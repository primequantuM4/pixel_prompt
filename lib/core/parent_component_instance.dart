import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';

abstract class ParentComponentInstance extends ComponentInstance {
  List<ComponentInstance> get childrenInstance;
  Axis get direction => Axis.vertical;

  bool shouldRenderChild(ComponentInstance child) => false;

  ParentComponentInstance(Component component);
}
