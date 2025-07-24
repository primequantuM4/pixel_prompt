abstract class AnsiColorType {
  String get fg;
  String get bg;

  AnsiColorType dimmed();
}

class Colors implements AnsiColorType {
  final int code;
  final int bgCode;
  final bool _dim;

  const Colors._(this.code, this.bgCode, [this._dim = false]);

  static const black = Colors._(30, 40);
  static const red = Colors._(31, 41);
  static const green = Colors._(32, 42);
  static const yellow = Colors._(33, 43);
  static const blue = Colors._(34, 44);
  static const magenta = Colors._(35, 45);
  static const cyan = Colors._(36, 46);
  static const white = Colors._(37, 47);

  static const highBlack = Colors._(90, 100);
  static const highRed = Colors._(91, 101);
  static const highGreen = Colors._(92, 102);
  static const highYellow = Colors._(93, 103);
  static const highBlue = Colors._(94, 104);
  static const highMagenta = Colors._(95, 105);
  static const highCyan = Colors._(96, 106);
  static const highWhite = Colors._(97, 107);

  @override
  String get fg => _dim ? '2;$code' : '$code';
  @override
  String get bg => _dim ? '2;$bgCode' : '$bgCode';

  @override
  Colors dimmed() => Colors._(code, bgCode, true);
}

class ColorRGB implements AnsiColorType {
  final int r, g, b;
  const ColorRGB(this.r, this.g, this.b);

  @override
  ColorRGB dimmed({dimFactor = 0.5}) {
    return ColorRGB(
      (r * dimFactor).round(),
      (g * dimFactor).round(),
      (b * dimFactor).round(),
    );
  }

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

  @override
  String toString() => 'ColorRGB: r: $r, g: $g, b: $b';
}
