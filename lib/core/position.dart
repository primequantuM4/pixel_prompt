/// Represents a 2D position with a defined positioning mode.
///
/// A [Position] combines an [x] and [y] coordinate with a [PositionType]
/// to specify whether the values are interpreted as absolute or relative
/// within a layout or rendering context.
///
/// Used for positioning components or elements within containers or the screen.
class Position {
  /// The horizontal offset.
  final int x;

  /// The vertical offset.
  final int y;

  /// The type of positioning to apply (absolute or relative).
  final PositionType positionType;

  /// Creates a [Position] with the given [x], [y], and [positionType].
  ///
  /// - If [positionType] is [PositionType.absolute], [x] and [y] are
  ///   interpreted as fixed coordinates.
  /// - If [positionType] is [PositionType.relative], they are interpreted
  ///   relative to a parent or reference point.
  const Position({
    required this.x,
    required this.y,
    required this.positionType,
  });
}

enum PositionType { absolute, relative }
