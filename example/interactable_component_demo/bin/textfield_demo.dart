import 'package:pixel_prompt/components/text_field_component.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  App(
    children: [
      TextFieldComponent(
        placeHolder: 'Enter your name',
        textStyle: TextComponentStyle().foreground(ColorRGB(143, 188, 187)),
        hoverStyle: TextComponentStyle().background(ColorRGB(38, 38, 38)),
      ),
      TextFieldComponent(
        placeHolder: 'Enter your email',
        textStyle: TextComponentStyle().foreground(ColorRGB(143, 188, 187)),
        hoverStyle: TextComponentStyle().background(ColorRGB(38, 38, 38)),
      ),
    ],
  ).run();
}
