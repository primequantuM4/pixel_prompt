import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/renderer/border_renderer.dart';

class ButtonComponent extends InteractableComponent {
  final String label;
  AnsiColorType buttonColor;
  AnsiColorType textColor;
  final void Function() onPressed;
  final EdgeInsets padding;

  static const int _borderWidth = 2;
  static const int _borderHeight = 2;

  final BorderRenderer _borderRenderer;
  late TextComponentStyle _undimmedButtonStyle;
  late TextComponentStyle _dimmedButtonStyle;

  ButtonComponent({
    required this.label,
    AnsiColorType? buttonColor,
    AnsiColorType? textColor,
    required this.onPressed,
    BorderStyle? borderStyle,
    EdgeInsets? padding,
  })  : padding = padding ?? EdgeInsets.symmetric(horizontal: 3),
        buttonColor = buttonColor ?? ColorRGB(0, 0, 0),
        textColor = textColor ?? ColorRGB(255, 255, 255),
        _borderRenderer = BorderRenderer(
          style: borderStyle ?? BorderStyle.empty,
          borderColor: buttonColor ?? ColorRGB(0, 0, 0),
        ) {
    _undimmedButtonStyle = TextComponentStyle()
        .foreground(this.textColor)
        .background(this.buttonColor);
    if (buttonColor is ColorRGB) {
      _dimmedButtonStyle =
          TextComponentStyle().background((buttonColor).dimmed());
    } else {
      _dimmedButtonStyle =
          TextComponentStyle().background((buttonColor ?? Colors.black)).dim();
    }

    if (textColor is ColorRGB) {
      _dimmedButtonStyle.foreground((textColor).dimmed());
    } else {
      _dimmedButtonStyle.foreground(textColor ?? Colors.white).dim();
    }
  }

  @override
  bool get isFocusable => true;

  @override
  bool get isHoverable => true;

  @override
  bool get wantsInput => true;

  @override
  int fitHeight() {
    final lines = label.split('\n');

    return lines.length + _borderHeight + padding.top + padding.bottom;
  }

  @override
  int fitWidth() {
    final lines = label.split('\n');

    final contentWidth = lines.fold(
      0,
      (max, line) => line.length > max ? line.length : max,
    );
    return contentWidth + _borderWidth + padding.right + padding.left;
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent) return ResponseInput.ignored();

    if (event.code == KeyCode.enter ||
        (event.char == ' ')) {
      Logger.trace("ButtonComponent", "Triggering On Pressed");
      onPressed.call();
      onBlur();
      return ResponseInput(
          handled: true, commands: ResponseCommands.none, dirty: [this]);
    }
    return ResponseInput.ignored();
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    AnsiColorType color = ColorRGB(50, 50, 50);
    if (isHovered || isFocused) {
      if (buttonColor is ColorRGB) {
        _borderRenderer.borderColor = (color as ColorRGB).dimmed();
      } else {
        _borderRenderer.isDimmed = true;
      }
    } else {
      _borderRenderer.borderColor = color;
    }
    _borderRenderer.draw(buffer, bounds, (buffer, innerBounds) {
      Logger.trace("ButtonComponent", bounds.toString());
      Logger.trace("ButtonComponent", innerBounds.toString());
      drawButtonContent(buffer, innerBounds);
    });
  }

  void drawButtonContent(CanvasBuffer buffer, Rect bounds) {
    final lines = label.split('\n');
    final contentStyle =
        isHovered || isFocused ? _dimmedButtonStyle : _undimmedButtonStyle;

    final contentWidth =
        lines.fold(0, (max, line) => line.length > max ? line.length : max);

    final totalHeight = lines.length + padding.top + padding.bottom;

    int y = bounds.y;

    for (int row = 0; row < totalHeight; row++) {
      final isContentRow =
          row >= padding.top && row < totalHeight - padding.bottom;
      final contentLine = isContentRow ? lines[row - padding.top] : '';

      final paddedLine = ' ' * padding.left +
          contentLine.padRight(contentWidth) +
          ' ' * padding.right;

      buffer.drawAt(bounds.x, y + row, paddedLine, contentStyle);
    }
  }

  @override
  void onBlur() {
    isFocused = false;
    isHovered = false;
  }

  @override
  void onClick() {
    onPressed.call();
    isFocused = false;
    isHovered = false;
    markDirty();
  }

  @override
  void onFocus() {}

  @override
  void onHover() {}
}
