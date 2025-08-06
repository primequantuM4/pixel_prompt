import 'dart:async';

import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/manager/input_registry.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class HeaderComponent extends BuildableComponent {
  const HeaderComponent();

  @override
  List<Component> build() {
    return [
      Row(
        children: [
          TextComponent(
            "Pixel Prompt's",
            style: TextComponentStyle(
              color: ColorRGB(122, 199, 246),
              bgColor: ColorRGB(13, 15, 12),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            ),
          ),
          TextComponent(
            "Stopwatch",
            style: TextComponentStyle(
              bgColor: ColorRGB(20, 9, 18),
              color: ColorRGB(245, 147, 137),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            ),
          ),
        ],
      ),
    ];
  }
}

class StopWatchComponent extends StatefulComponent {
  int millisecond = 0;

  Timer? millisecondTimer;

  bool startCounting = false;
  bool isReset = false;

  bool tickTrigged = false;

  @override
  ComponentState<StopWatchComponent> createState() => _StopWatchState();
}

class _StopWatchState extends ComponentState<StopWatchComponent>
    implements InputHandler {
  _StopWatchState() {
    InputRegistry.register(this);
  }

  String _formatTime(int millis) {
    final totalSeconds = millis ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final hundredths = ((millis % 1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$seconds.$hundredths";
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent) return ResponseInput.ignored();

    if (event.char == 'T') {
      Logger.trace('_StopWatchState', "Triggering Stopwatch for one second");
      tick(1000);
      return ResponseInput(commands: ResponseCommands.none, handled: true);
    }

    return ResponseInput.ignored();
  }

  @override
  List<Component> build() {
    return [
      Row(
        children: [
          ButtonComponent(
            label: "Start",
            buttonColor: ColorRGB(238, 154, 223),
            outerBorderColor: Colors.white,
            borderStyle: BorderStyle.rounded,
            onPressed: () => start(),
          ),
          ButtonComponent(
            label: "Stop",
            buttonColor: ColorRGB(146, 167, 232),
            outerBorderColor: Colors.white,
            borderStyle: BorderStyle.rounded,
            onPressed: () => stop(),
          ),
          ButtonComponent(
            label: "Reset",
            buttonColor: ColorRGB(245, 147, 137),
            outerBorderColor: Colors.white,
            borderStyle: BorderStyle.rounded,
            onPressed: () => reset(),
          ),
        ],
      ),
      TextComponent(_formatTime(component.millisecond)),
    ];
  }

  void tick(int ms) {
    setState(() {
      component.millisecond += ms;
    });
  }

  void start() {
    if (component.startCounting) return;
    component.startCounting = true;
    component.millisecondTimer = Timer.periodic(Duration(milliseconds: 10), (
      _,
    ) {
      setState(() {
        component.millisecond += 10;
      });
    });
  }

  void stop() {
    component.startCounting = false;
    component.millisecondTimer?.cancel();
  }

  void reset() {
    stop();
    setState(() {
      component.millisecond = 0;
    });
  }
}

void main() {
  App(
    children: [
      Column(children: [HeaderComponent(), StopWatchComponent()]),
    ],
  ).run();
}
