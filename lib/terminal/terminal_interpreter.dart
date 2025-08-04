import 'dart:math';

import 'package:pixel_prompt/pixel_prompt.dart';

enum TerminalState { csi, normal }

class TerminalInterpreter {
  int currentLine = 0;
  int currentColumn = 0;

  AnsiColorType? _foregroundColor;
  AnsiColorType? _backgroundColor;

  final Set<FontStyle> _fontStyles = {};

  int lines;
  int columns;

  List<List<CellState>> bufferState;

  StringBuffer ansiBuffer = StringBuffer();

  TerminalState _terminalState = TerminalState.normal;

  TerminalInterpreter(this.lines, this.columns)
    : bufferState = [
        for (int i = 0; i < lines; i++)
          [for (int j = 0; j < columns; j++) CellState()],
      ];

  bool seenEscapeCode = false;

  // terminating characters that trigger ANSI commands
  // Any latin alphabet character is technically a terminating character
  // TODO: Add more terminating characters when needed
  static const String styleTerminatingCharacter = 'm';
  static const String cursorHomeTerminatingCharacter = 'H';
  static const String upMovementTerminatingCharacter = 'A';
  static const String downMovementTerminatingCharacter = 'B';
  static const String forwardMovementTerminatingCharacter = 'C';
  static const String backMovementTerminatingCharacter = 'D';
  static const String clearLineTerminatingCharacter = 'K';
  static const String requestCursorTerminatingCharacter = 'n';
  static const String respondCursorTerminatingCharacter = 'R';
  static const String enableTerminatingCharacter = 'h';
  static const String disableTerminatingCharacter = 'l';

  void processInput(String data) {
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      _handleCharacterByState(char);
    }
  }

  String charactersToString() => _matrixToString(getCharactersMatrix());
  String fgColorsToString() => _formatMatrixToString(getFgMatrix());
  String bgColorsToString() => _formatMatrixToString(getBgMatrix());

  void writeToBufferState(String char) {
    bufferState[currentLine][currentColumn].character = char;
    bufferState[currentLine][currentColumn].foregroundColor = _foregroundColor;
    bufferState[currentLine][currentColumn].backgroundColor = _backgroundColor;
    bufferState[currentLine][currentColumn].fontStyles = {..._fontStyles};
  }

  List<List<String>> getCharactersMatrix() => bufferState
      .map((row) => row.map((cell) => cell.character).toList())
      .toList();

  List<List<String>> getFgMatrix() => bufferState
      .map(
        (row) => row
            .map((cell) => (cell.foregroundColor?.printableFg ?? 'default'))
            .toList(),
      )
      .toList();

  List<List<String>> getBgMatrix() => bufferState
      .map(
        (row) => row
            .map((cell) => (cell.backgroundColor?.printableBg ?? 'default'))
            .toList(),
      )
      .toList();

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

  void _processSingleCharacter(String char) {
    if (seenEscapeCode) {
      switch (char) {
        case '[':
          _terminalState = TerminalState.csi;
          seenEscapeCode = false;
          break;
        default:
          throw UnimplementedError();
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

  void _handleAnsiSequence(String char) {
    Set<String> terminatingCharacters = {
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

    if (terminatingCharacters.contains(char)) {
      _handleAnsiBuffer(char);
      _terminalState = TerminalState.normal;
      ansiBuffer.clear();
    } else {
      ansiBuffer.write(char);
    }
  }

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
        // ignore and clear buffer
        ansiBuffer.clear();
        break;
      default:
        throw UnimplementedError();
    }
  }

  void _handleStyleAnsi() {
    List<int>? data = _tryParseAnsiBuffer(clearLineTerminatingCharacter);

    if (data == null) return;

    // equivalent to \x1B[0m
    if (data.isEmpty) {
      _clearStyles();
    }

    for (int i = 0; i < data.length; i++) {
      int val = data[i];

      // clear styles
      if (val == 0) {
        _clearStyles();
      }
      // rgb foreground condition
      else if (val == 38 && i + 4 < data.length && data[i + 1] == 2) {
        int r = data[i + 2];
        int g = data[i + 3];
        int b = data[i + 4];

        if (_validRgbColor(r, g, b)) {
          _foregroundColor = ColorRGB(r, g, b);
        }
        i += 4;
      }
      // rgb background condition
      else if (val == 48 && i + 4 < data.length && data[i + 1] == 2) {
        int r = data[i + 2];
        int g = data[i + 3];
        int b = data[i + 4];

        if (_validRgbColor(r, g, b)) {
          _backgroundColor = ColorRGB(r, g, b);
        }
        i += 4;
      }
      // ANSI foreground colors
      else if ((30 <= val && val <= 37) || (90 <= val && val <= 97)) {
        _foregroundColor = _colorFromCode(val);
      }
      // ANSI background colors
      else if ((40 <= val && val <= 47) || (100 <= val && val <= 107)) {
        _backgroundColor = _colorFromCode(val);
      }
      // Styles
      else {
        for (final fs in FontStyle.values) {
          if (fs.code == val) _fontStyles.add(_styleFromCode(fs.code));
        }
      }
    }
  }

  void _handleClearCommand() {
    List<int>? ansiNumbers = _tryParseAnsiBuffer(clearLineTerminatingCharacter);

    if (ansiNumbers == null) return;

    // equivalent to \x1B[0K
    if (ansiNumbers.isEmpty) {
      _eraseFromCursorToEnd();
      return;
    }

    int command = ansiNumbers[0];

    if (command == 0) {
      _eraseFromCursorToEnd();
    } else if (command == 1) {
      _eraseFromBeginningToCursor();
    } else if (command == 2) {
      _eraseEntireLine();
    } // ignore other numbers as they don't do anything
  }

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

  void _handleDirectionMovementAnsi(String direction) {
    // current character is counted as a line so movement in any direction is n - 1
    // movement should be valid otherwise write to buffer whatever is in _ansiBuffer
    // nA/nB/nC/nD should be movement where n -> is a valid int

    List<int>? ansiNumbers;
    if (direction == 'up') {
      ansiNumbers = _tryParseAnsiBuffer(upMovementTerminatingCharacter);
    } else if (direction == 'down') {
      ansiNumbers = _tryParseAnsiBuffer(downMovementTerminatingCharacter);
    } else if (direction == 'back') {
      ansiNumbers = _tryParseAnsiBuffer(backMovementTerminatingCharacter);
    } else if (direction == 'forward') {
      ansiNumbers = _tryParseAnsiBuffer(forwardMovementTerminatingCharacter);
    } else {
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
      default:
    }
  }

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
        String remainingString = i + 1 < value.length
            ? value.substring(i + 1)
            : '';

        for (int j = 0; j < remainingString.length; j++) {
          if (currentColumn > columns - 1 || currentLine > lines - 1) break;
          writeToBufferState(remainingString[j]);
          currentColumn++;
        }

        if (currentColumn <= columns - 1 && currentLine <= lines - 1) {
          bufferState[currentLine][currentColumn].character =
              terminatingCharacter;
        }

        return null;
      } else {
        num = (num + int.parse(value[i])) * 10;
      }
    }

    // any remaining unprocessed number
    if (num > 0) res.add((num / 10).toInt());

    return res;
  }

  void _eraseFromCursorToEnd() {
    for (int i = currentColumn; i < columns; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  void _eraseFromBeginningToCursor() {
    for (int i = 0; i <= currentColumn; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  void _eraseEntireLine() {
    for (int i = 0; i < columns; i++) {
      bufferState[currentLine][i].character = ' ';
      bufferState[currentLine][i].backgroundColor = _backgroundColor;
      bufferState[currentLine][i].foregroundColor = _foregroundColor;
    }
  }

  String _matrixToString(List<List<String>> matrix) {
    return matrix.map((row) => row.join()).join('\n');
  }

  String _formatMatrixToString(List<List<String>> matrix) {
    final padded = _padMatrix(matrix);
    return padded.map((row) => row.join()).join('\n');
  }

  List<List<String>> _padMatrix(List<List<String>> matrix) {
    return matrix
        .map((row) => row.map((cell) => cell.padRight(8)).toList())
        .toList();
  }

  bool _canConvertToNumber(String char) {
    return int.tryParse(char) != null;
  }

  void _clearStyles() {
    _foregroundColor = null;
    _backgroundColor = null;
    _fontStyles.clear();
  }

  bool _validRgbColor(int r, int g, int b) {
    bool validRed = 0 <= r && r < 256;
    bool validGreen = 0 <= g && g < 256;
    bool validBlue = 0 <= b && b < 256;

    return validRed && validGreen && validBlue;
  }

  AnsiColorType _colorFromCode(int code) {
    final mapping = <int, Colors>{
      30: Colors.black,
      31: Colors.red,
      32: Colors.green,
      33: Colors.yellow,
      34: Colors.blue,
      35: Colors.magenta,
      36: Colors.cyan,
      37: Colors.white,
      90: Colors.highBlack,
      91: Colors.highRed,
      92: Colors.highGreen,
      93: Colors.highYellow,
      94: Colors.highBlue,
      95: Colors.highMagenta,
      96: Colors.highCyan,
      97: Colors.highWhite,
      40: Colors.black,
      41: Colors.red,
      42: Colors.green,
      43: Colors.yellow,
      44: Colors.blue,
      45: Colors.magenta,
      46: Colors.cyan,
      47: Colors.white,
      100: Colors.highBlack,
      101: Colors.highRed,
      102: Colors.highGreen,
      103: Colors.highYellow,
      104: Colors.highBlue,
      105: Colors.highMagenta,
      106: Colors.highCyan,
      107: Colors.highWhite,
    };
    return mapping[code]!;
  }

  FontStyle _styleFromCode(int code) {
    final mapping = <int, FontStyle>{
      1: FontStyle.bold,
      3: FontStyle.italic,
      4: FontStyle.underline,
      9: FontStyle.strikethrough,
    };

    return mapping[code]!;
  }
}

class CellState {
  String character = ' ';
  AnsiColorType? foregroundColor;
  AnsiColorType? backgroundColor;
  Set<FontStyle> fontStyles = {};

  void reset() {
    character = ' ';
    foregroundColor = null;
    backgroundColor = null;
  }

  @override
  String toString() {
    String style = fontStyles.map((style) => style.code).join(';');

    return 'CellState(char: $character fg: ${foregroundColor?.fg}, bg: ${backgroundColor?.bg}, style: $style})';
  }
}
