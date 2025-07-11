import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class BorderRenderer {
  final BorderStyle style;
  AnsiColorType? borderColor;
  bool isDimmed = false;

  BorderRenderer({required this.style, this.borderColor});

  void draw(CanvasBuffer buffer, Rect bounds,
      void Function(CanvasBuffer buffer, Rect bounds) drawChild) {
    final x = bounds.x;
    final y = bounds.y;
    final width = bounds.width;
    final height = bounds.height;
    TextComponentStyle borderStyle;

    borderStyle = TextComponentStyle();

    if (isDimmed) {
      borderStyle = borderStyle.dim();
    }

    if (borderColor != null) {
      borderStyle = borderStyle.foreground(borderColor!);
      if (style == BorderStyle.empty) {
        borderStyle = borderStyle.background(borderColor!);
      }
    }

    // Top border
    buffer.drawAt(x, y, style.topLeft, borderStyle);
    buffer.drawAt(bounds.right - 1, y, style.topRight, borderStyle);
    for (int i = 1; i < width - 1; i++) {
      buffer.drawAt(x + i, y, style.horizontal, borderStyle);
    }

    // Bottom border
    buffer.drawAt(x, bounds.bottom - 1, style.bottomLeft, borderStyle);
    buffer.drawAt(
      bounds.right - 1,
      bounds.bottom - 1,
      style.bottomRight,
      borderStyle,
    );
    for (int i = 1; i < width - 1; i++) {
      buffer.drawAt(x + i, bounds.bottom - 1, style.horizontal, borderStyle);
    }

    // Side border
    for (int i = 1; i < height - 1; i++) {
      buffer.drawAt(x, y + i, style.vertical, borderStyle);
      buffer.drawAt(bounds.right - 1, y + i, style.vertical, borderStyle);
    }

    final Rect innerBounds = Rect(
      x: x + 1,
      y: y + 1,
      width: width - 2,
      height: height - 2,
    );

    drawChild(buffer, innerBounds);
  }
}
