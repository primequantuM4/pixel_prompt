import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/checkbox.dart';
import 'package:pixel_prompt/components/checkbox_list.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/column.dart';
import 'package:pixel_prompt/components/row.dart';
import 'package:pixel_prompt/components/text_component.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/edge_insets.dart';

void main() {
  App(
    children: [
      const Column(
        children: [
          TextComponent(
            "Choose your Settings",
            style: TextComponentStyle(
              color: ColorRGB(143, 188, 187),
              bgColor: ColorRGB(46, 52, 64),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            ),
          ),
          CheckboxList(
            direction: Axis.vertical,
            hoverColor: ColorRGB(76, 86, 106),
            selectionColor: ColorRGB(0, 191, 165),
            textColor: ColorRGB(94, 129, 172),
            items: ['Enable Notifications', 'Dark Mode', 'Use Custom DNS'],
            borderStyle: BorderStyle.rounded,
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
  ).run();
}
