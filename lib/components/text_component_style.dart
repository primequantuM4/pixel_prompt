import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'colors.dart';
import 'font_style.dart';

/// Defines the visual style for a text component, including color, background,
/// font styles, and spacing (padding/margin).
///
/// A [TextComponentStyle] encapsulates all styling information that determines
/// how text is displayed in a terminal or canvas-based UI, using ANSI color codes
/// and text formatting attributes.
///
/// ### Styling Options
/// - **Foreground/Background Colors:** Controlled by [color] and [bgColor] using
///   [AnsiColorType].
/// - **Font Styles:** Bold, italic, underline, strikethrough, etc., using
///   [FontStyle].
/// - **Padding & Margin:** Controlled via [EdgeInsets] for layout spacing.
///
/// ### Example
/// ```dart
/// final style = TextComponentStyle(
///   color: Colors.red,
///   bgColor: ColorRGB(0, 0, 0),
///   styles: {FontStyle.bold, FontStyle.underline},
///   padding: EdgeInsets.all(1),
///   margin: EdgeInsets.symmetric(horizontal: 2),
/// );
///
/// final boldStyle = style.bold().foreground(Colors.blue);
/// ```
///
/// ### See Also
/// - [AnsiColorType] for color definitions.
/// - [FontStyle] for text formatting.
/// - [EdgeInsets] for layout spacing.
///
/// {@category Styling}
class TextComponentStyle {
  /// The foreground text color.
  final AnsiColorType? color;

  /// The background text color.
  final AnsiColorType? bgColor;

  /// The set of font styles (e.g., bold, italic, underline).
  final Set<FontStyle> styles;

  /// The space inside the text boundaries.
  final EdgeInsets padding;

  /// The space outside the text boundaries.
  final EdgeInsets margin;

  /// Creates a [TextComponentStyle] with optional color, background color,
  /// font styles, and padding/margin settings.
  ///
  /// If [styles] is omitted, defaults to an empty set.
  /// Padding and margin default to zero on all sides.
  const TextComponentStyle({
    this.color,
    this.bgColor,
    Set<FontStyle>? styles,
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
  }) : styles = styles ?? const <FontStyle>{};

  /// The total horizontal padding (left + right).
  int get horizontalPadding => padding.horizontal;

  /// The total vertical padding (top + bottom).
  int get verticalPadding => padding.vertical;

  /// The total horizontal margin (left + right).
  int get horizontalMargin => margin.horizontal;

  /// The total vertical margin (top + bottom).
  int get verticalMargin => margin.vertical;

  /// Returns a copy of this style with the given [color] as the foreground color.
  TextComponentStyle foreground(AnsiColorType color) => copyWith(color: color);

  /// Returns a copy of this style with the given [bgColor] as the background color.
  TextComponentStyle background(AnsiColorType color) =>
      copyWith(bgColor: color);

  /// Returns a copy of this style with bold text enabled.
  TextComponentStyle bold() => copyWith(styles: {...styles, FontStyle.bold});

  /// Returns a copy of this style with italic text enabled.
  TextComponentStyle italic() =>
      copyWith(styles: {...styles, FontStyle.italic});

  /// Returns a copy of this style with underlined text enabled.
  TextComponentStyle underline() =>
      copyWith(styles: {...styles, FontStyle.underline});

  /// Returns a copy of this style with strikethrough text enabled.
  TextComponentStyle strikethrough() =>
      copyWith(styles: {...styles, FontStyle.strikethrough});

  /// Returns a copy of this style with updated padding values.
  TextComponentStyle paddingOnly({
    int top = 0,
    int right = 0,
    int bottom = 0,
    int left = 0,
  }) => copyWith(
    padding: EdgeInsets.only(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    ),
  );

  /// Returns a copy of this style with updated margin values.
  TextComponentStyle marginOnly({
    int top = 0,
    int right = 0,
    int bottom = 0,
    int left = 0,
  }) => copyWith(
    margin: EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
  );

  /// Builds and returns the ANSI style code string for this style.
  ///
  /// Includes font style codes, foreground, and background colors if defined.
  /// Also logs the generated style code via [Logger.trace].
  String getStyleAnsi() {
    final codes = [
      for (var style in styles) style.code,
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
    ].join(';');

    Logger.trace("TextComponentStyle", codes.split(';').join(':'));
    return codes;
  }

  /// Returns a new [TextComponentStyle] with the given properties overridden.
  ///
  /// Properties not specified will be copied from the current style.
  TextComponentStyle copyWith({
    AnsiColorType? color,
    AnsiColorType? bgColor,
    Set<FontStyle>? styles,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return TextComponentStyle(
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
      styles: styles ?? this.styles,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }
}
