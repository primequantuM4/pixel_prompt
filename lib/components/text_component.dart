import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

class TextComponent extends Component {
  final String text;
  final TextComponentStyle? style;
  const TextComponent(this.text, {this.style});
  @override
  ComponentInstance createInstance() =>
      _TextComponentInstance(text, style: style ?? TextComponentStyle());
}

class _TextComponentInstance extends ComponentInstance {
  final String text;
  final TextComponentStyle style;

  _TextComponentInstance(this.text, {required this.style});

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
    int y = bounds.y + style.padding.top + style.margin.top;

    for (var line in lines) {
      int x = bounds.x + style.padding.left + style.margin.left;

      for (int i = 0; i < style.padding.left; i++) {
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

      for (int i = 0; i < style.padding.right; i++) {
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
    final leftX = bounds.x + style.margin.left;

    for (int i = 0; i < style.padding.top; i++) {
      buffer.drawAt(
        leftX,
        bounds.y + style.margin.top + i,
        ' ' * totalWidth,
        style,
      );
    }

    for (int i = 0; i < style.padding.bottom; i++) {
      buffer.drawAt(leftX, y + i, ' ' * totalWidth, style);
    }
  }

  @override
  int fitHeight() {
    final totalLines = text.split('\n').length;
    return style.verticalMargin + style.verticalPadding + totalLines;
  }

  @override
  int fitWidth() {
    return style.horizontalPadding + style.horizontalMargin + text.length;
  }
}
