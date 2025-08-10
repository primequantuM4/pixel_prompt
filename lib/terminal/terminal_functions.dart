import 'dart:io';

/// ## Terminal Control Utilities
///
/// Provides static helper functions for querying terminal properties
/// and controlling terminal modes such as entering and exiting fullscreen.
///
/// Wraps common ANSI escape codes for terminal control with safety checks
/// to ensure terminal availability.
///
/// ### Example
/// ```dart
/// if (TerminalFunctions.hasTerminal) {
///   print('Terminal size: ${TerminalFunctions.terminalWidth}x${TerminalFunctions.terminalHeight}');
///   TerminalFunctions.enterFullScreen();
///   // ... run fullscreen UI ...
///   TerminalFunctions.exitFullScreen();
/// }
/// ```
///
/// ### See Also
/// - [stdout.hasTerminal]: Platform API to check terminal presence.
/// - ANSI escape codes documentation for terminal control sequences.
///
/// {@category Terminal}
/// {@category Utilities}
class TerminalFunctions {
  /// Whether the current process's stdout is connected to a terminal.
  static bool get hasTerminal => stdout.hasTerminal;

  /// Returns the current height (rows) of the terminal.
  static int get terminalHeight => stdout.terminalLines;

  /// Returns the current width (columns) of the terminal.
  static int get terminalWidth => stdout.terminalColumns;

  /// Switches the terminal into the "alternate" fullscreen buffer.
  ///
  /// Throws [UnsupportedError] if a terminal is not detected.
  /// Uses the ANSI escape sequence `\x1B[?1049h`.
  static void enterFullScreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }

    stdout.write('\x1B[?1049h'); // Enable alternate screen buffer
    stdout.write('\x1B[H'); // Move cursor to home position
  }

  /// Exits the "alternate" fullscreen buffer and returns to the normal screen.
  ///
  /// Throws [UnsupportedError] if a terminal is not detected.
  /// Uses the ANSI escape sequence `\x1B[?1049l`.
  static void exitFullScreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }
    stdout.write('\x1B[?1049l'); // Disable alternate screen buffer
  }
}
