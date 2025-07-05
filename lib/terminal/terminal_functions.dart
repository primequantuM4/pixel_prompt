import 'dart:io';

class TerminalFunctions {
  static bool get hasTerminal => stdout.hasTerminal;
  static int get terminalHeight => stdout.terminalLines;
  static int get terminalWidth => stdout.terminalColumns;

  static void enterFullScreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }

    stdout.write('\x1B[?1049h');
    stdout.write('\x1B[H');
  }

  static void exitFullScreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }
    stdout.write('\x1B[?1049l');
  }
}
