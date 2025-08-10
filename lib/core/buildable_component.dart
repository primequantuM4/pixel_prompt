import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/core/stateful_component.dart';

/// A [Component] that does not require mutable state.
///
/// A [BuildableComponent] is a component whose output is determined entirely by its configuration and does not hold mutable state.
/// It describes part of the UI purely from its configuration and builds
/// a tree of other components that represent its contents.
///
/// The [build] method is called when the [BuildableComponentInstance] is
/// created, producing a fixed set of child [Component]s for rendering.
/// Any change in appearance or layout requires creating a new
/// [BuildableComponent] with updated configuration.
///
/// For dynamic or interactive components that depend on internal state,
/// use a [StatefulComponent] instead.
///
/// Example:
/// ```dart
/// class Menu extends BuildableComponent {
///   final List<String> items;
///
///   const Menu(this.items);
///
///   @override
///   List<Component> build() {
///     return items.map((label) => TextComponent(label)).toList();
///   }
/// }
/// ```
///
/// ## Performance considerations
///
/// Because a [BuildableComponent] has no internal state, it can be reused
/// and rebuilt efficiently. To maximize performance:
///
/// - Use `const` constructors where possible.
/// - Keep the [build] method minimal, avoiding unnecessary nested components.
///
/// See also:
/// - [BuildableComponentInstance] for the runtime representation.
/// - [StatefulComponent] for stateful, mutable UI.
///
/// {@category Core}
/// {@category Components}
abstract class BuildableComponent extends Component {
  /// Creates a stateless, buildable component.
  const BuildableComponent();

  @override
  BuildableComponentInstance createInstance() =>
      BuildableComponentInstance(this);

  /// Builds and returns the list of child [Component]s for this component.
  ///
  /// Called once when creating the runtime [BuildableComponentInstance].
  List<Component> build();
}

/// The runtime instance of a [BuildableComponent].
///
/// A [BuildableComponentInstance] is created when a stateless
/// [BuildableComponent] is inserted into the layout.
/// It holds the concrete [ComponentInstance]s for all children built
/// by the [BuildableComponent]'s [build] method.
///
/// The instance:
/// - Measures and reports its total size based on its children.
/// - Stacks children vertically, separated by [childGap] spaces.
/// - Renders each child in its assigned [bounds].
///
/// Example:
/// ```dart
/// final menuInstance = Menu(['Home', 'About', 'Exit']).createInstance();
/// final size = menuInstance.measure(Size(width: 80, height: 24));
/// menuInstance.render(buffer, someBounds);
/// ```
///
/// See also:
/// - [BuildableComponent] for the configuration object.
/// - [ParentComponentInstance] for shared child-management behavior.
///
/// {@category Core}
/// {@category Components}
class BuildableComponentInstance extends ParentComponentInstance {
  /// The stateless [BuildableComponent] configuration for this instance.
  final BuildableComponent component;

  /// The list of instantiated child components.
  final List<ComponentInstance> _childrenInstance;

  /// Vertical spacing between stacked children.
  final int childGap = 1;

  static const String _tag = 'BuildableComponentInstance';

  /// Creates an instance from the given [component], immediately
  /// building and instantiating its children.
  BuildableComponentInstance(this.component)
    : _childrenInstance = component
          .build()
          .map((comp) => comp.createInstance())
          .toList(),
      super(component);

  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  @override
  int fitHeight() {
    int height = 0;
    for (final child in childrenInstance) {
      height += child.fitHeight();
    }
    height += max(0, childrenInstance.length - 1) * childGap;
    return height;
  }

  @override
  int fitWidth() {
    int width = 0;
    for (final child in childrenInstance) {
      width = max(child.fitWidth(), width);
    }
    return width;
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (var child in childrenInstance) {
      Logger.trace(_tag, 'Item $child being rendered');
      child.render(buffer, child.bounds);
    }
  }
}
