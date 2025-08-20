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

/// A clickable button component that can be rendered within a terminal-based UI.
///
/// The [ButtonComponent] is an interactive widget that displays a label inside
/// a styled border with customizable colors and padding. It responds to focus,
/// hover, and click events, triggering an action through [onPressed].
///
/// This component supports multiline labels and adapts its size based on the
/// longest line and provided padding.
///
/// ### Features
/// - Customizable background, text, and border colors.
/// - Optional border styles via [BorderStyle].
/// - Responds to hover, focus, and click events.
/// - Supports keyboard activation (`Enter` or `Space`).
///
/// ### Example
/// ```dart
/// final button = ButtonComponent(
///   label: 'Submit',
///   onPressed: () {
///     print('Button pressed!');
///   },
///   buttonColor: const ColorRGB(0, 0, 255),
///   textColor: const ColorRGB(255, 255, 255),
///   outerBorderColor: const ColorRGB(100, 100, 255),
///   borderStyle: BorderStyle.thin,
/// );
/// ```
///
/// ### See also
/// - [TextFieldComponent], for capturing text input.
/// - [BorderStyle], for customizing button borders.
/// - [TextComponentStyle], for styling button labels.
///
/// {@category Components}
/// {@category InteractableComponents}
class ButtonComponent extends Component {
  /// The text label displayed inside the button.
  final String label;

  /// The background color of the button face.
  final AnsiColorType buttonColor;

  /// The color of the outer border surrounding the button.
  final AnsiColorType outerBorderColor;

  /// The color of the text label.
  final AnsiColorType textColor;

  /// The border style applied to the button (e.g., none, single, double).
  final BorderStyle borderStyle;

  /// The callback invoked when the button is pressed.
  final void Function() onPressed;

  /// Creates a new [ButtonComponent] with the given [label] and [onPressed] callback.
  ///
  /// The appearance can be customized through optional parameters such as
  /// [buttonColor], [textColor], [outerBorderColor], [borderStyle], and [padding].
  const ButtonComponent({
    required this.label,
    required this.onPressed,
    this.buttonColor = const ColorRGB(0, 0, 0),
    this.outerBorderColor = const ColorRGB(50, 50, 50),
    this.textColor = const ColorRGB(255, 255, 255),
    this.borderStyle = BorderStyle.empty,
    super.padding = const EdgeInsets.symmetric(horizontal: 3),
  });

  @override
  ComponentInstance createInstance() => _ButtonComponentInstance(this);
}

/// Internal instance for rendering and managing [ButtonComponent] state.
///
/// This instance handles hover, focus, and click behavior,
/// and renders the button content with the appropriate styles.
///
/// It also processes input events such as `Enter` or `Space`
/// to trigger the [ButtonComponent.onPressed] callback.
/// **Note:** This is not meant to be used directly. Instead, construct
/// a [ButtonComponent] and let the framework manage its instance.
///
/// {@category Components}
/// {@category InteractableComponents}
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

    if (event.code == KeyCode.enter || (event.char == ' ')) {
      Logger.trace("ButtonComponent", "Triggering On Pressed");
      component.onPressed.call();
      return ResponseInput(
        handled: true,
        commands: ResponseCommands.none,
        dirty: [this],
      );
    }
    return ResponseInput.ignored();
  }

  @override
  Size measure(Size maxSize) => Size(width: fitWidth(), height: fitHeight());

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

  /// Draws the text label and applies padding inside the button.
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

    for (int row = 0; row < totalHeight; row++) {
      final isContentRow =
          row >= padding.top && row < totalHeight - padding.bottom;
      final contentLine = isContentRow ? lines[row - padding.top] : '';
      final paddedLine =
          ' ' * padding.left +
          contentLine.padRight(contentWidth) +
          ' ' * padding.right;
      buffer.drawAt(bounds.x, bounds.y + row, paddedLine, contentStyle);
    }
  }

  @override
  void onBlur() {
    isFocused = false;
    isHovered = false;
  }

  @override
  void onClick() {
    component.onPressed.call();
  }

  @override
  void onFocus() {}

  @override
  void onHover() {}
}
