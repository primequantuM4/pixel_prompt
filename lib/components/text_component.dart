import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

class TextComponent extends Component {
  final String text;
  final TextComponentStyle style;

  TextComponent(this.text, {required this.style, super.position});

  @override
  Size measure(Size maxSize) {
    final lines = text.split('\n');
    final contentWidth = lines.fold(
      0,
      (max, line) => line.length > max ? line.length : max,
    );
    final contentHeight = lines.length;
    return Size(
      width: contentWidth + style.horizontalPadding + style.horizontalMargin,
      height: contentHeight + style.verticalPadding + style.verticalMargin,
    );
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final lines = text.split('\n');
    int y = bounds.y + style.topPadding + style.topMargin;

    for (var line in lines) {
      int x = bounds.x + style.leftMargin + style.leftPadding;

      for (int i = 0; i < style.leftPadding; i++) {
        buffer.drawChar(
          x - i - 1,
          y,
          ' ',
          fg: style.color,
          bg: style.bgColor,
          styles: style.styles,
        );
      }

      buffer.drawAt(x, y, line, style);

      for (int i = 0; i < style.rightPadding; i++) {
        buffer.drawChar(
          x + line.length + i,
          y,
          ' ',
          fg: style.color,
          bg: style.bgColor,
        );
      }
      y += 1;
    }

    final totalWidth =
        lines.fold(0, (max, line) => line.length > max ? line.length : max) +
        style.horizontalPadding;
    final leftX = bounds.x + style.leftMargin;

    for (int i = 0; i < style.topPadding; i++) {
      buffer.drawAt(
        leftX,
        bounds.y + style.topMargin + i,
        ' ' * totalWidth,
        style,
      );
    }

    for (int i = 0; i < style.bottomPadding; i++) {
      buffer.drawAt(leftX, y + i, ' ' * totalWidth, style);
    }
  }

  @override
  int fitHeight() {
    final totalLines = text.split('\n').length;
    return style.topPadding + style.bottomPadding + totalLines;
  }

  @override
  int fitWidth() {
    return style.leftPadding + style.rightPadding + text.length;
  }
}
