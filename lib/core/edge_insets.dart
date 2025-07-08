class EdgeInsets {
  final int top, right, bottom, left;

  const EdgeInsets.all(int value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  const EdgeInsets.symmetric({int vertical = 0, int horizontal = 0})
      : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  const EdgeInsets.only({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  int get horizontal => left + right;
  int get vertical => top + bottom;
}
