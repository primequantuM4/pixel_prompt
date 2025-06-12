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

  Row({required this.children});

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
      bounds: bounds,
    );

    final positionedItems = engine.compute();

    for (final item in positionedItems) {
      item.component.render(buffer, item.rect);
    }
  }

  @override
  int fitHeight() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }

  @override
  int fitWidth() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }
}
