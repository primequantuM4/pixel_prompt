import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/stateful_component.dart';

abstract class ComponentState<T extends StatefulComponent> {
  late T component;

  void initState() {}

  List<Component> build();

  void setState(VoidCallback fn) {
    fn();
    component.rebuild();
    App.instance.requestRebuild();
  }
}
