import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  print('--READY--');
  App(
    children: [
      Column(
        children: [
          TextComponent(
            "Choose your Settings",
            style: TextComponentStyle()
                .foreground(ColorRGB(143, 188, 187))
                .background(ColorRGB(46, 52, 64))
                .paddingTop(1)
                .paddingBottom(1)
                .paddingLeft(12)
                .paddingRight(12)
                .marginLeft(4),
          ),
          CheckboxList(
            direction: Axis.vertical,
            hoverColor: ColorRGB(76, 86, 106),
            selectionColor: ColorRGB(0, 191, 165),
            textColor: ColorRGB(94, 129, 172),
            items: ['Enable Notifications', 'Dark Mode', 'Use Custom DNS'],
          ),

          Row(
            children: [
              Checkbox(
                label: 'Linux',
                hoverColor: ColorRGB(76, 86, 106),
                selectionColor: ColorRGB(0, 191, 165),
                textColor: ColorRGB(94, 129, 172),
              ),
              Checkbox(
                label: 'Windows',
                hoverColor: ColorRGB(76, 86, 106),
                selectionColor: ColorRGB(0, 191, 165),
                textColor: ColorRGB(94, 129, 172),
              ),
              Checkbox(
                label: 'Mac',
                hoverColor: ColorRGB(76, 86, 106),
                selectionColor: ColorRGB(0, 191, 165),
                textColor: ColorRGB(94, 129, 172),
              ),
            ],
          ),
        ],
      ),
    ],
  ).run(testMode: true);
}
