/// Represents the width and height dimensions of a rectangular area.
///
/// The [Size] class is used to describe the dimensions of components,
/// containers, and layout regions within the terminal UI framework.
///
/// Both [width] and [height] are mutable to allow dynamic resizing.
class Size {
  /// The horizontal extent.

  int width;

  /// The vertical extent.

  int height;

  /// Creates a [Size] with the given [width] and [height].
  ///
  /// Both dimensions must be non-negative.
  Size({required this.width, required this.height});
}
