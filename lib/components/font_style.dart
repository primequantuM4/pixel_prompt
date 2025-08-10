import 'package:pixel_prompt/components/colors.dart';

/// Represents a text font style in ANSI terminal sequences.
///
/// Provides predefined font styles such as bold, italic, underline, and strikethrough,
/// identified by their ANSI style codes.
///
/// ## Properties
/// - [code]: The ANSI code representing the font style.
/// - [name]: A human-readable name of the font style.
///
/// ## Responsibilities
/// - Map ANSI style codes to named font styles.
/// - Provide a way to get a font style from its ANSI code.
///
/// ## Example
/// ```dart
/// final boldStyle = FontStyle.bold;
/// print(boldStyle.code); // Outputs: 1
/// print(boldStyle.name); // Outputs: "bold"
///
/// final underlineStyle = FontStyle.fromCode(4);
/// print(underlineStyle.name); // Outputs: "underline"
/// ```
///
/// ## See Also
/// - ANSI escape codes for font styling.
/// - [AnsiColorType] - For styling text with color
///
/// {@category Styling}
class FontStyle {
  /// The ANSI style code for this font style.
  final int code;

  /// The human-readable name of this font style.
  final String name;

  const FontStyle._(this.code, this.name);

  /// Bold font style (ANSI code 1).
  static const bold = FontStyle._(1, 'bold');

  /// Italic font style (ANSI code 3).
  static const italic = FontStyle._(3, 'italic');

  /// Underline font style (ANSI code 4).
  static const underline = FontStyle._(4, 'underline');

  /// Strikethrough font style (ANSI code 9).
  static const strikethrough = FontStyle._(9, 'strikethrough');

  static final Map<int, FontStyle> _fromCode = {
    for (final style in values) style.code: style,
  };

  /// List of all predefined font styles.
  static const List<FontStyle> values = [
    bold,
    italic,
    underline,
    strikethrough,
  ];

  /// Returns the [FontStyle] matching the given ANSI [code].
  ///
  /// Throws [StateError] if the code is not recognized.
  factory FontStyle.fromCode(int code) {
    if (!_fromCode.containsKey(code)) {
      throw StateError('Unknown font style code: $code');
    }
    return _fromCode[code]!;
  }

  @override
  String toString() => name;
}
