abstract class AnsiColorType {
  String get fg;
  String get bg;

  String get printableFg;
  String get printableBg;

  AnsiColorType dimmed();
}

class Colors implements AnsiColorType {
  final int code;
  final int bgCode;
  final bool _dim;
  final String name;

  const Colors._(this.code, this.bgCode, this.name, [this._dim = false]);

  static const black = Colors._(30, 40, 'black');
  static const red = Colors._(31, 41, 'red');
  static const green = Colors._(32, 42, 'green');
  static const yellow = Colors._(33, 43, 'yellow');
  static const blue = Colors._(34, 44, 'blue');
  static const magenta = Colors._(35, 45, 'magenta');
  static const cyan = Colors._(36, 46, 'cyan');
  static const white = Colors._(37, 47, 'white');

  static const highBlack = Colors._(90, 100, 'highBlack');
  static const highRed = Colors._(91, 101, 'highRed');
  static const highGreen = Colors._(92, 102, 'highGreen');
  static const highYellow = Colors._(93, 103, 'highYellow');
  static const highBlue = Colors._(94, 104, 'highBlue');
  static const highMagenta = Colors._(95, 105, 'highMagenta');
  static const highCyan = Colors._(96, 106, 'highCyan');
  static const highWhite = Colors._(97, 107, 'highWhite');

  static const _ansiCodes = <int, Colors>{
    30: black,
    31: red,
    32: green,
    33: yellow,
    34: blue,
    35: magenta,
    36: cyan,
    37: white,
    90: highBlack,
    91: highRed,
    92: highGreen,
    93: highYellow,
    94: highBlue,
    95: highMagenta,
    96: highCyan,
    97: highWhite,
    40: black,
    41: red,
    42: green,
    43: yellow,
    44: blue,
    45: magenta,
    46: cyan,
    47: white,
    100: highBlack,
    101: highRed,
    102: highGreen,
    103: highYellow,
    104: highBlue,
    105: highMagenta,
    106: highCyan,
    107: highWhite,
  };

  @override
  String get fg => _dim ? '2;$code' : '$code';
  @override
  String get bg => _dim ? '2;$bgCode' : '$bgCode';

  @override
  String get printableFg => _dim ? '$name(d)' : name;
  @override
  String get printableBg => _dim ? '$name(d)' : name;

  @override
  Colors dimmed() => Colors._(code, bgCode, name, true);

  factory Colors.fromCode(int code) => _ansiCodes[code]!;
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
  get printableFg =>
      '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

  @override
  get printableBg =>
      '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

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
