import 'dart:io';
import 'dart:math';

import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/font_style.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/buffer_cell.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/logger/logger.dart';

/// A terminal canvas buffer managing character cells and their styles.
///
/// [CanvasBuffer] maintains an internal 2D grid of [BufferCell]s representing
/// the terminal screen content, including characters, foreground and background
/// colors, and font styles.
///
/// It supports drawing characters and strings at arbitrary positions,
/// clearing areas or the entire buffer, and flushing changes to the
/// terminal with proper ANSI escape codes.
///
/// The buffer tracks an original terminal cursor offset, supports fullscreen mode,
/// and manages cursor visibility for clean rendering.
///
/// Typical usage:
/// 1. Construct with terminal width and height.
/// 2. Use [drawChar] or [drawAt] to update cells.
/// 3. Call [render] to flush changes to the terminal.
/// 4. Use [clear] or [clearBufferArea] to reset contents.
/// {@category Core}
/// {@category Rendering}
class CanvasBuffer {
  /// The width of the canvas in characters.
  int width;

  /// The height of the canvas in characters.
  int height;

  /// The original horizontal cursor column in the terminal (1-based).
  /// Columns increase from left to right.
  int cursorOriginalColumn = 1;

  /// The original vertical cursor line in the terminal (1-based).
  /// Lines increase from top to bottom.
  int cursorOriginalLine = 1;

  static const String _tag = 'CanvasBuffer';

  /// Whether the buffer is in fullscreen mode.
  ///
  /// If true, cursor calculations reset to 1,1.
  bool isFullscreen = false;

  /// Internal 2D grid storing the screen cells.
  List<List<BufferCell>> _screenBuffer;

  /// Internal previous 2D grid for storing and comparing with current screen cells.
  List<List<BufferCell>> _previousFrame;

  /// Creates a [CanvasBuffer] with the specified [width] and [height].
  ///
  /// Initializes the internal buffer with empty spaces.
  CanvasBuffer({required this.width, required this.height})
    : _screenBuffer = List.generate(
        height,
        (_) => List.filled(width, BufferCell(char: ' ')),
      ),
      _previousFrame = List.generate(
        height,
        (_) => List.filled(width, BufferCell(char: '')),
      );

  /// Sets the original terminal cursor offset for relative rendering.
  ///
  /// Typically set to the terminal’s current cursor position before rendering.
  setTerminalOffset(int column, int line) {
    cursorOriginalColumn = column;
    cursorOriginalLine = line;
  }

  (int, int) getTerminalOffset() {
    return (cursorOriginalColumn, cursorOriginalLine);
  }

  void updateDimensions(int width, int height) {
    if (this.width == width && this.height == height) return;

    this.width = max(width, this.width);
    this.height = max(height, this.height);

    _screenBuffer = List.generate(
      this.height,
      (_) => List.filled(this.width, BufferCell(char: ' ')),
    );

    _previousFrame = List.generate(
      this.height,
      (_) => List.filled(this.width, BufferCell(char: '')),
    );
  }

  /// Draws a single character at position ([column], [line]) with optional style.
  ///
  /// If the character is whitespace, the style is cleared.
  /// Ignores drawing if coordinates are out of bounds.
  void drawChar(
    int column,
    int line,
    String char, {
    AnsiColorType? fg,
    AnsiColorType? bg,
    Set<FontStyle>? styles,
  }) {
    if (column >= 0 && column < width && line >= 0 && line < height) {
      final Set<FontStyle> effectiveStyle = (char.trim().isEmpty)
          ? {}
          : (styles ?? {});
      _screenBuffer[line][column] = BufferCell(
        char: char,
        fg: fg,
        bg: bg,
        styles: effectiveStyle,
      );
    }
  }

  /// Draws a string [data] starting at position ([column], [line]) with a given [style].
  ///
  /// Each character in [data] is drawn sequentially on the same row.
  void drawAt(int column, int line, String data, TextComponentStyle style) {
    for (int i = 0; i < data.length; i++) {
      drawChar(
        column + i,
        line,
        data[i],
        fg: style.color,
        bg: style.bgColor,
        styles: style.styles,
      );
    }
  }

  /// Clears the entire canvas buffer, resetting all cells to spaces with no style.
  ///
  /// Also sends ANSI escape sequences to clear the terminal screen and reset cursor.
  void clear() {
    for (var row in _screenBuffer) {
      for (final cell in row) {
        cell.clear();
      }
    }
  }

  /// Clears a rectangular [area] within the buffer.
  ///
  /// All cells within [area] are reset to spaces with no style.
  void clearBufferArea(Rect area) {
    for (int line = area.y; line < area.y + area.height; line++) {
      if (line >= _screenBuffer.length) break;
      for (int column = area.x; column < area.x + area.width; column++) {
        if (column >= _screenBuffer[0].length) break;
        _screenBuffer[line][column].clear();
      }
    }
  }

  /// Flushes the contents of a rectangular [area] to the terminal.
  ///
  /// This writes spaces over the specified area at the current cursor position,
  /// using ANSI escape codes for cursor positioning.
  ///
  /// Note: This implementation currently clears the area visually without
  /// redrawing the buffer content.
  void flushArea(Rect area) {
    for (int line = area.y; line < area.y + area.height; line++) {
      if (line >= _screenBuffer.length) break;

      if (cursorOriginalColumn != -1 && cursorOriginalLine != -1) {
        final cursorLine = isFullscreen ? line + 1 : cursorOriginalLine + line;
        final cursorColumn = isFullscreen ? 1 : cursorOriginalColumn;

        String cursorMove = '\x1B[$cursorLine;${cursorColumn}H';
        stdout.write(cursorMove);
      }

      for (int column = area.x; column < area.x + area.width; column++) {
        if (column >= _screenBuffer[0].length) break;
        stdout.write(' ');
      }
    }
  }

  /* void printComponentTree(Component comp, [int level = 0]) {
    print(
        '${' ' * level * 2}${comp.runtimeType} ${comp is TextComponent ? comp.text : comp is ButtonComponent ? comp.label : ''}');
    if (comp is ParentComponent) {
      for (var child in comp.children) {
        printComponentTree(child, level + 1);
      }
    }
  } */

  /// Renders the entire buffer content to the terminal.
  ///
  /// Applies ANSI escape codes to set colors and styles per cell,
  /// optimizes by grouping cells with identical styles, and manages cursor visibility.
  void render() {
    hideCursor();
    final buffer = StringBuffer();

    final baseLine = isFullscreen ? 1 : cursorOriginalLine;
    final baseColumn = isFullscreen ? 1 : cursorOriginalColumn;

    int? lastColumnPos, lastLinePos;

    for (int line = 0; line < _screenBuffer.length; line++) {
      BufferCell? lastCell;
      for (int column = 0; column < _screenBuffer[line].length; column++) {
        final curr = _screenBuffer[line][column];
        final prev = _previousFrame[line][column];

        if (_cellEquals(curr, prev)) continue;

        final cursorLine = baseLine + line;
        final cursorColumn = baseColumn + column;
        final shouldCursorMove =
            (cursorLine != lastLinePos) ||
            (cursorColumn != (lastColumnPos ?? -1));
        if (shouldCursorMove) {
          buffer.write('\x1B[$cursorLine;${cursorColumn}H');
          lastLinePos = cursorLine;
          lastColumnPos = cursorColumn;
        }

        if (lastCell == null || !_sameStyle(curr, lastCell)) {
          buffer.write('\x1B[0');
          buffer.write(_ansiCode(curr));
          lastCell = curr;
        }
        buffer.write(curr.char);

        _previousFrame[line][column] = curr.copy();
        lastColumnPos = (lastColumnPos ?? 1) + 1;
      }
    }

    buffer.write('\x1B[0m');
    stdout.write(buffer.toString());
    Logger.trace(_tag, 'RENDERED');
  }

  /// Moves the terminal cursor to position ([column], [line]) relative to the original offset.
  ///
  /// Ignores the call if coordinates are -1.
  void moveCursorTo(int column, int line) {
    if (column == -1 || line == -1) return;
    final int renderColumn = isFullscreen ? 1 : cursorOriginalColumn;
    final int renderLine = isFullscreen ? 1 : cursorOriginalLine;

    String cursorPosition =
        '\x1B[${renderLine + line};${renderColumn + column}H';
    stdout.write(cursorPosition);
  }

  /// Hides the terminal cursor using ANSI escape codes.
  void hideCursor() {
    stdout.write('\x1B[?25l');
  }

  /// Shows the terminal cursor using ANSI escape codes.
  void showCursor() {
    stdout.write('\x1B[?25h');
  }

  /// Checks if two [BufferCell]s have the same style attributes.
  ///
  /// Style equality includes foreground, background, and font styles.
  bool _sameStyle(BufferCell cell, BufferCell lastCell) {
    return cell.fg == lastCell.fg &&
        cell.bg == lastCell.bg &&
        _sameSet(cell.styles, lastCell.styles);
  }

  /// Checks if two sets of [FontStyle] are equal, ignoring order.
  bool _sameSet(Set<FontStyle> a, Set<FontStyle> b) {
    if (a.length != b.length) return false;
    for (final style in a) {
      if (!b.contains(style)) return false;
    }
    return true;
  }

  /// Builds ANSI escape code sequence for the given [BufferCell]'s styles.
  String _ansiCode(BufferCell cell) {
    final style = TextComponentStyle(
      color: cell.fg,
      bgColor: cell.bg,
      styles: cell.styles,
    );

    final String ansiCode = style.getStyleAnsi();
    if (ansiCode.isEmpty) return 'm';
    return ';${ansiCode}m';
  }

  bool _cellEquals(BufferCell currentCell, BufferCell previousCell) =>
      currentCell == previousCell;

  // ========== FOR TESTING PURPOSES ==========

  /// Returns the internal buffer grid for test inspection.
  List<List<BufferCell>> getDrawnCanvas() {
    return _screenBuffer;
  }

  /// Returns a list of strings representing the ANSI-encoded rendered output,
  /// one string per row.
  List<String> getRenderedString() {
    List<String> renderedString = [];

    for (var row in _screenBuffer) {
      final buffer = StringBuffer();
      BufferCell? lastCell;

      for (final cell in row) {
        if (lastCell == null || !_sameStyle(cell, lastCell)) {
          buffer.write('\x1B[0');
          buffer.write(_ansiCode(cell));
          lastCell = cell;
        }
        buffer.write(cell.char);
      }

      buffer.write('\x1B[0m');
      renderedString.add(buffer.toString());
    }
    return renderedString;
  }
}
