enum FontStyle {
  bold(1),
  dim(2),
  italic(3),
  underline(4),
  strikethrough(9);

  final int code;
  const FontStyle(this.code);
}
