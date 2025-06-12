import 'dart:math';

import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/core/position.dart';

import 'positioned_component.dart';

class LayoutEngine {
  final List<Component> children;
  final Axis direction;
  final Rect bounds;
  final int childGap = 1;

  LayoutEngine({
    required this.children,
    required this.direction,
    required this.bounds,
  });

  List<PositionedComponent> compute() {
    int cursorX = bounds.x;
    int cursorY = bounds.y;

    final List<PositionedComponent> result = [];

    for (final child in children) {
      final size = child.measure(
        Size(width: bounds.width, height: bounds.height),
      );

      if (child.position?.positionType == PositionType.absolute) {
        final bounds = Rect(
          x: child.position!.x,
          y: child.position!.y,
          width: size.width,
          height: size.height,
        );
        result.add(PositionedComponent(component: child, rect: bounds));
        child.setBounds(bounds);
        continue;
      }

      final xVal = direction == Axis.vertical ? bounds.x : cursorX;
      final yVal = direction == Axis.vertical ? cursorY : bounds.y;

      final Rect childBounds;
      if (child.position == null) {
        childBounds = Rect(
          x: xVal,
          y: yVal,
          width: size.width,
          height: size.height,
        );
      } else {
        childBounds = Rect(
          x: xVal + child.position!.x,
          y: yVal + child.position!.y,
          width: size.width,
          height: size.height,
        );
      }

      result.add(PositionedComponent(component: child, rect: childBounds));
      child.setBounds(childBounds);

      if (direction == Axis.vertical) {
        cursorY += size.height + childGap;
      } else {
        cursorX += size.width + childGap;
      }
    }

    return result;
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
