import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';

abstract class BuildableComponent extends Component {
  const BuildableComponent();
  @override
  BuildableComponentInstance createInstance() =>
      BuildableComponentInstance(this);
  List<Component> build();
}

class BuildableComponentInstance extends ParentComponentInstance {
  final BuildableComponent component;
  final List<ComponentInstance> _childrenInstance;

  final int childGap = 1;

  static const String _tag = 'BuildableComponentInstance';

  BuildableComponentInstance(this.component)
    : _childrenInstance = component
          .build()
          .map((Component comp) => comp.createInstance())
          .toList(),
      super(component);

  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  @override
  int fitHeight() {
    int height = 0;

    for (final child in childrenInstance) {
      height += child.fitHeight();
    }

    height += max(0, childrenInstance.length - 1) * childGap;
    return height;
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
    for (var child in childrenInstance) {
      Logger.trace(_tag, 'Item $child being rendered');
      child.render(buffer, child.bounds);
    }
  }
}
