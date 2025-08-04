class FontStyle {
  final int code;
  final String name;

  const FontStyle._(this.code, this.name);

  static const bold = FontStyle._(1, 'bold');
  static const italic = FontStyle._(3, 'italic');
  static const underline = FontStyle._(4, 'underline');
  static const strikethrough = FontStyle._(9, 'strikethrough');

  static const mapping = <int, FontStyle>{
    1: bold,
    3: italic,
    4: underline,
    9: strikethrough,
  };

  static const List<FontStyle> values = [
    bold,
    italic,
    underline,
    strikethrough,
  ];

  factory FontStyle.fromCode(int code) {
    return mapping[code]!;
  }

  @override
  String toString() => name;
}
