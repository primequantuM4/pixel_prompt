import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

/// Handles input in a modal command mode, similar to a text editor's command line.
///
/// This [InputHandler] listens for a command mode trigger (the `:` character),
/// then accumulates user input until execution or cancellation.
///
/// It supports:
/// - Entering command mode by typing `:`
/// - Executing commands by pressing Enter (e.g., `:q` to exit)
/// - Handling backspace to edit the command buffer
/// - Exiting command mode on command execution or Ctrl+C
///
/// ### Usage
/// Typical usage involves feeding input events to this handler when command mode
/// functionality is desired.
///
///
/// {@category Input}
class CommandModeHandler implements InputHandler {
  bool _inCommandMode = false;
  final StringBuffer _buffer = StringBuffer();

  /// Processes an input event and updates command mode state accordingly.
  ///
  /// Returns a [ResponseInput] indicating if the event was handled and
  /// any commands triggered.
  @override
  ResponseInput handleInput(InputEvent event) {
    if (!_shouldHandle(event)) {
      return ResponseInput(commands: ResponseCommands.none, handled: false);
    }

    event = event as KeyEvent;
    if (event.code == KeyCode.character &&
        (event.char == '\r' || event.char == '\n')) {
      return executeCommand();
    } else if (event.code == KeyCode.ctrlC) {
      return ResponseInput(commands: ResponseCommands.exit, handled: true);
    } else if (event.code == KeyCode.backspace) {
      String value = _buffer.toString();
      if (value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
        _buffer.clear();
        _buffer.write(value);
      }
    } else {
      _buffer.write(event.char);
    }

    return ResponseInput(commands: ResponseCommands.none, handled: true);
  }

  /// Executes the buffered command and returns a response indicating
  /// any triggered commands.
  ///
  /// Currently, `:q` triggers an exit command.
  ResponseInput executeCommand() {
    final ResponseCommands responseCommands;
    if (_buffer.toString() == ':q') {
      responseCommands = ResponseCommands.exit;
    } else {
      responseCommands = ResponseCommands.none;
    }

    _exitCommandMode();
    return ResponseInput(commands: responseCommands, handled: true);
  }

  /// Determines if the event should be handled by this handler,
  /// entering command mode on ':' character.
  bool _shouldHandle(InputEvent event) {
    if (event is! KeyEvent) return false;
    if (!_inCommandMode && event.char == ':') {
      _enterCommandMode();
    }
    return _inCommandMode ||
        (!_inCommandMode && event.char == ':') ||
        event.code == KeyCode.ctrlC;
  }

  /// Enters command mode and clears the command buffer.
  void _enterCommandMode() {
    _inCommandMode = true;
    _buffer.clear();
  }

  /// Exits command mode and clears the command buffer.
  void _exitCommandMode() {
    _inCommandMode = false;
    _buffer.clear();
  }
}
