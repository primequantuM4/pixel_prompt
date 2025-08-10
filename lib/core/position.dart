/// Represents a 2D position with a defined positioning mode.
///
/// A [Position] stores horizontal ([x]) and vertical ([y]) offsets, along with a
/// [PositionType] that determines whether the offsets are interpreted as absolute
/// coordinates or relative to a parent element.
///
/// This is commonly used for placing components within a container or
/// specifying fixed positions in a terminal or layout system.
///
/// Example:
/// ```dart
/// // Absolute position at (10, 5)
/// final pos1 = Position(
///   x: 10,
///   y: 5,
///   positionType: PositionType.absolute,
/// );
///
/// // Relative position offset by (2, -1) from a parent reference point
/// final pos2 = Position(
///   x: 2,
///   y: -1,
///   positionType: PositionType.relative,
/// );
/// ```
///
/// See also:
/// - [PositionType] for available positioning modes
/// - [Component.position] for component placement
///
/// {@category Core}
/// {@category Layout}
class Position {
  /// The horizontal offset from the origin or reference point.
  final int x;

  /// The vertical offset from the origin or reference point.
  final int y;

  /// The positioning mode that determines how [x] and [y] are interpreted.
  ///
  /// - [PositionType.absolute]: Coordinates are fixed and independent of layout.
  /// - [PositionType.relative]: Coordinates are offsets relative to a parent
  ///   or reference point.
  final PositionType positionType;

  /// Creates a [Position] with the given [x], [y], and [positionType].
  const Position({
    required this.x,
    required this.y,
    required this.positionType,
  });
}

/// Defines how a [Position]’s coordinates are interpreted.
enum PositionType {
  /// Coordinates are fixed and independent of any parent or layout context.
  absolute,

  /// Coordinates are relative to a parent or reference point in the layout.
  relative,
}
