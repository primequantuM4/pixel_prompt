import 'package:pixel_prompt/logger/logger.dart';
import 'colors.dart';
import 'font_style.dart';

class TextComponentStyle {
  final AnsiColorType? color;
  final AnsiColorType? bgColor;
  final Set<FontStyle> styles;

  final int _leftPadding;
  final int _rightPadding;
  final int _topPadding;
  final int _bottomPadding;

  final int _leftMargin;
  final int _rightMargin;
  final int _topMargin;
  final int _bottomMargin;

  const TextComponentStyle({
    this.color,
    this.bgColor,
    Set<FontStyle>? styles,
    int leftPadding = 0,
    int rightPadding = 0,
    int topPadding = 0,
    int bottomPadding = 0,
    int leftMargin = 0,
    int rightMargin = 0,
    int topMargin = 0,
    int bottomMargin = 0,
  })  : styles = styles ?? const <FontStyle>{},
        _leftPadding = leftPadding,
        _rightPadding = rightPadding,
        _topPadding = topPadding,
        _bottomPadding = bottomPadding,
        _leftMargin = leftMargin,
        _rightMargin = rightMargin,
        _topMargin = topMargin,
        _bottomMargin = bottomMargin;

  // Getter methods (unchanged)
  int get horizontalPadding => _leftPadding + _rightPadding;
  int get verticalPadding => _topPadding + _bottomPadding;
  int get horizontalMargin => _leftMargin + _rightMargin;
  int get verticalMargin => _topMargin + _bottomMargin;

  int get leftPadding => _leftPadding;
  int get rightPadding => _rightPadding;
  int get topPadding => _topPadding;
  int get bottomPadding => _bottomPadding;

  int get leftMargin => _leftMargin;
  int get rightMargin => _rightMargin;
  int get topMargin => _topMargin;
  int get bottomMargin => _bottomMargin;

  // Style modification methods (return new instances)
  TextComponentStyle foreground(AnsiColorType color) => copyWith(color: color);

  TextComponentStyle background(AnsiColorType color) =>
      copyWith(bgColor: color);

  TextComponentStyle bold() => copyWith(styles: {...styles, FontStyle.bold});

  TextComponentStyle italic() =>
      copyWith(styles: {...styles, FontStyle.italic});

  TextComponentStyle underline() =>
      copyWith(styles: {...styles, FontStyle.underline});

  TextComponentStyle strikethrough() =>
      copyWith(styles: {...styles, FontStyle.strikethrough});

  TextComponentStyle dim() {
    Logger.trace("TextComponentStyle", "Dim added ${FontStyle.dim.code}");
    return copyWith(styles: {...styles, FontStyle.dim});
  }

  // Padding/margin modification methods
  TextComponentStyle paddingTop(int padding) => copyWith(topPadding: padding);
  TextComponentStyle paddingLeft(int padding) => copyWith(leftPadding: padding);
  TextComponentStyle paddingRight(int padding) =>
      copyWith(rightPadding: padding);
  TextComponentStyle paddingBottom(int padding) =>
      copyWith(bottomPadding: padding);

  TextComponentStyle marginTop(int margin) => copyWith(topMargin: margin);
  TextComponentStyle marginBottom(int margin) => copyWith(bottomMargin: margin);
  TextComponentStyle marginLeft(int margin) => copyWith(leftMargin: margin);
  TextComponentStyle marginRight(int margin) => copyWith(rightMargin: margin);

  // ANSI style generator (unchanged)
  String getStyleAnsi() {
    final codes = [
      for (var style in styles) style.code,
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
    ].join(';');

    Logger.trace("TextComponentStyle", codes.split(';').join(':'));
    return codes;
  }

  // CopyWith helper
  TextComponentStyle copyWith({
    AnsiColorType? color,
    AnsiColorType? bgColor,
    Set<FontStyle>? styles,
    int? leftPadding,
    int? rightPadding,
    int? topPadding,
    int? bottomPadding,
    int? leftMargin,
    int? rightMargin,
    int? topMargin,
    int? bottomMargin,
  }) {
    return TextComponentStyle(
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
      styles: styles ?? this.styles,
      leftPadding: leftPadding ?? _leftPadding,
      rightPadding: rightPadding ?? _rightPadding,
      topPadding: topPadding ?? _topPadding,
      bottomPadding: bottomPadding ?? _bottomPadding,
      leftMargin: leftMargin ?? _leftMargin,
      rightMargin: rightMargin ?? _rightMargin,
      topMargin: topMargin ?? _topMargin,
      bottomMargin: bottomMargin ?? _bottomMargin,
    );
  }
}
