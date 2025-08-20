/// Represents the width and height dimensions of a rectangular area.
///
/// The [Size] class is used to describe the dimensions of components,
/// containers, and layout regions within the terminal UI framework.
///
/// Both [width] and [height] are mutable to allow dynamic resizing.
///
/// {@category Core}
class Size {
  /// The horizontal extent.

  int width;

  /// The vertical extent.

  int height;

  /// Creates a [Size] with the given [width] and [height].
  ///
  /// Both dimensions must be non-negative.
  Size({required this.width, required this.height});

  /// A large fixed size representing effectively infinite dimensions.
  ///
  /// Used when a component should not be constrained by available space
  static Size infite = Size(width: 1000, height: 1000);
}
