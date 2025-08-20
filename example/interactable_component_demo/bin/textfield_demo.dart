import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  App(
    children: [
      const TextFieldComponent(
        placeHolder: 'Enter your name',
        textStyle: TextComponentStyle(color: ColorRGB(143, 188, 187)),
        hoverStyle: TextComponentStyle(bgColor: ColorRGB(38, 38, 38)),
      ),
      const TextFieldComponent(
        placeHolder: 'Enter your email',
        textStyle: TextComponentStyle(color: ColorRGB(143, 188, 187)),
        hoverStyle: TextComponentStyle(bgColor: ColorRGB(38, 38, 38)),
      ),
    ],
  ).run();
}
