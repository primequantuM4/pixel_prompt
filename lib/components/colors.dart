abstract class AnsiColorType {
  String get fg;
  String get bg;
}

enum Colors implements AnsiColorType {
  black(30, 40),
  red(31, 41),
  green(32, 42),
  yellow(33, 43),
  blue(34, 44),
  magenta(35, 45),
  cyan(36, 46),
  white(37, 47),
  highBlack(90, 100),
  highRed(91, 101),
  highGreen(92, 102),
  highYellow(93, 103),
  highBlue(94, 104),
  highMagenta(95, 105),
  highCyan(96, 106),
  highWhite(97, 107);

  final int code;
  final int bgCode;
  const Colors(this.code, this.bgCode);

  @override
  String get fg => '$code';

  @override
  String get bg => '$bgCode';
}

class ColorRGB implements AnsiColorType {
  final int r, g, b;
  const ColorRGB(this.r, this.g, this.b);

  @override
  String get fg => '38;2;$r;$g;$b';

  @override
  String get bg => '48;2;$r;$g;$b';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ColorRGB && r == other.r && g == other.g && b == other.b;
  }

  @override
  int get hashCode => Object.hash(r, g, b);
}
