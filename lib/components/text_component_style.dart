import 'colors.dart';
import 'font_style.dart';

class TextComponentStyle {
  AnsiColorType? color;
  AnsiColorType? bgColor;
  Set<FontStyle> styles = {};

  int _leftPadding = 0;
  int _rightPadding = 0;
  int _topPadding = 0;
  int _bottomPadding = 0;

  int _leftMargin = 0;
  int _rightMargin = 0;
  int _topMargin = 0;
  int _bottomMargin = 0;

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
    _topPadding = padding;
    return this;
  }

  TextComponentStyle paddingLeft(int padding) {
    _leftPadding = padding;
    return this;
  }

  TextComponentStyle paddingRight(int padding) {
    _rightPadding = padding;
    return this;
  }

  TextComponentStyle paddingBottom(int padding) {
    _bottomPadding = padding;
    return this;
  }

  TextComponentStyle marginTop(int margin) {
    _topMargin = margin;
    return this;
  }

  TextComponentStyle marginBottom(int margin) {
    _bottomMargin = margin;
    return this;
  }

  TextComponentStyle marginLeft(int margin) {
    _leftMargin = margin;
    return this;
  }

  TextComponentStyle marginRight(int margin) {
    _rightMargin = margin;
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
}
