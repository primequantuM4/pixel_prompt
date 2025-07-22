import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'colors.dart';
import 'font_style.dart';

class TextComponentStyle {
  final AnsiColorType? color;
  final AnsiColorType? bgColor;
  final Set<FontStyle> styles;

  final EdgeInsets padding;
  final EdgeInsets margin;

  const TextComponentStyle({
    this.color,
    this.bgColor,
    Set<FontStyle>? styles,
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
  }) : styles = styles ?? const <FontStyle>{};

  int get horizontalPadding => padding.horizontal;
  int get verticalPadding => padding.vertical;
  int get horizontalMargin => margin.horizontal;
  int get verticalMargin => margin.vertical;

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


  TextComponentStyle paddingOnly(
          {int top = 0, int right = 0, int bottom = 0, int left = 0}) =>
      copyWith(
        padding: EdgeInsets.only(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
        ),
      );

  TextComponentStyle marginOnly(
          {int top = 0, int right = 0, int bottom = 0, int left = 0}) =>
      copyWith(
        margin: EdgeInsets.only(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
        ),
      );

  String getStyleAnsi() {
    final codes = [
      for (var style in styles) style.code,
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
    ].join(';');

    Logger.trace("TextComponentStyle", codes.split(';').join(':'));
    return codes;
  }

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
    );
  }
}
