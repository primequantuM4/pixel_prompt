import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';
import 'package:pixel_prompt/core/rect.dart';

/// Represents a [ComponentInstance] with its assigned [Rect] bounds,
/// optionally linked to the parent component responsible for rendering it.
///
/// Used by the [LayoutEngine] to provide the renderer with the final
/// layout result for each component.
///
/// ### See also
/// - [LayoutEngine] — Produces positioned components.
/// - [Rect] — The position and size of the component.
///
/// ### Example
/// ```dart
/// final positioned = PositionedComponentInstance(
///   componentInstance: myComponent,
///   rect: Rect(x: 0, y: 0, width: 10, height: 2),
///   parentComponentInstance: parent,
/// );
/// ```
///
/// {@category Layout}
class PositionedComponentInstance {
  /// The component being positioned.
  ComponentInstance componentInstance;

  /// The final bounds of the component.
  final Rect rect;

  /// The parent component that will render this instance,
  /// or `null` if the renderer handles it directly.
  ComponentInstance? parentComponentInstance;

  PositionedComponentInstance({
    required this.componentInstance,
    required this.rect,
    this.parentComponentInstance,
  });
}
