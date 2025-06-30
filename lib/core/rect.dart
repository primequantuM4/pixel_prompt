class Rect {
  final int x;
  final int y;
  final int width;
  final int height;
  const Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  int get right => x + width;
  int get bottom => y + height;

  @override
  String toString() => 'x:$x, y:$y, width:$width, height:$height';
}
