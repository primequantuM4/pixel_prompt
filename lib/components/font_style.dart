enum FontStyle {
  bold(1),
  italic(3),
  underline(4),
  strikethrough(9);

  final int code;
  const FontStyle(this.code);
}
