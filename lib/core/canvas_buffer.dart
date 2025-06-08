import 'dart:io';

import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/font_style.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/buffer_cell.dart';
import 'package:pixel_prompt/core/rect.dart';

class CanvasBuffer {
  final int width;
  final int height;

  int cursorOriginalX = -1;
  int cursorOriginalY = -1;

  bool isFullscreen = false;
  final List<List<BufferCell>> _screenBuffer;

  CanvasBuffer({required this.width, required this.height})
    : _screenBuffer = List.generate(
        height,
        (_) => List.filled(width, BufferCell(char: ' ')),
      );

  setTerminalOffset(int x, int y) {
    cursorOriginalX = x;
    cursorOriginalY = y;
  }

  void drawChar(
    int x,
    int y,
    String char, {
    AnsiColorType? fg,
    AnsiColorType? bg,
    Set<FontStyle>? styles,
  }) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      final Set<FontStyle> effectiveStyle = (char.trim().isEmpty)
          ? {}
          : (styles ?? {});
      _screenBuffer[y][x] = BufferCell(
        char: char,
        fg: fg,
        bg: bg,
        styles: effectiveStyle,
      );
    }
  }

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

  void clear() {
    for (var row in _screenBuffer) {
      for (final cell in row) {
        cell.clear();
      }
    }

    stdout.write('\x1B[2J');
    stdout.write('\x1B[H');
  }

  void clearBufferArea(Rect area) {
    for (int y = area.y; y < area.y + area.height; y++) {
      if (y >= _screenBuffer.length) break;
      for (int x = area.x; x < area.x + area.width; x++) {
        if (x >= _screenBuffer[0].length) break;
        _screenBuffer[y][x].clear();
      }
    }
  }

  void flushArea(Rect area) {
    /*
          \x1B[2J -> clears entire screen 
          \x1B[k -> clear from cursor to end of line
          \x1B[1k -> clear from beginning to cursor
          \x1B[2k -> clear entire line
          \x1B[n;mH or \x1B[n;mf -> move cursor to row n, col m
    */
    final int renderX = isFullscreen ? 1 : cursorOriginalX;
    final int renderY = isFullscreen ? 1 : cursorOriginalY;

    String cursorPosition = '\x1B[$renderY;${renderX}H';
    stdout.write(cursorPosition);
    for (int y = area.y; y < area.y + area.height; y++) {
      if (y > _screenBuffer.length) break;
      for (int x = area.x; x < area.x + area.width; x++) {
        if (x > _screenBuffer[0].length) break;

        stdout.write(' ');
      }
    }
  }

  void render() {
    final renderY = isFullscreen ? 1 : cursorOriginalY;
    final renderX = isFullscreen ? 1 : cursorOriginalX;

    stdout.write('\x1B[$renderY;${renderX}H');
    for (int y = 0; y < _screenBuffer.length; y++) {
      final row = _screenBuffer[y];
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
      buffer.write('\n');
      stdout.write(buffer.toString());
    }
  }

  bool _sameStyle(BufferCell cell, BufferCell lastCell) {
    return cell.fg == lastCell.fg &&
        cell.bg == lastCell.bg &&
        _sameSet(cell.styles, lastCell.styles);
  }

  bool _sameSet(Set<FontStyle> a, Set<FontStyle> b) {
    if (a.length != b.length) return false;
    for (final style in a) {
      if (!b.contains(style)) return false;
    }
    return true;
  }

  String _ansiCode(BufferCell cell) {
    final style = TextComponentStyle();
    style.color = cell.fg;
    style.bgColor = cell.bg;
    style.styles = cell.styles;

    final String ansiCode = style.getStyleAnsi();
    if (ansiCode.isEmpty) return 'm';
    return ';${ansiCode}m';
  }

  // ========== FOR TESTING PURPOSES ==========

  List<List<BufferCell>> getDrawnCanvas() {
    return _screenBuffer;
  }

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
