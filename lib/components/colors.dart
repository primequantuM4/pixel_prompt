/// Interface representing an ANSI color type used for terminal foreground and background colors.
///
/// Provides methods to get ANSI color codes and their printable representations,
/// and a method to get a dimmed variant of the color.
///
/// ## Responsibilities
/// - Provide ANSI escape codes for foreground and background colors.
/// - Support dimmed (faint) color variants.
/// - Provide human-readable printable representations.
///
/// ## See Also
/// - [Colors] - Predefined ANSI standard and bright colors.
/// - [ColorRGB] - Represents true color (24-bit RGB) ANSI colors.
/// {@category Color}
/// {@category Components}
/// {@category Styling}
abstract class AnsiColorType {
  /// Returns the ANSI foreground color code as a string.
  String get fg;

  /// Returns the ANSI background color code as a string.
  String get bg;

  /// Returns a printable string representation of the foreground color (e.g., "red", "#ff0000").
  String get printableFg;

  /// Returns a printable string representation of the background color.
  String get printableBg;

  /// Returns a dimmed (faint) variant of this color.
  AnsiColorType dimmed();
}

/// Standard ANSI colors implementation with support for normal and bright variants.
///
/// Provides common ANSI colors with their respective codes for foreground and background.
///
/// ## Properties
/// - [code]: ANSI code for the foreground color.
/// - [bgCode]: ANSI code for the background color.
/// - [name]: Human-readable name of the color.
/// - [_dim]: Whether this color is dimmed (faint).
///
/// ## Responsibilities
/// - Map ANSI color codes to predefined colors.
/// - Provide ANSI escape sequences for foreground and background.
/// - Generate dimmed variants.
///
/// ## Example
/// ```dart
/// final red = Colors.red;
/// print(red.fg);       // Outputs: 31
/// print(red.printableFg); // Outputs: "red"
/// final dimRed = red.dimmed();
/// print(dimRed.fg);    // Outputs: "2;31"
/// ```
///
/// ## See Also
/// - [AnsiColorType] - For parent class
/// - [ColorRGB] - For true color (24-bit RGB) ANSI colors
///
/// {@category Color}
/// {@category Component}
/// {@category Styling}
class Colors implements AnsiColorType {
  /// The ANSI escape code for the foreground color.
  final int code;

  /// The ANSI escape code for the background color.
  final int bgCode;

  /// Whether this color is dimmed (faint).
  final bool _dim;

  /// Human-readable name of the color.
  final String name;

  const Colors._(this.code, this.bgCode, this.name, [this._dim = false]);

  /// Standard black ANSI color.
  static const black = Colors._(30, 40, 'black');

  /// Standard red ANSI color.
  static const red = Colors._(31, 41, 'red');

  /// Standard green ANSI color.
  static const green = Colors._(32, 42, 'green');

  /// Standard yellow ANSI color.
  static const yellow = Colors._(33, 43, 'yellow');

  /// Standard blue ANSI color.
  static const blue = Colors._(34, 44, 'blue');

  /// Standard magenta ANSI color.
  static const magenta = Colors._(35, 45, 'magenta');

  /// Standard cyan ANSI color.
  static const cyan = Colors._(36, 46, 'cyan');

  /// Standard white ANSI color.
  static const white = Colors._(37, 47, 'white');

  /// Bright black ANSI color.
  static const highBlack = Colors._(90, 100, 'highBlack');

  /// Bright red ANSI color.
  static const highRed = Colors._(91, 101, 'highRed');

  /// Bright green ANSI color.
  static const highGreen = Colors._(92, 102, 'highGreen');

  /// Bright yellow ANSI color.
  static const highYellow = Colors._(93, 103, 'highYellow');

  /// Bright blue ANSI color.
  static const highBlue = Colors._(94, 104, 'highBlue');

  /// Bright magenta ANSI color.
  static const highMagenta = Colors._(95, 105, 'highMagenta');

  /// Bright cyan ANSI color.
  static const highCyan = Colors._(96, 106, 'highCyan');

  /// Bright white ANSI color.
  static const highWhite = Colors._(97, 107, 'highWhite');

  /// Mapping of ANSI codes to their corresponding [Colors] instances.
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

  /// Returns the ANSI escape sequence for the foreground color.
  ///
  /// If the color is dimmed, returns a compound escape sequence
  /// that includes both the dim code (2) and the color code.
  @override
  String get fg => _dim ? '2;$code' : '$code';

  /// Returns the ANSI escape sequence for the background color.
  ///
  /// If the color is dimmed, returns a compound escape sequence
  /// that includes both the dim code (2) and the color code.
  @override
  String get bg => _dim ? '2;$bgCode' : '$bgCode';

  /// Returns a human-readable string representation of the foreground color.
  ///
  /// For dimmed colors, appends "(d)" to the color name.
  @override
  String get printableFg => _dim ? '$name(d)' : name;

  /// Returns a human-readable string representation of the background color.
  ///
  /// For dimmed colors, appends "(d)" to the color name.
  @override
  String get printableBg => _dim ? '$name(d)' : name;

  /// Creates a dimmed version of this color.
  ///
  /// Returns a new [Colors] instance with the same base color code
  /// but marked as dimmed.
  @override
  Colors dimmed() => Colors._(code, bgCode, name, true);

  /// Returns the predefined color corresponding to the given ANSI code.
  ///
  /// Throws an exception if the code is not recognized.
  ///
  /// Example:
  /// ```dart
  /// final color = Colors.fromCode(31); // Returns Colors.red
  /// ```
  factory Colors.fromCode(int code) => _ansiCodes[code]!;
}

/// Represents a true color (24-bit RGB) ANSI color.
///
/// Supports generating ANSI escape sequences for foreground and background colors
/// in the RGB format, along with dimming support.
///
/// ## Properties
/// - [r], [g], [b]: Red, Green, Blue components (0-255).
///
/// ## Responsibilities
/// - Provide RGB ANSI escape codes for foreground and background.
/// - Support dimming of RGB colors.
/// - Provide printable hex string representation.
///
/// ## Example
/// ```dart
/// final redRgb = ColorRGB(255, 0, 0);
/// print(redRgb.fg);         // Outputs: "38;2;255;0;0"
/// print(redRgb.printableFg); // Outputs: "#ff0000"
/// final dimmed = redRgb.dimmed();
/// print(dimmed.fg);          // Outputs dimmed RGB code.
/// ```
///
/// ## See Also
/// - [AnsiColorType] - For parent class
/// - [Colors] - For named colors
/// {@category Color}
/// {@category Component}
/// {@category Styling}
class ColorRGB implements AnsiColorType {
  /// The red component of the RGB color (0-255).
  final int r;

  /// The green component of the RGB color (0-255).
  final int g;

  /// The blue component of the RGB color (0-255).
  final int b;

  /// Creates a true color RGB color with the given components.
  ///
  /// - [r]: Red component (0-255)
  /// - [g]: Green component (0-255)
  /// - [b]: Blue component (0-255)
  ///
  /// Example:
  /// ```dart
  /// const pureRed = ColorRGB(255, 0, 0);
  /// const pureGreen = ColorRGB(0, 255, 0);
  /// const pureBlue = ColorRGB(0, 0, 255);
  /// ```
  const ColorRGB(this.r, this.g, this.b);

  /// Returns a dimmed version of this color by scaling RGB components by [dimFactor].
  ///
  /// The default dim factor is 0.5, which reduces each color component by half.
  ///
  /// Example:
  /// ```dart
  /// final brightRed = ColorRGB(255, 0, 0);
  /// final dimRed = brightRed.dimmed(); // RGB(127, 0, 0)
  /// final veryDimRed = brightRed.dimmed(dimFactor: 0.2); // RGB(51, 0, 0)
  /// ```
  @override
  ColorRGB dimmed({double dimFactor = 0.5}) {
    return ColorRGB(
      (r * dimFactor).round(),
      (g * dimFactor).round(),
      (b * dimFactor).round(),
    );
  }

  /// Returns the ANSI escape sequence for the RGB foreground color.
  ///
  /// Format: "38;2;r;g;b"
  @override
  String get fg => '38;2;$r;$g;$b';

  /// Returns the ANSI escape sequence for the RGB background color.
  ///
  /// Format: "48;2;r;g;b"
  @override
  String get bg => '48;2;$r;$g;$b';

  /// Returns a hexadecimal string representation of the foreground color.
  ///
  /// Format: "#rrggbb" where each component is 2-digit hex.
  @override
  String get printableFg =>
      '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

  /// Returns a hexadecimal string representation of the background color.
  ///
  /// Format: "#rrggbb" where each component is 2-digit hex.
  @override
  String get printableBg =>
      '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

  /// Compares two [ColorRGB] instances for equality.
  ///
  /// Returns true if both colors have the same RGB components.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ColorRGB && r == other.r && g == other.g && b == other.b;
  }

  /// Returns the hash code for this color based on its RGB components.
  @override
  int get hashCode => Object.hash(r, g, b);

  /// Returns a string representation of this RGB color.
  ///
  /// Format: "ColorRGB: r: {r}, g: {g}, b: {b}"
  @override
  String toString() => 'ColorRGB: r: $r, g: $g, b: $b';
}
