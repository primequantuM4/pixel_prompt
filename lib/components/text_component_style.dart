import 'colors.dart';
import 'font_style.dart';

class TextComponentStyle {
  AnsiColorType? color;
  AnsiColorType? bgColor;
  Set<FontStyle> styles = {};

  int _paddingLeft = 0;
  int _paddingRight = 0;
  int _paddingTop = 0;
  int _paddingBottom = 0;

  int _marginLeft = 0;
  int _marginRight = 0;
  int _marginTop = 0;
  int _marginBottom = 0;

  TextComponentStyle foreground(AnsiColorType color) {
    this.color = color;
    return this;
  }

  TextComponentStyle background(AnsiColorType color) {
    bgColor = color;
    return this;
  }

  TextComponentStyle bold() {
    styles.add(FontStyle.bold);
    return this;
  }

  TextComponentStyle italic() {
    styles.add(FontStyle.italic);
    return this;
  }

  TextComponentStyle underline() {
    styles.add(FontStyle.underline);
    return this;
  }

  TextComponentStyle strikethrough() {
    styles.add(FontStyle.strikethrough);
    return this;
  }

  TextComponentStyle paddingTop(int padding) {
    _paddingTop = padding;
    return this;
  }

  TextComponentStyle paddingLeft(int padding) {
    _paddingLeft = padding;
    return this;
  }

  TextComponentStyle paddingRight(int padding) {
    _paddingRight = padding;
    return this;
  }

  TextComponentStyle paddingBottom(int padding) {
    _paddingBottom = padding;
    return this;
  }

  TextComponentStyle marginTop(int margin) {
    _marginTop = margin;
    return this;
  }

  TextComponentStyle marginBottom(int margin) {
    _marginBottom = margin;
    return this;
  }

  TextComponentStyle marginLeft(int margin) {
    _marginLeft = margin;
    return this;
  }

  TextComponentStyle marginRight(int margin) {
    _marginRight = margin;
    return this;
  }

  String getStyleAnsi() {
    final codes = [
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
      for (var style in styles) style.code,
    ].join(';');

    return codes;
  }

  int get horizontalPadding => _paddingLeft + _paddingRight;
  int get verticalPadding => _paddingTop + _paddingBottom;
  int get horizontalMargin => _marginLeft + _marginRight;
  int get verticalMargin => _marginTop + _marginBottom;

  int get leftPadding => _paddingLeft;
  int get rightPadding => _paddingRight;
  int get topPadding => _paddingTop;
  int get bottomPadding => _paddingBottom;

  int get leftMargin => _marginLeft;
  int get rightMargin => _marginRight;
  int get topMargin => _marginTop;
  int get bottomMargin => _marginBottom;
}
