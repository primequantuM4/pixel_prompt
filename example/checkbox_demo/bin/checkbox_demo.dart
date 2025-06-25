import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  App(
    children: [
      CheckboxList(
        direction: Axis.vertical,
        hoverColor: ColorRGB(255, 0, 0),
        items: ['Imagine Dragons', 'Coldplay', 'Walking the wire'],
      ),
      CheckboxList(
        direction: Axis.horizontal,
        hoverColor: ColorRGB(255, 0, 0),
        items: ['Clocks', 'Sing for the moment', 'Moments'],
      ),
    ],
  ).run();
}
