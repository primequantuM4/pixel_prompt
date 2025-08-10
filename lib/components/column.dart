import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/components/row.dart';

/// A [Column] arranges its child [Component] widgets vertically in sequence.
///
/// The [Column] is a layout component that stacks its children vertically,
/// respecting their intrinsic sizes and any vertical gaps specified via
/// [childGap]. It does not scroll; if content overflows the available space,
/// it will be clipped by the parent.
///
/// ### Layout Behavior
/// - Each child is measured based on the maximum available size.
/// - The overall width is the maximum width of its children.
/// - The overall height is the sum of its children's heights, plus
///   the [childGap] between each.
///
/// ### Example
/// ```dart
/// final column = Column(
///   children: [
///     TextComponent("Hello"),
///     TextComponent("World"),
///   ],
///   childGap: 2,
/// );
/// ```
///
/// ### See Also
/// - [Row] for horizontal layouts.
/// - [ParentComponentInstance] for parent-child layout handling.
/// - [CanvasBuffer] for rendering operations.
///
/// {@category Components}
/// {@category Layout}
class Column extends Component {
  /// The list of child [Component]s to be displayed vertically.
  final List<Component> children;

  /// The number of rows (in terminal cells) to leave between each child.
  ///
  /// Defaults to `1`.
  final int childGap;

  /// Creates a new [Column] layout.
  ///
  /// The [children] parameter must not be null.
  const Column({required this.children, this.childGap = 1});

  @override
  ComponentInstance createInstance() => _ColumnInstance(this);
}

/// Internal runtime instance of a [Column] for layout and rendering.
///
/// This class manages the lifecycle, measurement, and rendering of
/// [Column] children in a live UI tree.
///
/// **Note:** This is not meant to be used directly. Instead, construct
/// a [Column] and let the framework manage its instance.
/// {@category Components}
/// {@category Layout}
class _ColumnInstance extends ParentComponentInstance {
  /// The [Column] component definition from which this instance was created.
  final Column component;

  /// The lazily created list of child component instances.
  final List<ComponentInstance> _childrenInstance;

  /// Creates a [_ColumnInstance] from a [Column] definition.
  _ColumnInstance(this.component)
    : _childrenInstance = component.children
          .map((comp) => comp.createInstance())
          .toList(),
      super(component);

  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  /// Measures the total size of the column given the available [maxSize].
  ///
  /// - Skips measuring children with absolute positioning.
  /// - The total height is the sum of all children's heights.
  /// - The width is the maximum child width.
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

  /// Renders the column and its children into the [buffer] within the given [bounds].
  ///
  /// Each child is rendered within its own calculated bounds.
  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      child.render(buffer, child.bounds);
    }
  }

  /// Returns the total height required to fit the column's children,
  /// including [childGap] spacing.
  @override
  int fitHeight() {
    int total = 0;
    for (final child in childrenInstance) {
      total += child.fitHeight();
    }
    total += max(0, childrenInstance.length - 1) * component.childGap;
    return total;
  }

  /// Returns the maximum width required to fit the widest child.
  @override
  int fitWidth() {
    int maxWidth = 0;
    for (final child in childrenInstance) {
      maxWidth = max(child.fitWidth(), maxWidth);
    }
    return maxWidth;
  }
}
