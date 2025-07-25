import 'dart:async';

import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/button_component.dart';
import 'package:pixel_prompt/core/buildable_component.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/stateful_component.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class HeaderComponent extends BuildableComponent {
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

  @override
  ComponentState<StopWatchComponent> createState() => _StopWatchState();
}

class _StopWatchState extends ComponentState<StopWatchComponent> {
  String _formatTime(int millis) {
    final totalSeconds = millis ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final hundredths = ((millis % 1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$seconds.$hundredths";
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

  void start() {
    if (component.startCounting) return;
    component.startCounting = true;
    component.millisecondTimer = Timer.periodic(Duration(milliseconds: 100), (
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
