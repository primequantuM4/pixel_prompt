import 'package:pixel_prompt/pixel_prompt.dart';

class CounterComponent extends StatefulComponent {
  int counter = 0;
  bool revealed = false;
  @override
  ComponentState<CounterComponent> createState() => CounterState();
}

class CounterState extends ComponentState<CounterComponent> {
  @override
  List<Component> build() {
    return [
      Row(
        children: [
          ButtonComponent(
            label: 'Increment',
            borderStyle: BorderStyle.rounded,
            outerBorderColor: ColorRGB(0, 200, 0),
            buttonColor: ColorRGB(0, 200, 0),
            onPressed: () {
              setState(() {
                component.counter++;
              });
            },
          ),
          ButtonComponent(
            label: 'Decrement',
            outerBorderColor: ColorRGB(255, 0, 0),
            buttonColor: ColorRGB(255, 0, 0),
            borderStyle: BorderStyle.rounded,
            onPressed: () {
              setState(() {
                component.counter--;
              });
            },
          ),
        ],
      ),
      TextComponent(
        'Counter: ${component.counter}',
        style: TextComponentStyle(
          color: ColorRGB(200, 200, 200),
          bgColor: ColorRGB(20, 20, 20),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        ),
      ),
      ButtonComponent(
        label: component.revealed ? 'Hide Text' : 'Click to reveal hidden text',
        onPressed: () {
          setState(() {
            component.revealed = !component.revealed;
          });
        },
      ),
      if (component.revealed)
        TextComponent(
          'Shh! This is a hidden text',
          style: TextComponentStyle()
              .background(ColorRGB(236, 110, 170))
              .foreground(Colors.white),
        ),
    ];
  }
}

void main() {
  App(children: [CounterComponent()]).run();
}
