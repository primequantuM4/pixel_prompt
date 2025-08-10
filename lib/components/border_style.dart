import 'package:pixel_prompt/components/checkbox_list.dart';
import 'package:pixel_prompt/renderer/border_renderer.dart';

/// Defines the characters used to draw borders in a terminal UI.
///
/// Each instance specifies the characters for the corners and edges of a rectangular border.
///
/// ## Properties
/// - [topLeft]: Character for the top-left corner.
/// - [topRight]: Character for the top-right corner.
/// - [bottomLeft]: Character for the bottom-left corner.
/// - [bottomRight]: Character for the bottom-right corner.
/// - [horizontal]: Character for the horizontal edges.
/// - [vertical]: Character for the vertical edges.
///
/// ## Responsibilities
/// - Provide a reusable set of border characters for drawing UI elements.
/// - Support different visual styles such as thin, thick, rounded, and empty (no border).
///
/// ## Examples
/// ```dart
/// final border = BorderStyle.thin;
/// print(border.topLeft); // ┌
/// print(border.horizontal); // ─
/// ```
///
/// Use with a border renderer:
/// ```dart
/// BorderRenderer(style: BorderStyle.rounded).draw(buffer, bounds, drawChild);
/// ```
///
/// ## See Also
/// - [BorderRenderer]: Renders the border using these characters.
/// - [CheckboxList] use borders for layout.
///
/// {@category Styling}
class BorderStyle {
  /// Character for the top-left corner of the border.
  final String topLeft;

  /// Character for the top-right corner of the border.
  final String topRight;

  /// Character for the bottom-left corner of the border.
  final String bottomLeft;

  /// Character for the bottom-right corner of the border.
  final String bottomRight;

  /// Character for the horizontal edges of the border.
  final String horizontal;

  /// Character for the vertical edges of the border.
  final String vertical;

  /// Creates a new [BorderStyle] with the specified corner and edge characters.
  const BorderStyle({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

  /// Thin line border style.
  static const thin = BorderStyle(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
  );

  /// Thick line border style.
  static const thick = BorderStyle(
    topLeft: '╔',
    topRight: '╗',
    bottomLeft: '╚',
    bottomRight: '╝',
    horizontal: '═',
    vertical: '║',
  );

  /// Rounded corners border style.
  static const rounded = BorderStyle(
    topLeft: '╭',
    topRight: '╮',
    bottomLeft: '╰',
    bottomRight: '╯',
    horizontal: '─',
    vertical: '│',
  );

  /// Empty border style (no visible border).
  static const empty = BorderStyle(
    topLeft: ' ',
    topRight: ' ',
    bottomLeft: ' ',
    bottomRight: ' ',
    horizontal: ' ',
    vertical: ' ',
  );
}
