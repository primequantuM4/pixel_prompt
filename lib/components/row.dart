import 'dart:math';

import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';

class Row extends Component with ParentComponent {
  @override
  final List<Component> children;

  final int childGap;

  Row({required this.children, this.childGap = 1});

  @override
  Size measure(Size maxSize) {
    int maxHeight = 0;
    int totalWidth = 0;

    for (final child in children) {
      if (child.position?.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalWidth += childSize.width;

      maxHeight = max(childSize.height, maxHeight);
    }

    return Size(width: totalWidth, height: maxHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final engine = LayoutEngine(
      children: children,
      direction: Axis.horizontal,
      childGap: childGap,
      bounds: bounds,
    );

    final positionedItems = engine.compute();

    for (final item in positionedItems) {
      item.component.render(buffer, item.rect);
    }
  }

  @override
  int fitHeight() {
    int maxHeight = 0;

    for (final child in children) {
      maxHeight = max(maxHeight, child.fitHeight());
    }

    return maxHeight;
  }

  @override
  int fitWidth() {
    int total = 0;

    for (final child in children) {
      total += child.fitWidth();
    }

    total += max(0, children.length - 1) * childGap;

    return total;
  }
}
