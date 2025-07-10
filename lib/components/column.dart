import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

class Column extends Component with ParentComponent {
  @override
  final List<Component> children;
  final int childGap;

  Column({required this.children, this.childGap = 1});

  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    for (final child in children) {
      if (child.position?.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalHeight += childSize.height;

      maxWidth = max(childSize.width, maxWidth);
    }

    return Size(width: maxWidth, height: totalHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in children) {
      child.render(buffer, child.bounds);
    }
  }

  @override
  int fitHeight() {
    int total = 0;
    for (final child in children) {
      total += child.fitHeight();
    }

    total += max(0, children.length - 1) * childGap;
    return total;
  }

  @override
  int fitWidth() {
    int maxWidth = 0;

    for (final child in children) {
      maxWidth = max(child.fitWidth(), maxWidth);
    }

    return maxWidth;
  }
}
