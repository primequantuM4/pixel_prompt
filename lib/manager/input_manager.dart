import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/manager/input_dispatcher.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Manages raw terminal input handling, parsing, and dispatching.
///
/// The `InputManager` is responsible for reading raw input bytes from
/// standard input, interpreting them as terminal input events (keyboard,
/// mouse, special sequences), and dispatching them via an [InputDispatcher].
///
/// It also manages terminal modes and input features, such as enabling mouse
/// input, ANSI processing (on Windows), and querying the cursor position.
///
/// ### Responsibilities:
/// - Configure terminal modes for raw input.
/// - Parse raw input bytes into high-level [InputEvent]s.
/// - Dispatch events to registered handlers.
/// - Support cursor position querying and mouse event parsing.
/// - Handle input pausing and graceful shutdown.
///
/// ### Lifecycle:
/// - Constructed with an [InputDispatcher] to forward input events.
/// - Listens asynchronously on `stdin` for input data.
/// - Supports Windows and Unix-like platforms with platform-specific setup.
/// - Cleans up and restores terminal state on stop.
///
/// ### Example
/// ```dart
/// final dispatcher = InputDispatcher(renderer: renderManager);
/// final inputManager = InputManager(dispatcher: dispatcher);
///
/// // Subscribe to mouse events if needed:
/// inputManager.onEvent = (event) {
///   if (event is MouseEvent) {
///     print('Mouse event at (${event.x}, ${event.y})');
///   }
/// };
///
/// // Later, gracefully stop input handling:
/// inputManager.stop();
/// ```
///
/// ### See also
/// - [InputDispatcher]: Receives and routes parsed input events.
/// - [InputEvent]: Represents keyboard, mouse, and other input types.
/// - [RenderManager]: Manages rendering that might respond to input events.
/// - [MouseEvent]: Represents mouse-specific input events.
///
/// {@category Input}
class InputManager {
  /// Whether input processing is currently paused.
  bool _isInputPaused = false;

  /// Cache for whether cursor position reporting is supported.
  bool? _cursorSupported;

  /// Whether a cursor position response is expected from the terminal.
  bool _expectingCursorResponse = false;

  /// Last known cursor X position from terminal response (0-based).
  int returnedCursorPositionX = -1;

  /// Last known cursor Y position from terminal response (0-based).
  int returnedCursorPositionY = -1;

  static const String _tag = 'InputManager';

  /// Callback invoked with cursor position when terminal responds.
  void Function(int, int)? _cursorCallback;

  /// Optional callback for external subscription to mouse events.
  Function(MouseEvent)? onEvent;

  /// Subscription to the standard input stream.
  StreamSubscription<List<int>>? _stdinSubscription;

  /// Dispatcher responsible for handling and propagating input events.
  final InputDispatcher _dispatcher;

  /// Buffer accumulating raw input bytes for processing.
  final List<int> _inputBuffer = [];

  /// Buffer accumulating bytes related to cursor position responses.
  final List<int> _cursorInputBuffer = [];

  /// Creates an [InputManager] forwarding parsed events to the given [dispatcher].
  ///
  /// Automatically configures terminal modes, enables mouse input, and begins
  /// listening for stdin input bytes.
  InputManager({required InputDispatcher dispatcher})
    : _dispatcher = dispatcher {
    _configureStdin();
    _enableMouseInput();

    ProcessSignal.sigint.watch().listen((signal) {
      // Gracefully handle Ctrl-C (SIGINT)
      _manageHandlers([0x03]);
    });

    if (Platform.isWindows) {
      _enableWindowsAnsi();
    }

    _stdinSubscription = stdin.listen(_manageHandlers);
  }

  /// Configures `stdin` terminal modes for raw input by disabling echo and line mode.
  void _configureStdin() {
    if (stdin.hasTerminal) {
      stdin
        ..echoMode = false
        ..lineMode = false;
    }
  }

  /// Enables terminal mouse input reporting sequences via ANSI escape codes.
  void _enableMouseInput() {
    stdout.write('\x1B[?1006h\x1B[?1003h');
  }

  /// Checks asynchronously if the terminal supports cursor position reporting,
  /// with a configurable [timeout].
  ///
  /// Sends a cursor position request and completes with `true` if a response is
  /// received within [timeout], else completes `false`.
  Future<bool> supportsCursorResponse({
    Duration timeout = const Duration(milliseconds: 200),
  }) {
    final completer = Completer<bool>();
    getCursorPosition((x, y) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        _expectingCursorResponse = false;
        _cursorInputBuffer.clear();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  /// Returns a cached result indicating whether cursor position reporting is supported.
  ///
  /// If not cached, performs the asynchronous check via [supportsCursorResponse].
  Future<bool> isCursorSupported() async {
    if (_cursorSupported != null) return _cursorSupported!;
    _cursorSupported = await supportsCursorResponse();
    return _cursorSupported!;
  }

  /// Enables Windows console input modes required for ANSI escape sequences and mouse input.
  ///
  /// Uses Win32 API to enable virtual terminal processing, mouse input, and window input.
  void _enableWindowsAnsi() {
    final handle = GetStdHandle(STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
      handle,
      mode.value |
          ENABLE_VIRTUAL_TERMINAL_INPUT |
          ENABLE_MOUSE_INPUT |
          ENABLE_WINDOW_INPUT,
    );
    calloc.free(mode);
  }

  /// Restores Windows console input modes to original defaults.
  void _restoreWindowsConsoleMode() {
    final handle = GetStdHandle(STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
      handle,
      mode.value &
          ~(ENABLE_VIRTUAL_TERMINAL_INPUT |
              ENABLE_MOUSE_INPUT |
              ENABLE_WINDOW_INPUT),
    );

    calloc.free(mode);
  }

  /// Handles incoming raw input bytes from stdin, parses them into [InputEvent]s,
  /// and dispatches events via [_dispatcher].
  ///
  /// Detects mouse sequences, special key sequences, single-byte keys, and unknown inputs.
  ///
  /// If input is paused via [pauseInput], this method immediately returns without processing.
  void _manageHandlers(List<int> data) {
    Logger.trace(_tag, "Stream received $data");
    if (_isInputPaused) return;

    if (_expectingCursorResponse) {
      _handleCursorResponse(data);
      return;
    }

    _inputBuffer.addAll(data);

    while (_inputBuffer.isNotEmpty) {
      InputEvent dispatchedEvent;

      // Mouse event detection: ESC [ <
      if (_inputBuffer.length >= 3 &&
          _inputBuffer[0] == 0x1B &&
          _inputBuffer[1] == 0x5B &&
          _inputBuffer[2] == 0x3C) {
        final mouseEvents = _processMouseBuffer();
        for (final event in mouseEvents) {
          _dispatcher.dispatchEvent(event);
          onEvent?.call(event); // notify external subscriber if set
        }
        return;
      }
      // ANSI special key sequences starting with ESC
      else if (_inputBuffer[0] == 0x1B && _inputBuffer.length >= 3) {
        final sequence = _inputBuffer.sublist(0, 3);
        dispatchedEvent = _parseEscapeSequence(sequence);
        _inputBuffer.removeRange(0, 3);
      }
      // Windows-style sequences starting with 0xE0
      else if (_inputBuffer[0] == 0xE0 && _inputBuffer.length >= 2) {
        final sequence = _inputBuffer.sublist(0, 2);
        dispatchedEvent = _parseEscapeSequence(sequence);
        _inputBuffer.removeRange(0, 2);
      }
      // Single byte keys
      else if (_inputBuffer.length == 1) {
        final byte = _inputBuffer.removeAt(0);
        dispatchedEvent = _parseSingleByte(byte);
      }
      // Unknown input
      else {
        dispatchedEvent = UnknownEvent();
      }

      if (_dispatcher.dispatchEvent(dispatchedEvent)) stop();
    }
  }

  /// Parses a special key escape [sequence] into a corresponding [InputEvent].
  InputEvent _parseEscapeSequence(List<int> sequence) {
    switch (sequence[2]) {
      case 0x41:
        return KeyEvent(code: KeyCode.arrowUp);
      case 0x42:
        return KeyEvent(code: KeyCode.arrowDown);
      case 0x43:
        return KeyEvent(code: KeyCode.arrowRight);
      case 0x44:
        return KeyEvent(code: KeyCode.arrowLeft);
      case 0x5A:
        return KeyEvent(code: KeyCode.shiftTab);
      default:
        return SequenceEvent(sequence: sequence);
    }
  }

  /// Parses a single byte [byte] input into a corresponding [InputEvent].
  InputEvent _parseSingleByte(int byte) {
    if (byte == 0x0A || byte == 0x0D) {
      return KeyEvent(code: KeyCode.character, char: '\n');
    } else if (byte == 0x03) {
      Logger.trace(_tag, 'Received the exit signal, [Ctrl-C]');
      return KeyEvent(code: KeyCode.ctrlC);
    } else if (byte == 0x08 || byte == 0x7F) {
      return KeyEvent(code: KeyCode.backspace);
    } else {
      final input = String.fromCharCode(byte);
      if (input == '\t') {
        Logger.trace(_tag, 'Tab pressed');
        return KeyEvent(code: KeyCode.tab);
      } else if (byte >= 32 && byte <= 126) {
        return KeyEvent(code: KeyCode.character, char: input);
      } else {
        return UnknownEvent(byte: byte);
      }
    }
  }

  /// Handles raw input data expected to be a cursor position response.
  ///
  /// Parses sequences like ESC [ row ; col R and invokes the registered cursor callback.
  void _handleCursorResponse(List<int> data) {
    _cursorInputBuffer.addAll(data);

    String input = String.fromCharCodes(_cursorInputBuffer);

    RegExp regex = RegExp(r'\x1B\[(\d+);(\d+)R');
    Match? match = regex.firstMatch(input);

    if (match != null) {
      _expectingCursorResponse = false;
      _cursorInputBuffer.clear();

      int row = int.parse(match.group(1)!);
      int col = int.parse(match.group(2)!);
      _cursorCallback?.call(col - 1, row - 1);
    }
  }

  /// Stops input handling, restores terminal to normal state, and exits the process.
  ///
  /// This disables mouse reporting, restores console modes (Windows or POSIX),
  /// shows the cursor, and cancels the input subscription.
  void stop() {
    stdout.write('\x1B[?1006l\x1B[?1003l');

    if (Platform.isWindows) {
      _restoreWindowsConsoleMode();
    } else {
      if (stdin.hasTerminal) {
        stdin
          ..echoMode = true
          ..lineMode = true;
      }
    }

    stdout.write(
      '\x1B[?1049l',
    ); // TODO: make sure ONLY to handle this in full screen mode
    stdout.write('\x1B[?25h');
    stdout.write('\x1B[$returnedCursorPositionY;${returnedCursorPositionX}H');
    _stdinSubscription?.cancel();
    exit(0);
  }

  /// Pauses input handling temporarily.
  void pauseInput() {
    _isInputPaused = true;
  }

  /// Resumes input handling after pause.
  void resumeInput() {
    _isInputPaused = false;
  }

  /// Processes the input buffer for mouse event sequences.
  ///
  /// Returns a list of parsed [MouseEvent]s.
  List<MouseEvent> _processMouseBuffer() {
    final List<MouseEvent> mouseEvents = [];
    while (true) {
      int start = _inputBuffer.indexOf(27);
      if (start == -1) break;

      int end = _inputBuffer.indexOf(77, start);
      if (end == -1) {
        end = _inputBuffer.indexOf(109, start);
        if (end == -1) break;
      }

      String sequence = String.fromCharCodes(
        _inputBuffer.sublist(start, end + 1),
      );
      _inputBuffer.removeRange(start, end + 1);
      final event = _parseMouseEvent(sequence);
      if (event != null) mouseEvents.add(event);
    }

    return mouseEvents;
  }

  /// Requests the terminal to send the current cursor position.
  ///
  /// The given [callback] is invoked with zero-based (x,y) coordinates.
  void getCursorPosition(void Function(int x, int y) callback) {
    stdout.write('\x1B[6n');
    _expectingCursorResponse = true;
    _cursorCallback = callback;
  }

  /// Asynchronously fetches the current cursor position.
  Future<Point<int>> fetchCursorPosition() {
    final completer = Completer<Point<int>>();

    getCursorPosition((x, y) {
      completer.complete(Point(x, y));
    });

    return completer.future;
  }

  /// Parses a mouse event from the given escape sequence.
  ///
  /// Returns a [MouseEvent] or `null` if parsing fails.
  MouseEvent? _parseMouseEvent(String sequence) {
    try {
      String data = sequence.substring(3, sequence.length - 1);
      List<String> parts = data.split(';');
      if (parts.length != 3) return null;

      int cb = int.parse(parts[0]);
      int x = int.parse(parts[1]) - 1;
      int y = int.parse(parts[2]) - 1;
      bool isRelease = sequence.endsWith('m');
      bool isMotion = (cb & 0x20) != 0;

      MouseEventType type = MouseEventType.click;
      if (isRelease) {
        type = MouseEventType.release;
      } else if (isMotion) {
        type = MouseEventType.hover;
      }

      int button = cb & ~0x20;

      return MouseEvent(type: type, x: x, y: y, button: button);
    } catch (e) {
      print('Error parsing mouse event: $e');
      return null;
    }
  }
}
