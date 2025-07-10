import 'dart:math';

import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/core/position.dart';

import 'positioned_component.dart';

class LayoutEngine {
  final Component root;
  final List<Component> children;
  final Axis direction;
  final Rect bounds;
  final int childGap;

  final List<PositionedComponent> result = [];

  LayoutEngine({
    required this.root,
    required this.children,
    required this.direction,
    required this.bounds,
    this.childGap = 1,
  });

  List<PositionedComponent> compute(Size maxSize) {
    final Size measured = root.measure(maxSize);
    final Rect rootBounds =
        Rect(x: 0, y: 0, width: measured.width, height: measured.height);
    _layoutRecursiveCompute(root, rootBounds);

    return result;
  }

  void _layoutRecursiveCompute(Component component, Rect bounds) {
    component.bounds = bounds;

    if (component is! ParentComponent) return; // base case

    final innerRect = Rect(
      x: bounds.x + component.padding.left,
      y: bounds.y + component.padding.top,
      width: bounds.width - component.padding.horizontal,
      height: bounds.height - component.padding.vertical,
    );

    int cursorX = innerRect.x;
    int cursorY = innerRect.y;

    for (var child in component.children) {
      final maxSize = Size(width: bounds.width, height: bounds.height);
      final size = child.measure(maxSize);

      final pos = child.position;
      final isAbsolute = pos?.positionType == PositionType.absolute;

      final rect = isAbsolute
          ? Rect(
              x: innerRect.x + pos!.x,
              y: innerRect.y + pos.y,
              width: size.width,
              height: size.height,
            )
          : Rect(
              x: cursorX,
              y: cursorY,
              width: size.width,
              height: size.height,
            );
      child.bounds = rect;
      result.add(PositionedComponent(component: child, rect: rect));
      _layoutRecursiveCompute(child, rect);

      if (!isAbsolute) {
        if (component.direction == Axis.vertical) {
          cursorY += size.height + childGap;
        } else {
          cursorX += size.width + childGap;
        }
      }
    }
  }

  int fitWidth() {
    if (children.isEmpty) return 0;
    int requiredWidth = 0;

    if (direction == Axis.horizontal) {
      requiredWidth += ((children.length - 1) * childGap);
    }

    for (var child in children) {
      if (direction == Axis.horizontal) {
        requiredWidth += child.fitWidth();
      } else {
        requiredWidth = max(child.fitWidth(), requiredWidth);
      }
    }

    return requiredWidth;
  }

  int fitHeight() {
    if (children.isEmpty) return 0;
    int requiredHeight = 0;

    if (direction == Axis.vertical) {
      requiredHeight += ((children.length - 1) * childGap);
    }

    for (var child in children) {
      if (direction == Axis.vertical) {
        requiredHeight += child.fitHeight();
      } else {
        requiredHeight = max(requiredHeight, child.fitHeight());
      }
    }

    return requiredHeight;
  }
}
