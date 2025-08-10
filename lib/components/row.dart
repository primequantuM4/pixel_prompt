import 'dart:math';

import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/components/column.dart';

/// A [Row] arranges its child [Component] widgets horizontally in sequence.
///
/// The [Row] is a layout component that places its children from left to right,
/// respecting their intrinsic sizes and any horizontal gaps specified via
/// [childGap]. It does not scroll; if content overflows the available space,
/// it will be clipped by the parent.
///
/// ### Layout Behavior
/// - Each child is measured based on the maximum available size.
/// - The overall height is the maximum height of its children.
/// - The overall width is the sum of its children's widths, plus
///   the [childGap] between each.
///
/// ### Example
/// ```dart
/// final row = Row(
///   children: [
///     TextComponent("Hello"),
///     TextComponent("World"),
///   ],
///   childGap: 2,
/// );
/// ```
///
/// ### See Also
/// - [Column] for vertical layouts.
/// - [ParentComponentInstance] for parent-child layout handling.
/// - [CanvasBuffer] for rendering operations.
/// {@category Components}
/// {@category Layout}
class Row extends Component {
  /// The list of child [Component]s to be displayed horizontally.
  final List<Component> children;

  /// The number of columns (in terminal cells) to leave between each child.
  ///
  /// Defaults to `1`.
  final int childGap;

  /// Creates a new [Row] layout.
  ///
  /// The [children] parameter must not be null.
  const Row({required this.children, this.childGap = 1});

  @override
  ComponentInstance createInstance() => _RowInstance(this);
}

/// Internal runtime instance of a [Row] for layout and rendering.
///
/// This class manages the lifecycle, measurement, and rendering of
/// [Row] children in a live UI tree.
///
/// **Note:** This is not meant to be used directly. Instead, construct
/// a [Row] and let the framework manage its instance.
/// {@category Components}
/// {@category Layout}
class _RowInstance extends ParentComponentInstance {
  /// The [Row] component definition from which this instance was created.
  final Row component;

  /// The lazily created list of child component instances.
  final List<ComponentInstance> _childrenInstance;

  @override
  Axis get direction => Axis.horizontal;

  /// Creates a [_RowInstance] from a [Row] definition.
  _RowInstance(this.component)
    : _childrenInstance = component.children
          .map((comp) => comp.createInstance())
          .toList(),
      super(component);

  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  /// Measures the total size of the row given the available [maxSize].
  ///
  /// - Skips measuring children with absolute positioning.
  /// - The total width is the sum of all children's widths, plus spacing.
  /// - The height is the maximum child height.
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

  /// Renders the row and its children into the [buffer] within the given [bounds].
  ///
  /// Each child is rendered within its own calculated bounds.
  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      child.render(buffer, child.bounds);
    }
  }

  /// Returns the maximum height required to fit the tallest child.
  @override
  int fitHeight() {
    int maxHeight = 0;
    for (final child in childrenInstance) {
      maxHeight = max(maxHeight, child.fitHeight());
    }
    return maxHeight;
  }

  /// Returns the total width required to fit the row's children,
  /// including [childGap] spacing.
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
