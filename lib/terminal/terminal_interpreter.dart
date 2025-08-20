import 'dart:math';

import 'package:pixel_prompt/pixel_prompt.dart';

/// Represents the current parsing state of terminal input.
///
/// Used by input parsers to track whether they're processing normal
/// characters or Control Sequence Introducer (CSI) sequences.
enum TerminalState {
  /// Processing a Control Sequence Introducer (escape sequence)
  csi,

  /// Processing normal character input
  normal,
}

/// ## Terminal ANSI Interpreter and Buffer Manager
///
/// Interprets ANSI escape sequences from terminal input and maintains
/// a virtual terminal buffer state representing characters, colors,
/// and font styles for each cell on the terminal screen.
///
/// This class processes input strings containing normal characters and
/// ANSI control sequences, updating the internal buffer accordingly.
///
/// The buffer is a 2D grid (`bufferState`) of [CellState], each cell
/// storing the character and its styling attributes.
///
/// Maintains cursor position (`currentLine`, `currentColumn`) and supports
/// ANSI sequences for text styling, cursor movement, clearing, and colors.
///
/// ### Example
/// ```dart
/// final interpreter = TerminalInterpreter(24, 80);
/// interpreter.processInput('Hello \x1B[31mRed\x1B[0m World!');
/// print(interpreter.charactersToString());
/// ```
///
/// ### See Also
/// - [ANSI escape code Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code)
/// - [AnsiColorType] for color representations.
/// - [FontStyle] for supported font styles.
/// {@category Terminal}
/// {@subCategory Parsing}
/// {@subCategory Rendering}
class TerminalInterpreter {
  /// Current cursor line (row), zero-based.
  int currentLine = 0;

  /// Current cursor column, zero-based.
  int currentColumn = 0;

  AnsiColorType? _foregroundColor;
  AnsiColorType? _backgroundColor;

  final Set<FontStyle> _fontStyles = {};

  /// Number of lines (rows) in the terminal buffer.
  final int lines;

  /// Number of columns in the terminal buffer.
  final int columns;

  /// 2D buffer storing the state of each terminal cell.
  final List<List<CellState>> bufferState;

  /// Buffer accumulating characters of an ongoing ANSI escape sequence.
  final StringBuffer ansiBuffer = StringBuffer();

  TerminalState _terminalState = TerminalState.normal;

  /// Tracks if an escape code has been seen (e.g., '\x1B').
  bool seenEscapeCode = false;

  /// ANSI control sequence terminating characters.

  /// Terminating character for text style sequences (SGR - Select Graphic Rendition)
  static const String styleTerminatingCharacter = 'm';

  /// Terminating character for cursor home position sequences (CUP - Cursor Position)
  static const String cursorHomeTerminatingCharacter = 'H';

  /// Terminating character for cursor up movement sequences (CUU - Cursor Up)
  static const String upMovementTerminatingCharacter = 'A';

  /// Terminating character for cursor down movement sequences (CUD - Cursor Down)
  static const String downMovementTerminatingCharacter = 'B';

  /// Terminating character for cursor forward movement sequences (CUF - Cursor Forward)
  static const String forwardMovementTerminatingCharacter = 'C';

  /// Terminating character for cursor back movement sequences (CUB - Cursor Back)
  static const String backMovementTerminatingCharacter = 'D';

  /// Terminating character for line clearing sequences (EL - Erase in Line)
  static const String clearLineTerminatingCharacter = 'K';

  /// Terminating character for cursor position request sequences (DSR - Device Status Report)
  static const String requestCursorTerminatingCharacter = 'n';

  /// Terminating character for cursor position response sequences (CPR - Cursor Position Report)
  static const String respondCursorTerminatingCharacter = 'R';

  /// Terminating character for enable feature sequences (SM - Set Mode)
  static const String enableTerminatingCharacter = 'h';

  /// Terminating character for disable feature sequences (RM - Reset Mode)
  static const String disableTerminatingCharacter = 'l';

  /// Set of terminating characters for ANSI sequences.
  static const Set<String> terminatingCharacters = {
    styleTerminatingCharacter,
    cursorHomeTerminatingCharacter,
    upMovementTerminatingCharacter,
    downMovementTerminatingCharacter,
    forwardMovementTerminatingCharacter,
    backMovementTerminatingCharacter,
    clearLineTerminatingCharacter,
    requestCursorTerminatingCharacter,
    respondCursorTerminatingCharacter,
    enableTerminatingCharacter,
    disableTerminatingCharacter,
  };

  // Constants for parsing ANSI color and style codes.
  static const int _ansiFgRGB = 38;
  static const int _ansiBgRGB = 48;
  static const int _ansiRgbMode = 2;
  static const int _rgbComponentCount = 3;
  static const int _expectedExtraArgs = _rgbComponentCount + 1;

  static const int _ansiFgStart = 30;
  static const int _ansiFgBrightStart = 90;
  static const int _ansiFgEnd = 37;
  static const int _ansiFgBrightEnd = 97;

  static const int _ansiBgStart = 40;
  static const int _ansiBgBrightStart = 100;
  static const int _ansiBgEnd = 47;
  static const int _ansiBgBrightEnd = 107;

  static const int _eraseCursorToEndCommand = 0;
  static const int _eraseStartToCursorCommand = 1;
  static const int _eraseLineCommand = 2;

  /// Creates a terminal interpreter with given [lines] and [columns] size.
  ///
  /// Initializes the internal buffer state with empty cells.
  TerminalInterpreter(this.lines, this.columns)
    : bufferState = [
        for (int i = 0; i < lines; i++)
          [for (int j = 0; j < columns; j++) CellState()],
      ];

  /// Processes an input string containing text and ANSI sequences.
  ///
  /// Updates the terminal buffer and cursor position accordingly.
  void processInput(String data) {
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      _handleCharacterByState(char);
    }
  }

  /// Returns the character content of the buffer as a multi-line string.
  String charactersToString() => _matrixToString(getCharactersMatrix());

  /// Returns the foreground color matrix as a formatted string.
  String fgColorsToString() => _formatMatrixToString(getFgMatrix());

  /// Returns the background color matrix as a formatted string.
  String bgColorsToString() => _formatMatrixToString(getBgMatrix());

  /// Writes a single character and current style attributes at the cursor.
  void writeToBufferState(String char) {
    bufferState[currentLine][currentColumn].character = char;
    bufferState[currentLine][currentColumn].foregroundColor = _foregroundColor;
    bufferState[currentLine][currentColumn].backgroundColor = _backgroundColor;
    bufferState[currentLine][currentColumn].fontStyles = {..._fontStyles};
  }

  /// Returns a 2D list of characters from the buffer.
  List<List<String>> getCharactersMatrix() => bufferState
      .map((row) => row.map((cell) => cell.character).toList())
      .toList();

  /// Returns a 2D list of foreground colors as printable strings.
  List<List<String>> getFgMatrix() => bufferState
      .map(
        (row) => row
            .map((cell) => (cell.foregroundColor?.printableFg ?? 'default'))
            .toList(),
      )
      .toList();

  /// Returns a 2D list of background colors as printable strings.
  List<List<String>> getBgMatrix() => bufferState
      .map(
        (row) => row
            .map((cell) => (cell.backgroundColor?.printableBg ?? 'default'))
            .toList(),
      )
      .toList();

  /// Handles an incoming character [char] according to the current terminal state.
  ///
  /// - If the terminal is in the [TerminalState.normal] state,
  ///   it processes the character as either normal text or escape sequence start.
  ///
  /// - If the terminal is in the [TerminalState.csi] (Control Sequence Introducer) state,
  ///   it accumulates the character into the ANSI escape sequence buffer and
  ///   triggers handling when a terminating character is reached.
  void _handleCharacterByState(String char) {
    switch (_terminalState) {
      case TerminalState.normal:
        _processSingleCharacter(char);
        break;
      case TerminalState.csi:
        _handleAnsiSequence(char);
        break;
    }
  }

  /// Processes a single character in the normal terminal state.
  ///
  /// - Detects the start of an escape sequence (ESC, '\x1B') and marks `seenEscapeCode`.
  /// - On receiving newline `\n` or carriage return `\r`, moves the cursor appropriately.
  /// - Writes normal characters to the buffer at the current cursor position.
  /// - If an escape code was previously seen, switches state to CSI if the next char is '['.
  ///   Otherwise, throws if unknown escape sequences are encountered.
  void _processSingleCharacter(String char) {
    if (seenEscapeCode) {
      switch (char) {
        case '[':
          _terminalState = TerminalState.csi;
          seenEscapeCode = false;
          break;
        default:
          throw UnimplementedError('Unknown escape sequence: \x1B$char');
      }
    } else {
      switch (char) {
        case '\x1B':
          seenEscapeCode = true;
          break;
        case '\n':
          if (currentLine < lines) currentLine++;
          currentColumn = 0;
          break;
        case '\r':
          currentColumn = 0;
          break;
        default:
          writeToBufferState(char);
          if (currentColumn < columns) currentColumn++;
      }
    }
  }

  /// Handles characters received while in the CSI (Control Sequence Introducer) state.
  ///
  /// - Accumulates characters into the ANSI escape sequence buffer (`ansiBuffer`).
  /// - When a terminating character is detected, triggers processing of the full sequence.
  /// - Resets the terminal state to normal after processing.
  void _handleAnsiSequence(String char) {
    if (terminatingCharacters.contains(char)) {
      _handleAnsiBuffer(char);
      _terminalState = TerminalState.normal;
      ansiBuffer.clear();
    } else {
      ansiBuffer.write(char);
    }
  }

  /// Interprets the accumulated ANSI escape sequence in `ansiBuffer` based on the terminating [char].
  ///
  /// - Dispatches to specific handlers based on the terminating character:
  ///   - Style changes ('m')
  ///   - Cursor movements ('A', 'B', 'C', 'D', 'H')
  ///   - Line clearing ('K')
  ///   - Ignored or unsupported sequences clear the buffer silently.
  /// - Throws on unrecognized terminating characters to flag unsupported sequences.
  void _handleAnsiBuffer(String char) {
    switch (char) {
      case styleTerminatingCharacter:
        _handleStyleAnsi();
        break;
      case upMovementTerminatingCharacter:
        _handleDirectionMovementAnsi('up');
        break;
      case downMovementTerminatingCharacter:
        _handleDirectionMovementAnsi('down');
        break;
      case backMovementTerminatingCharacter:
        _handleDirectionMovementAnsi('back');
        break;
      case forwardMovementTerminatingCharacter:
        _handleDirectionMovementAnsi('forward');
        break;
      case cursorHomeTerminatingCharacter:
        _handleMovement();
        break;
      case clearLineTerminatingCharacter:
        _handleClearCommand();
        break;
      case requestCursorTerminatingCharacter:
      case respondCursorTerminatingCharacter:
      case disableTerminatingCharacter:
      case enableTerminatingCharacter:
        // Ignored sequences; just clear buffer.
        ansiBuffer.clear();
        break;
      default:
        throw UnimplementedError('Unhandled ANSI terminating char: $char');
    }
  }

  /// Processes ANSI style escape sequences (e.g., '\x1B[31m' for red text).
  ///
  /// - Parses the numeric parameters in the escape sequence.
  /// - Applies style resets, foreground/background color changes (including RGB),
  ///   and font style toggles accordingly.
  void _handleStyleAnsi() {
    List<int>? data = _tryParseAnsiBuffer(clearLineTerminatingCharacter);
    if (data == null) return;

    if (data.isEmpty) {
      _clearStyles();
      return;
    }

    for (int i = 0; i < data.length; i++) {
      int val = data[i];

      if (val == 0) {
        _clearStyles();
      } else if (val == _ansiFgRGB &&
          i + _expectedExtraArgs < data.length &&
          data[i + 1] == _ansiRgbMode) {
        final rgb = _extractRGB(data, i);
        if (rgb != null) _foregroundColor = rgb;
        i += _expectedExtraArgs;
      } else if (val == _ansiBgRGB &&
          i + _expectedExtraArgs < data.length &&
          data[i + 1] == _ansiRgbMode) {
        final rgb = _extractRGB(data, i);
        if (rgb != null) _backgroundColor = rgb;
        i += _expectedExtraArgs;
      } else if ((_ansiFgStart <= val && val <= _ansiFgEnd) ||
          (_ansiFgBrightStart <= val && val <= _ansiFgBrightEnd)) {
        _foregroundColor = Colors.fromCode(val);
      } else if ((_ansiBgStart <= val && val <= _ansiBgEnd) ||
          (_ansiBgBrightStart <= val && val <= _ansiBgBrightEnd)) {
        _backgroundColor = Colors.fromCode(val);
      } else {
        for (final fs in FontStyle.values) {
          if (fs.code == val) _fontStyles.add(FontStyle.fromCode(fs.code));
        }
      }
    }
  }

  /// Processes the ANSI clear line commands (e.g., '\x1B[K').
  ///
  /// - Supports clearing from cursor to end of line,
  ///   from start of line to cursor,
  ///   or the entire line based on parameters.
  void _handleClearCommand() {
    List<int>? ansiNumbers = _tryParseAnsiBuffer(clearLineTerminatingCharacter);
    if (ansiNumbers == null) return;

    if (ansiNumbers.isEmpty) {
      _eraseFromCursorToEnd();
      return;
    }

    int command = ansiNumbers[0];

    if (command == _eraseCursorToEndCommand) {
      _eraseFromCursorToEnd();
    } else if (command == _eraseStartToCursorCommand) {
      _eraseFromBeginningToCursor();
    } else if (command == _eraseLineCommand) {
      _eraseEntireLine();
    }
  }

  /// Handles cursor movement to a specific location (e.g., '\x1B[10;20H').
  ///
  /// - Parses the line and column numbers from the escape sequence parameters.
  /// - Updates [currentLine] and [currentColumn] cursor positions within buffer limits.
  void _handleMovement() {
    List<int>? ansiNumbers = _tryParseAnsiBuffer(
      cursorHomeTerminatingCharacter,
    );

    if (ansiNumbers == null || ansiNumbers.isEmpty) return;

    currentLine = max(min(ansiNumbers[0] - 1, lines), 0);

    if (ansiNumbers.length > 1) {
      currentColumn = max(min(ansiNumbers[1] - 1, columns), 0);
    }
  }

  /// Handles directional cursor movements (up, down, back, forward) using ANSI sequences.
  ///
  /// - Uses parameters to determine how many cells to move.
  /// - Updates the current cursor position accordingly, clamping within terminal bounds.
  void _handleDirectionMovementAnsi(String direction) {
    List<int>? ansiNumbers;

    switch (direction) {
      case 'up':
        ansiNumbers = _tryParseAnsiBuffer(upMovementTerminatingCharacter);
        break;
      case 'down':
        ansiNumbers = _tryParseAnsiBuffer(downMovementTerminatingCharacter);
        break;
      case 'back':
        ansiNumbers = _tryParseAnsiBuffer(backMovementTerminatingCharacter);
        break;
      case 'forward':
        ansiNumbers = _tryParseAnsiBuffer(forwardMovementTerminatingCharacter);
        break;
      default:
        ansiNumbers = [];
    }

    if (ansiNumbers == null || ansiNumbers.isEmpty) return;

    int cursorMovement = ansiNumbers[0] - 1;

    switch (direction) {
      case 'up':
        currentLine = max(currentLine - cursorMovement, 0);
        break;
      case 'down':
        currentLine = min(currentLine + cursorMovement, lines - 1);
        break;
      case 'back':
        currentColumn = max(currentColumn - cursorMovement, 0);
        break;
      case 'forward':
        currentColumn = min(currentColumn + cursorMovement, columns - 1);
        break;
    }
  }

  /// Attempts to parse the accumulated ANSI buffer into a list of integers.
  ///
  /// Returns `null` if parsing fails or buffer contains non-numeric data.
  /// Parses the accumulated ANSI parameter string in [ansiBuffer] into a list of integers.
  ///
  /// - The ANSI parameters are typically separated by semicolons (`;`).
  /// - Returns a list of integer parameters extracted from the buffer.
  /// - If non-numeric characters are found during parsing (unexpected input),
  ///   writes those characters literally into the buffer starting at the current cursor,
  ///   inserts the terminating character literally as well, then returns null to indicate failure.
  ///
  /// Example:
  ///   For input buffer "1;34;48;2;255;0;0", returns [1, 34, 48, 2, 255, 0, 0].
  List<int>? _tryParseAnsiBuffer(String terminatingCharacter) {
    String value = ansiBuffer.toString();
    List<int> res = [];

    int num = 0;

    for (int i = 0; i < value.length; i++) {
      if (value[i] == ';') {
        res.add((num / 10).toInt());
        num = 0;
        continue;
      }

      if (!_canConvertToNumber(value[i])) {
        // Write remaining characters literally to buffer starting at cursor.
        String remainingString = i + 1 < value.length
            ? value.substring(i + 1)
            : '';

        for (int j = 0; j < remainingString.length; j++) {
          if (currentColumn > columns - 1 || currentLine > lines - 1) break;
          writeToBufferState(remainingString[j]);
          currentColumn++;
        }

        // Write the terminating character literally if possible.
        if (currentColumn <= columns - 1 && currentLine <= lines - 1) {
          bufferState[currentLine][currentColumn].character =
              terminatingCharacter;
        }

        return null;
      } else {
        // Build the number digit-by-digit (note the multiplication by 10).
        num = (num + int.parse(value[i])) * 10;
      }
    }

    // Add the last parsed number if any.
    if (num > 0) res.add((num / 10).toInt());

    return res;
  }

  /// Erases characters from the cursor position to the end of the current line.
  ///
  /// - Sets characters to space (' ').
  /// - Applies current background and foreground colors.
  void _eraseFromCursorToEnd() {
    for (int i = currentColumn; i < columns; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  /// Erases characters from the beginning of the current line up to the cursor position.
  ///
  /// - Sets characters to space (' ').
  /// - Applies current background and foreground colors.
  void _eraseFromBeginningToCursor() {
    for (int i = 0; i <= currentColumn; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  /// Erases the entire current line.
  ///
  /// - Sets all characters in the line to space (' ').
  /// - Applies current background and foreground colors.
  void _eraseEntireLine() {
    for (int i = 0; i < columns; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  /// Converts a matrix of strings (e.g., characters) to a single string with newlines.
  ///
  /// - Each row is concatenated to a string.
  /// - Rows are joined by newline characters.
  String _matrixToString(List<List<String>> matrix) {
    return matrix.map((row) => row.join()).join('\n');
  }

  /// Formats a matrix of strings by padding each cell to width 8, then joins as string.
  ///
  /// - Useful for aligned output of color or style matrices.
  String _formatMatrixToString(List<List<String>> matrix) {
    final padded = _padMatrix(matrix);
    return padded.map((row) => row.join()).join('\n');
  }

  /// Pads each cell string in the matrix to fixed width (8) by right-padding with spaces.
  ///
  /// - Helps to visually align output columns.
  List<List<String>> _padMatrix(List<List<String>> matrix) {
    return matrix
        .map((row) => row.map((cell) => cell.padRight(8)).toList())
        .toList();
  }

  /// Checks if the given character can be parsed as a decimal digit.
  ///
  /// Returns true if the character is a digit, false otherwise.
  bool _canConvertToNumber(String char) {
    return int.tryParse(char) != null;
  }

  /// Clears all current text styles and colors (foreground and background).
  void _clearStyles() {
    _foregroundColor = null;
    _backgroundColor = null;
    _fontStyles.clear();
  }

  /// Extracts an RGB color from a list of ANSI parameters starting at [start].
  ///
  /// - Expects the format: [38|48, 2, R, G, B] starting at index [start].
  /// - Returns a [ColorRGB] if the color components are valid; otherwise null.
  ColorRGB? _extractRGB(List<int> data, int start) {
    final r = data[start + 2];
    final g = data[start + 3];
    final b = data[start + 4];
    return _validRgbColor(r, g, b) ? ColorRGB(r, g, b) : null;
  }

  /// Validates whether RGB color components [r], [g], and [b] are within 0-255.
  ///
  /// Returns true if all components are valid colors.
  bool _validRgbColor(int r, int g, int b) {
    return (0 <= r && r < 256) && (0 <= g && g < 256) && (0 <= b && b < 256);
  }
}

/// Represents the state of a single cell in the terminal buffer.
///
/// Stores the character, foreground and background colors, and font styles.
class CellState {
  /// The character displayed in this cell.
  String character = ' ';

  /// The foreground color of this cell.
  AnsiColorType? foregroundColor;

  /// The background color of this cell.
  AnsiColorType? backgroundColor;

  /// The set of font styles applied to this cell.
  Set<FontStyle> fontStyles = {};

  /// Resets this cell to default empty state.
  void reset() {
    character = ' ';
    foregroundColor = null;
    backgroundColor = null;
  }

  @override
  String toString() {
    String style = fontStyles.map((style) => style.code).join(';');
    return 'CellState(char: $character fg: ${foregroundColor?.fg}, bg: ${backgroundColor?.bg}, style: $style)';
  }
}
