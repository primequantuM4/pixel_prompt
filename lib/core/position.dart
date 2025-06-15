class Position {
  final int x;
  final int y;
  final PositionType positionType;

  const Position({
    required this.x,
    required this.y,
    required this.positionType,
  });
}

enum PositionType { absolute, relative }

