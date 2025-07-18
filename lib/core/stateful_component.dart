import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

abstract class StatefulComponent extends Component {
  const StatefulComponent();

  @override
  ComponentInstance createInstance() => StatefulComponentInstance(this);

  ComponentState createState();
}

class StatefulComponentInstance extends ParentComponentInstance {
  final StatefulComponent component;
  List<Component>? _children;
  List<ComponentInstance>? _childrenInstances;

  final int childGap = 1;
  ComponentState? _state;

  RenderManager? renderManager;

  StatefulComponentInstance(this.component) : super(component) {
    _children ??= state.build();
  }

  ComponentState get state {
    _state ??= _initState();
    return _state!;
  }

  ComponentState _initState() {
    final newState = component.createState();
    newState.component = component;
    newState.instance = this;
    newState.initState();

    return newState;
  }

  @override
  List<ComponentInstance> get childrenInstance {
    if (_childrenInstances == null) {
      _children ??= state.build();
      _childrenInstances =
          _children!.map((comp) => comp.createInstance()).toList();
    }
    return _childrenInstances!;
  }

  set children(List<Component> newChildren) => _children = newChildren;

  @override
  int fitHeight() {
    int height = 0;

    for (final child in childrenInstance) {
      height += child.fitHeight();
    }

    height += max(0, childrenInstance.length - 1) * childGap;
    return height;
  }

  void rebuild() {
    _children = state.build();
    _childrenInstances = null;
  }

  @override
  int fitWidth() {
    int width = 0;

    for (final child in childrenInstance) {
      width = max(child.fitWidth(), width);
    }

    return width;
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      Logger.trace("StatefulComponent", "Item $child is being rendered");
      child.render(buffer, child.bounds);
    }
  }
}
