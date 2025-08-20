import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/app.dart';

/// Base class for a component instance that has child components.
///
/// A `ParentComponentInstance` represents a [ComponentInstance]
/// that can contain other [ComponentInstance]s, and optionally
/// control their layout direction and rendering behavior.
/// ### See also:
/// - [ComponentInstance] — the base interface for all component instances.
/// - [AppInstance] — a specialized parent instance that owns the application's root component tree.
///
/// {@category Core}
/// {@category Components}
/// {@category Layout}
abstract class ParentComponentInstance extends ComponentInstance {
  /// The direct child component instances managed by this parent.
  List<ComponentInstance> get childrenInstance;

  /// The primary axis along which children are laid out.
  /// Defaults to vertical stacking.
  Axis get direction => Axis.vertical;

  /// Determines whether a given [child] should be rendered.
  /// Defaults to `false`, meaning the decision is left to layout/rendering code.
  bool shouldRenderChild(ComponentInstance child) => false;

  /// Creates a parent component instance for the given [component].
  ///
  /// The [component] parameter defines the component type and properties
  /// that this instance will represent and manage.
  ParentComponentInstance(Component component);
}
