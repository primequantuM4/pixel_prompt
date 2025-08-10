import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/rect.dart';

/// A utility class responsible for rendering borders around rectangular areas
/// in the terminal UI using a specified [BorderStyle] and optional color.
///
/// The border is drawn on a [CanvasBuffer], and the inner content is rendered
/// via a provided callback function, which receives the reduced inner bounds.
///
/// This class abstracts the drawing of consistent, styled borders, supporting
/// custom border characters and coloring.
///
/// ### Example
/// ```dart
/// final borderRenderer = BorderRenderer(
///   style: BorderStyle.rounded,
///   borderColor: AnsiColorType.blue,
/// );
///
/// borderRenderer.draw(buffer, Rect(x: 0, y: 0, width: 10, height: 5), (buf, innerBounds) {
///   // Draw child content inside the border
///   buf.drawAt(innerBounds.x, innerBounds.y, 'Content inside border');
/// });
/// ```
///
/// ### See Also
/// - [BorderStyle]: Defines the characters used to draw the border.
/// - [CanvasBuffer]: The canvas on which the border and contents are drawn.
/// - [AnsiColorType]: Used for coloring the border.
///
/// This class is commonly used in terminal UI components that need
/// framed or boxed layouts.
/// {@category Rendering}
/// {@category Component}
/// {@category Border}
class BorderRenderer {
  /// The style of the border to render (characters for corners, sides, etc.).
  final BorderStyle style;

  /// Optional ANSI color to apply to the border characters.
  ///
  /// If the [style] is [BorderStyle.empty], the color is applied as a background.
  AnsiColorType? borderColor;

  /// Creates a [BorderRenderer] with the given [style] and optional [borderColor].
  BorderRenderer({required this.style, this.borderColor});

  /// Draws the border on the provided [buffer] within the given [bounds].
  ///
  /// Calls [drawChild] to render the content inside the border with
  /// adjusted inner bounds (shrinked by 1 on all sides).
  ///
  /// The border uses the specified [style] characters and applies
  /// the [borderColor] as foreground or background color.
  void draw(
    CanvasBuffer buffer,
    Rect bounds,
    void Function(CanvasBuffer buffer, Rect bounds) drawChild,
  ) {
    final x = bounds.x;
    final y = bounds.y;
    final width = bounds.width;
    final height = bounds.height;
    TextComponentStyle borderStyle;

    borderStyle = TextComponentStyle();

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
