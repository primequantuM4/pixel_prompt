import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

class Column extends Component {
  final List<Component> children;
  final int childGap;

  const Column({required this.children, this.childGap = 1});
  @override
  ComponentInstance createInstance() => _ColumnInstance(this);
}

class _ColumnInstance extends ParentComponentInstance {
  final Column component;

  final List<ComponentInstance> _childrenInstance;
  _ColumnInstance(this.component)
      : _childrenInstance = component.children
            .map((Component comp) => comp.createInstance())
            .toList(),
        super(component);
  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    for (final child in childrenInstance) {
      if (child.position.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalHeight += childSize.height;

      maxWidth = max(childSize.width, maxWidth);
    }

    return Size(width: maxWidth, height: totalHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      child.render(buffer, child.bounds);
    }
  }

  @override
  int fitHeight() {
    int total = 0;
    for (final child in childrenInstance) {
      total += child.fitHeight();
    }

    total += max(0, childrenInstance.length - 1) * component.childGap;
    return total;
  }

  @override
  int fitWidth() {
    int maxWidth = 0;

    for (final child in childrenInstance) {
      maxWidth = max(child.fitWidth(), maxWidth);
    }

    return maxWidth;
  }
}
