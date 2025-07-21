import 'dart:math';

import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

class Row extends Component {
  final List<Component> children;
  final int childGap;

  const Row({required this.children, this.childGap = 1});
  @override
  ComponentInstance createInstance() => _RowInstance(this);
}

class _RowInstance extends ParentComponentInstance {
  final Row component;
  final List<ComponentInstance> _childrenInstance;

  @override
  Axis get direction => Axis.horizontal;

  _RowInstance(this.component)
      : _childrenInstance =
            component.children.map((e) => e.createInstance()).toList(),
        super(component);
  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  @override
  Size measure(Size maxSize) {
    int maxHeight = 0;
    int totalWidth = 0;

    for (final child in childrenInstance) {
      if (child.position.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalWidth += childSize.width;

      maxHeight = max(childSize.height, maxHeight);
    }

    if (childrenInstance.length > 1) {
      totalWidth += (childrenInstance.length - 1) * component.childGap;
    }

    return Size(width: totalWidth, height: maxHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      child.render(buffer, child.bounds);
    }
  }

  @override
  int fitHeight() {
    int maxHeight = 0;

    for (final child in childrenInstance) {
      maxHeight = max(maxHeight, child.fitHeight());
    }

    return maxHeight;
  }

  @override
  int fitWidth() {
    int total = 0;

    for (final child in childrenInstance) {
      total += child.fitWidth();
    }

    total += max(0, childrenInstance.length - 1) * component.childGap;

    return total;
  }
}
