import 'dart:io';

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
class CanvasBuffer {
  /// The width of the canvas in characters.
  int width;

  /// The height of the canvas in characters.
  int height;

  /// The original horizontal cursor offset in the terminal.
  int cursorOriginalX = -1;

  /// The original vertical cursor offset in the terminal.
  int cursorOriginalY = -1;

  static const String _tag = 'CanvasBuffer';

  /// Whether the buffer is in fullscreen mode.
  ///
  /// If true, cursor calculations reset to 1,1.
  bool isFullscreen = false;

  /// Internal 2D grid storing the screen cells.
  List<List<BufferCell>> _screenBuffer;

  /// Creates a [CanvasBuffer] with the specified [width] and [height].
  ///
  /// Initializes the internal buffer with empty spaces.
  CanvasBuffer({required this.width, required this.height})
      : _screenBuffer = List.generate(
          height,
          (_) => List.filled(width, BufferCell(char: ' ')),
        );

  /// Sets the original terminal cursor offset for relative rendering.
  ///
  /// Typically set to the terminal’s current cursor position before rendering.
  setTerminalOffset(int x, int y) {
    cursorOriginalX = x;
    cursorOriginalY = y;
  }

  (int, int) getTerminalOffset() {
    return (cursorOriginalX, cursorOriginalY);
  }

  void updateDimensions(int width, int height) {
    this.width = width;
    this.height = height;

    _screenBuffer = List.generate(
      height,
      (_) => List.filled(
        width,
        BufferCell(char: ' '),
      ),
    );
  }

  /// Draws a single character at position ([x], [y]) with optional style.
  ///
  /// If the character is whitespace, the style is cleared.
  /// Ignores drawing if coordinates are out of bounds.
  void drawChar(
    int x,
    int y,
    String char, {
    AnsiColorType? fg,
    AnsiColorType? bg,
    Set<FontStyle>? styles,
  }) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      final Set<FontStyle> effectiveStyle =
          (char.trim().isEmpty) ? {} : (styles ?? {});
      _screenBuffer[y][x] = BufferCell(
        char: char,
        fg: fg,
        bg: bg,
        styles: effectiveStyle,
      );
    }
  }

  /// Draws a string [data] starting at position ([x], [y]) with a given [style].
  ///
  /// Each character in [data] is drawn sequentially on the same row.
  void drawAt(int x, int y, String data, TextComponentStyle style) {
    for (int i = 0; i < data.length; i++) {
      drawChar(
        x + i,
        y,
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
        stdout.write(' ');
      }
    }
  }

  /// Clears a rectangular [area] within the buffer.
  ///
  /// All cells within [area] are reset to spaces with no style.
  void clearBufferArea(Rect area) {
    for (int y = area.y; y < area.y + area.height; y++) {
      if (y >= _screenBuffer.length) break;
      for (int x = area.x; x < area.x + area.width; x++) {
        if (x >= _screenBuffer[0].length) break;
        _screenBuffer[y][x].clear();
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
    for (int y = area.y; y < area.y + area.height; y++) {
      if (y >= _screenBuffer.length) break;

      if (cursorOriginalX != -1 && cursorOriginalY != -1) {
        final cursorY = isFullscreen ? y + 1 : cursorOriginalY + y;
        final cursorX = isFullscreen ? 1 : cursorOriginalX;

        String cursorMove = '\x1B[$cursorY;${cursorX}H';
        stdout.write(cursorMove);
      }

      for (int x = area.x; x < area.x + area.width; x++) {
        if (x >= _screenBuffer[0].length) break;
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
    final renderY = isFullscreen ? 1 : cursorOriginalY;
    final renderX = isFullscreen ? 1 : cursorOriginalX;

    if (renderX != -1 && renderX != -1) {
      stdout.write('\x1B[$renderY;${renderX}H');
    }

    final buffer = StringBuffer();

    for (int y = 0; y < _screenBuffer.length; y++) {
      final row = _screenBuffer[y];
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
      buffer.write('\n');
    }
    stdout.write(buffer.toString());

    Logger.trace(_tag, 'RENDERED');
  }

  /// Moves the terminal cursor to position ([x], [y]) relative to the original offset.
  ///
  /// Ignores the call if coordinates are -1.
  void moveCursorTo(int x, int y) {
    if (x == -1 || y == -1) return;
    final int renderX = isFullscreen ? 1 : cursorOriginalX;
    final int renderY = isFullscreen ? 1 : cursorOriginalY;

    String cursorPosition = '\x1B[${renderY + y};${renderX + x}H';
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
