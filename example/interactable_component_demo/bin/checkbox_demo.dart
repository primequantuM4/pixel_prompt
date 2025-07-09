import 'package:pixel_prompt/common/border.dart';
import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/button_component.dart';
import 'package:pixel_prompt/components/text_field_component.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/stateful_component.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class YComponent extends StatefulComponent {
  bool revealComponent = false;
  int counter = 0;
  @override
  List<Component> build() {
    return [
      Row(children: [
        ButtonComponent(
            label: 'Decrement',
            buttonColor: Colors.red,
            onPressed: () {
              setState(() {
                counter--;
              });
            }),
        ButtonComponent(
            label: "Increment",
            buttonColor: Colors.green,
            onPressed: () {
              setState(() {
                counter++;
              });
            })
      ]),
      TextComponent("Counter is now $counter",
          style: TextComponentStyle()
              .foreground(ColorRGB(143, 188, 187))
              .background(ColorRGB(46, 52, 64))
              .paddingTop(1)
              .paddingBottom(1)
              .paddingLeft(4)
              .paddingRight(4)),
      ButtonComponent(
          borderStyle: BorderStyle.rounded,
          label:
              !revealComponent ? "Reveal a Secret!" : "Quick hide the secret!",
          onPressed: () {
            setState(() {
              revealComponent = !revealComponent;
            });
          }),
      CheckboxList(
        items: ["Skyrim", "Oblivion", "Morrowind"],
        borderType: BorderType.solid,
      ),
      if (revealComponent)
        TextComponent("Welcome to pixel prompt!",
            style: TextComponentStyle()
                .foreground(ColorRGB(143, 188, 187))
                .background(ColorRGB(46, 52, 64))
                .paddingTop(1)
                .paddingBottom(1)
                .paddingLeft(4)
                .paddingRight(4))
    ];
  }
}

class XComponent extends StatefulComponent {
  String? name;

  @override
  List<Component> build() {
    Logger.trace("XComponent", "Rebuilding with name: $name");

    final children = <Component>[
      TextfieldComponent(
        placeHolder: 'Enter your name',
        textStyle: TextComponentStyle().foreground(ColorRGB(143, 188, 187)),
        hoverStyle: TextComponentStyle().background(ColorRGB(38, 38, 38)),
        onSubmitted: (value) {
          setState(() {
            name = value;
          });
        },
      ),
    ];

    if (name != null) {
      children.add(
        TextComponent(
          "Hi $name! Welcome to pixel prompt",
          style: TextComponentStyle()
              .foreground(ColorRGB(143, 188, 187))
              .background(ColorRGB(46, 52, 64))
              .paddingTop(1)
              .paddingBottom(1)
              .paddingLeft(12)
              .paddingRight(12)
              .marginLeft(4),
        ),
      );
    }

    return children;
  }
}

void main() {
  App(
    children: [
      YComponent(),
    ],
  ).run();
}
