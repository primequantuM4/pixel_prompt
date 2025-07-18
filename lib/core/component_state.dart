import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/stateful_component.dart';

typedef VoidCallback = void Function();

abstract class ComponentState<T extends StatefulComponent> {
  late T component;
  late StatefulComponentInstance instance;

  void initState() {}

  List<Component> build();

  void setState(VoidCallback fn) {
    fn();
    instance.rebuild();
    AppInstance.instance.requestRebuild();
  }
}
