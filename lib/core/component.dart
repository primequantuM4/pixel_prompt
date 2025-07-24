import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/position.dart';

abstract class Component {
  final EdgeInsets padding;

  final Position? position;

  const Component({this.padding = const EdgeInsets.all(0), this.position});

  ComponentInstance createInstance();
}

mixin ParentComponent on Component {
  List<Component> get children;

  Axis get direction => Axis.vertical;

  bool shouldRenderChild(Component child) => false;
}
