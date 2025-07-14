import 'dart:math';

import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/pixel_prompt.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

typedef VoidCallback = void Function();

abstract class StatefulComponent extends Component with ParentComponent {
  final int childGap = 1;
  RenderManager? renderManager;

  StatefulComponent({this.renderManager});
  ComponentState? _state;
  List<Component>? _children;

  ComponentState get state {
    _state ??= _initializeState();
    return _state!;
  }

  List<Component> get _builtChildren {
    _children ??= state.build();
    return _children!;
  }

  ComponentState _initializeState() {
    final newState = createState();
    newState.component = this;
    newState.initState();
    return newState;
  }

  /// Must be implemented by each component class to provide its state
  ComponentState createState();

  /// Used by layout and rendering engines
  @override
  List<Component> get children => _builtChildren;

  /// Allows testing override or advanced cases
  set children(List<Component> newChildren) => _children = newChildren;

  /// Rebuilds children from state
  void rebuild() {
    _children = state.build();
  }

  @override
  int fitHeight() {
    int height = 0;

    for (final child in children) {
      height += child.fitHeight();
    }

    height += max(0, children.length - 1) * childGap;
    return height;
  }

  @override
  int fitWidth() {
    int width = 0;

    for (final child in children) {
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
    for (final child in children) {
      Logger.trace("StatefulComponent", "Item $child is being rendered");
      child.render(buffer, child.bounds);
    }
  }
}
