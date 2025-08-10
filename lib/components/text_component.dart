import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

/// A UI component that displays styled text in a terminal or canvas-based layout.
///
/// A [TextComponent] renders a string of text with optional styling such as
/// colors, font attributes, and padding/margin (via [TextComponentStyle]).
///
/// The text is rendered exactly as provided, with line breaks respected.
/// Spacing is determined by the configured padding and margin values.
///
/// ### Example
/// ```dart
/// final component = TextComponent(
///   "Hello, World!",
///   style: TextComponentStyle(
///     color: AnsiColorType.green,
///     styles: {FontStyle.bold},
///     padding: EdgeInsets.symmetric(horizontal: 1),
///   ),
/// );
/// ```
///
/// ### See Also
/// - [TextComponentStyle] for defining style attributes.
/// - [CanvasBuffer] for low-level drawing.
/// - [Component] for the base UI element contract.
///
/// {@category Components}
class TextComponent extends Component {
  /// The text content to display.
  final String text;

  /// The style applied to the text.
  ///
  /// If null, defaults to a new [TextComponentStyle] with no styling.
  final TextComponentStyle? style;

  /// Creates a [TextComponent] with the given [text] and optional [style].
  const TextComponent(this.text, {this.style});

  @override
  ComponentInstance createInstance() =>
      _TextComponentInstance(text, style: style ?? TextComponentStyle());
}

/// Internal rendering instance for [TextComponent].
///
/// Handles measurement, rendering, and size fitting based on text content
/// and the associated [TextComponentStyle].
///
/// {@category Components}
class _TextComponentInstance extends ComponentInstance {
  /// The text content to display.
  final String text;

  /// The styling information for the text.
  final TextComponentStyle style;

  _TextComponentInstance(this.text, {required this.style});

  @override
  Size measure(Size maxSize) {
    // Split text into lines and calculate max width.
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

      // Draw left padding spaces.
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

      // Draw the actual text line.
      buffer.drawAt(x, y, line, style);

      // Draw right padding spaces.
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

    // Calculate total rendered width (excluding margins).
    final totalWidth =
        lines.fold(0, (max, line) => line.length > max ? line.length : max) +
        style.horizontalPadding;
    final leftX = bounds.x + style.margin.left;

    // Draw top padding area.
    for (int i = 0; i < style.padding.top; i++) {
      buffer.drawAt(
        leftX,
        bounds.y + style.margin.top + i,
        ' ' * totalWidth,
        style,
      );
    }

    // Draw bottom padding area.
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
