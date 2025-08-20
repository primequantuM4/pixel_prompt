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

/// The engine responsible for measuring and positioning components
/// in the terminal UI.
///
/// A [LayoutEngine] recursively measures components starting from
/// the root [ComponentInstance], assigns bounds, and produces a list
/// of [PositionedComponentInstance]s ready for rendering.
///
/// ### Responsibilities
/// - Measure components using their [ComponentInstance.measure] method.
/// - Apply layout direction ([Axis.horizontal] or [Axis.vertical]).
/// - Account for padding, gaps, and absolute positioning.
/// - Record which component renders each child.
///
/// ### Lifecycle
/// - Created by the application’s renderer before layout computation.
/// - `compute` is called to produce layout results.
/// - Internal `_layoutRecursiveCompute` is called recursively to
///   measure and assign bounds to all child components.
///
/// ### See also
/// - [ParentComponentInstance] — For components that can contain children.
/// - [PositionedComponentInstance] — Holds final position data.
/// - [Axis] — Layout direction.
/// - [Rect] — Defines positions and sizes.
///
/// ### Example
/// ```dart
/// final engine = LayoutEngine(
///   rootInstance: myRoot,
///   children: myRoot.childrenInstance,
///   direction: Axis.vertical,
///   bounds: Rect(x: 0, y: 0, width: 80, height: 24),
///   childGap: 1,
/// );
/// final positioned = engine.compute(Size(width: 80, height: 24));
/// ```
///
/// {@category Layout}
class LayoutEngine {
  /// The root component in the layout hierarchy.
  final ComponentInstance rootInstance;

  /// Direct children of the root instance.
  final List<ComponentInstance> children;

  /// Layout direction for children.
  final Axis direction;

  /// The total bounds available for layout.
  final Rect bounds;

  /// Gap between children in the specified layout direction.
  final int childGap;

  /// Stores the final positioned results after computation.
  final List<PositionedComponentInstance> result = [];

  LayoutEngine({
    required this.rootInstance,
    required this.children,
    required this.direction,
    required this.bounds,
    this.childGap = 0,
  });

  /// Computes the layout starting from [rootInstance].
  ///
  /// Returns a list of [PositionedComponentInstance] with final positions
  /// and sizes for rendering.
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

  /// Recursively computes the position and size of [componentInstance]
  /// and its children.
  ///
  /// Assigns [Rect] bounds to each component and adds the result
  /// to the [result] list.
  void _layoutRecursiveCompute(
    ComponentInstance componentInstance,
    Rect bounds,
  ) {
    componentInstance.bounds = bounds;

    Logger.trace(
      "LayoutEngine",
      "Component $componentInstance with bounds ${componentInstance.bounds.toString()}",
    );

    // Stop if this is not a container
    if (componentInstance is! ParentComponentInstance) return;

    if (componentInstance is StatefulComponentInstance) {
      Logger.trace(
        "LayoutEngine",
        "Component $componentInstance is assigning children bounds ${componentInstance.bounds}",
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

  /// Computes the total width needed to fit all [children]
  /// based on [direction] and [childGap].
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

    return requiredWidth + 20;
  }

  /// Computes the total height needed to fit all [children]
  /// based on [direction] and [childGap].
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

    return requiredHeight + 10;
  }
}
