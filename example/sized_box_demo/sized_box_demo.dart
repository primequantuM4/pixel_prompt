import 'dart:async';

import 'package:pixel_prompt/components/sized_box_style.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/pixel_prompt.dart';
import 'package:pixel_prompt/terminal/terminal_functions.dart';
import 'package:pixel_prompt/components/center.dart';

// Let's create a count box, which will count numbers for us
class CountBox extends StatefulComponent {
  final int countStart;
  final Size boxSize;
  final bool isBackwards;

  CountBox({
    required this.boxSize,
    this.countStart = 0,
    this.isBackwards = false,
  });

  @override
  ComponentState<CountBox> createState() =>
      _CountBoxState(countStart, boxSize, isBackwards);
}

// State is a must-have for such a component (number being counted is *the* state)
class _CountBoxState extends ComponentState<CountBox> {
  int count;
  final Size boxSize;
  final bool isBackwards;

  _CountBoxState(this.count, this.boxSize, this.isBackwards);

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {
        count += (isBackwards) ? -1 : 1;
      }),
    );
  }

  @override
  List<Component> build() {
    return [SizedBox(child: TextComponent(count.toString()), size: boxSize)];
  }
}

void main() {
  final Size smallSized = Size(
    width: TerminalFunctions.terminalWidth ~/ 2,
    height: TerminalFunctions.terminalHeight ~/ 4,
  );

  App(
    children: [
      Column(
        children: [
          Row(
            children: [
              SizedBox(
                size: smallSized,
                padding: EdgeInsets.all(1),
                child: CountBox(boxSize: smallSized),
              ),
              SizedBox(
                size: smallSized,
                padding: EdgeInsets.all(1),
                child: TextComponent(
                  "I'm on the right side!",
                  style: TextComponentStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                size: smallSized,
                padding: EdgeInsets.all(2),
                child: TextComponent(
                  "And I'm on the left side! (Padded)",
                  style: TextComponentStyle(color: Colors.green),
                ),
              ),
              SizedBox(
                size: smallSized,
                padding: EdgeInsets.all(1),
                child: CountBox(
                  boxSize: smallSized,
                  countStart: 100,
                  isBackwards: true,
                ),
              ),
            ],
          ),
          SizedBox(
            child: Center(
              child: TextComponent(
                "Centered Text",
                style: TextComponentStyle(
                  color: Colors.green,
                  bgColor: Colors.white,
                ),
              ),
            ),
            size: Size(
              height: TerminalFunctions.terminalHeight ~/ 4,
              width: TerminalFunctions.terminalWidth,
            ),
            style: SizedBoxStyle(border: BorderStyle.thick),
          ),
          SizedBox(
            size: Size(
              height: TerminalFunctions.terminalHeight ~/ 4,
              width: TerminalFunctions.terminalWidth,
            ),
            style: SizedBoxStyle(
              backgroundColor: Colors.blue,
              border: BorderStyle.rounded,
            ),
            child: Center(
              child: TextComponent(
                "Pretty Styled SizedBox",
                style: TextComponentStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ],
  ).run(fullScreenMode: true);
}
