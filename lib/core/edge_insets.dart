/// Defines offsets for each side of a rectangle, typically used for padding or margins.
///
/// An [EdgeInsets] stores separate values for the top, right, bottom, and left edges.
/// This is useful for controlling spacing inside or outside UI components.
///
/// Common factory constructors are provided for convenience:
/// - [EdgeInsets.all] sets the same padding on all sides.
/// - [EdgeInsets.symmetric] sets the same padding vertically and/or horizontally.
/// - [EdgeInsets.only] sets padding for specific sides.
///
/// Example:
/// ```dart
/// // Uniform padding
/// final padding1 = EdgeInsets.all(8);
///
/// // Vertical: 10, Horizontal: 20
/// final padding2 = EdgeInsets.symmetric(vertical: 10, horizontal: 20);
///
/// // Only top and left padding
/// final padding3 = EdgeInsets.only(top: 5, left: 3);
/// ```
class EdgeInsets {
  /// The padding on the top side.
  final int top;

  /// The padding on the right side.
  final int right;

  /// The padding on the bottom side.
  final int bottom;

  /// The padding on the left side.
  final int left;

  /// Creates insets with the same value for all four sides.
  const EdgeInsets.all(int value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  /// Creates insets with symmetric vertical and/or horizontal values.
  ///
  /// - [vertical] applies to [top] and [bottom].
  /// - [horizontal] applies to [left] and [right].
  const EdgeInsets.symmetric({int vertical = 0, int horizontal = 0})
    : top = vertical,
      right = horizontal,
      bottom = vertical,
      left = horizontal;

  /// Creates insets with explicitly specified values for each side.
  const EdgeInsets.only({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  /// The total horizontal insets, equal to [left] + [right].
  int get horizontal => left + right;

  /// The total vertical insets, equal to [top] + [bottom].
  int get vertical => top + bottom;
}
