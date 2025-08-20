import 'dart:math';

enum Direction { up, down, left, right }

class SnakeSegment {
  final int x;
  final int y;
  final Direction dir;
  SnakeSegment(this.x, this.y, this.dir);

  Point<int> get pos => Point(x, y);
}
