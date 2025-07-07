import 'dart:math';

import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/stateful_component.dart';
import 'package:pixel_prompt/logger/logger.dart';

import 'positioned_component.dart';

class LayoutEngine {
  final ComponentInstance rootInstance;
  final List<ComponentInstance> children;
  final Axis direction;
  final Rect bounds;
  final int childGap;

  final List<PositionedComponentInstance> result = [];

  LayoutEngine({
    required this.rootInstance,
    required this.children,
    required this.direction,
    required this.bounds,
    this.childGap = 1,
  });

  List<PositionedComponentInstance> compute(Size maxSize) {
    final Size measured = rootInstance.measure(maxSize);
    final Rect rootBounds = Rect(
      x: 0,
      y: 0,
      width: measured.width,
      height: measured.height,
    );
    _layoutRecursiveCompute(rootInstance, rootBounds);

    return result;
  }

  void _layoutRecursiveCompute(
    ComponentInstance componentInstance,
    Rect bounds,
  ) {
    componentInstance.bounds = bounds;

    Logger.trace(
      "LayoutEngine",
      "Component $componentInstance with bounds ${componentInstance.bounds.toString()}",
    );

    if (componentInstance is! ParentComponentInstance) return; // base case

    if (componentInstance is StatefulComponentInstance) {
      Logger.trace(
        "LayoutEngine",
        "Component $componentInstance is trying to assign children with bounds ${componentInstance.bounds.toString()}",
      );
      for (var child in componentInstance.childrenInstance) {
        Logger.trace("LayoutEngine", "Child is $child");
      }
    }

    final innerRect = Rect(
      x: bounds.x + componentInstance.padding.left,
      y: bounds.y + componentInstance.padding.top,
      width: bounds.width - componentInstance.padding.horizontal,
      height: bounds.height - componentInstance.padding.vertical,
    );

    int cursorX = innerRect.x;
    int cursorY = innerRect.y;

    for (var child in componentInstance.childrenInstance) {
      final maxSize = Size(width: bounds.width, height: bounds.height);
      final size = child.measure(maxSize);

      final pos = child.position;
      final isAbsolute = pos.positionType == PositionType.absolute;

      final rect = isAbsolute
          ? Rect(
              x: innerRect.x + pos.x,
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
      bool isRenderedByParent = componentInstance.shouldRenderChild(child);
      result.add(
        PositionedComponentInstance(
          componentInstance: child,
          rect: rect,
          parentComponentInstance: isRenderedByParent
              ? componentInstance
              : null,
        ),
      );
      _layoutRecursiveCompute(child, rect);

      if (!isAbsolute) {
        if (componentInstance.direction == Axis.vertical) {
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
