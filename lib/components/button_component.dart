import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/renderer/border_renderer.dart';

class ButtonComponent extends Component {
  final String label;
  final AnsiColorType buttonColor;
  final AnsiColorType outerBorderColor;
  final AnsiColorType textColor;
  final BorderStyle borderStyle;
  final EdgeInsets padding;

  final void Function() onPressed;

  const ButtonComponent({
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 3),
    this.buttonColor = const ColorRGB(0, 0, 0),
    this.outerBorderColor = const ColorRGB(50, 50, 50),
    this.textColor = const ColorRGB(255, 255, 255),
    this.borderStyle = BorderStyle.empty,
  }) : super(padding: padding);

  @override
  ComponentInstance createInstance() => _ButtonComponentInstance(this);
}

class _ButtonComponentInstance extends InteractableComponentInstance {
  final ButtonComponent component;

  final BorderRenderer _borderRenderer;
  late TextComponentStyle _undimmedButtonStyle;
  late TextComponentStyle _dimmedButtonStyle;

  static const int _borderHeight = 2;
  static const int _borderWidth = 2;

  _ButtonComponentInstance(this.component)
    : _borderRenderer = BorderRenderer(
        style: component.borderStyle,
        borderColor: component.buttonColor,
      ),
      super(padding: component.padding) {
    _undimmedButtonStyle = TextComponentStyle()
        .foreground(component.textColor)
        .background(component.buttonColor);

    _dimmedButtonStyle = TextComponentStyle()
        .foreground(component.textColor.dimmed())
        .background(component.buttonColor.dimmed());
  }

  @override
  bool get isFocusable => true;

  @override
  bool get isHoverable => true;

  @override
  bool get wantsInput => true;

  @override
  int fitHeight() {
    final lines = component.label.split('\n');

    return lines.length + _borderHeight + padding.top + padding.bottom;
  }

  @override
  int fitWidth() {
    final lines = component.label.split('\n');

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
      component.onPressed.call();
      onBlur();
      return ResponseInput(
        handled: true,
        commands: ResponseCommands.none,
        dirty: [this],
      );
    }
    return ResponseInput.ignored();
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    if (isHovered || isFocused) {
      _borderRenderer.borderColor = component.outerBorderColor.dimmed();
    } else {
      _borderRenderer.borderColor = component.outerBorderColor;
    }
    _borderRenderer.draw(buffer, bounds, (buffer, innerBounds) {
      Logger.trace("ButtonComponent", bounds.toString());
      Logger.trace("ButtonComponent", innerBounds.toString());
      drawButtonContent(buffer, innerBounds);
    });
  }

  void drawButtonContent(CanvasBuffer buffer, Rect bounds) {
    final lines = component.label.split('\n');
    final contentStyle = isHovered || isFocused
        ? _dimmedButtonStyle
        : _undimmedButtonStyle;

    final contentWidth = lines.fold(
      0,
      (max, line) => line.length > max ? line.length : max,
    );

    final totalHeight = lines.length + padding.top + padding.bottom;

    int y = bounds.y;

    for (int row = 0; row < totalHeight; row++) {
      final isContentRow =
          row >= padding.top && row < totalHeight - padding.bottom;
      final contentLine = isContentRow ? lines[row - padding.top] : '';

      final paddedLine =
          ' ' * padding.left +
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
    isFocused = false;
    isHovered = false;
    component.onPressed.call();
  }

  @override
  void onFocus() {}

  @override
  void onHover() {}
}
