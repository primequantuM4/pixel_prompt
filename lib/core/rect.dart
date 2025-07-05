/// A simple immutable rectangle defined by its top-left corner and size.
///
/// The [Rect] class represents a rectangular region in a 2D space using
/// integer coordinates and dimensions. It is defined by:
/// - the top-left corner ([x], [y])
/// - the [width] and [height] of the rectangle
///
/// This class is typically used for layout, rendering bounds, or hit-testing
/// in the terminal UI system.
class Rect {
  /// The horizontal coordinate of the top-left corner.
  final int x;

  /// The vertical coordinate of the top-left corner.
  final int y;

  /// The width of the rectangle.
  final int width;

  /// The height of the rectangle.
  final int height;

  /// Creates a [Rect] with the given [x], [y], [width], and [height].
  ///
  /// All parameters are required and must be non-null.
  const Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// The horizontal coordinate of the right edge of the rectangle.
  ///
  /// Equivalent to `x + width`.
  int get right => x + width;

  /// The vertical coordinate of the bottom edge of the rectangle.
  ///
  /// Equivalent to `y + height`.
  int get bottom => y + height;

  /// Returns a string representation of the rectangle, including its
  /// position and size.
  @override
  String toString() => 'x:$x, y:$y, width:$width, height:$height';
}
