import 'dart:math';

import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// A [Component] that has an associated mutable [ComponentState].
///
/// A `StatefulComponent` allows encapsulating local state and rebuilding
/// its widget tree when that state changes. The state is represented by a
/// [ComponentState] subclass, which is created via [createState].
///
/// The runtime representation is a [StatefulComponentInstance], which holds
/// the component’s state, builds its children, and coordinates rendering.
///
/// ### Lifecycle:
/// 1. [StatefulComponentInstance] is created.
/// 2. [createState] is called once to produce the associated state.
/// 3. [ComponentState.initState] runs before the first [ComponentState.build].
/// 4. State changes trigger [ComponentState.setState], causing a rebuild.
///
/// ### See also:
/// - [ComponentState] — manages the mutable state for a `StatefulComponent`.
/// - [StatefulComponentInstance] — runtime instance of a `StatefulComponent`.
///
/// {@category Core}
/// {@category Components}
/// {@category State Management}
abstract class StatefulComponent extends Component {
  const StatefulComponent();

  @override
  ComponentInstance createInstance() => StatefulComponentInstance(this);

  ComponentState createState();
}

/// Runtime instance of a [StatefulComponent].
///
/// A `StatefulComponentInstance` owns and manages the [ComponentState]
/// for its [StatefulComponent], builds its child components, and
/// coordinates their layout and rendering.
///
/// ### Responsibilities:
/// - Initialize and hold a single [ComponentState] instance.
/// - Build and cache child [ComponentInstance]s.
/// - Rebuild children when requested by the state.
/// - Perform layout measurement via [fitWidth], [fitHeight], and [measure].
/// - Render children to a [CanvasBuffer].
///
/// ### Lifecycle:
/// - Created from a [StatefulComponent].
/// - Lazily creates the state when [state] is first accessed.
/// - [rebuild] replaces the child component tree using [ComponentState.build].
///
/// ### See also:
/// - [StatefulComponent] — defines the component’s configuration.
/// - [ComponentState] — holds mutable state and triggers rebuilds.
/// - [ParentComponentInstance] — base class for components with children.
class StatefulComponentInstance extends ParentComponentInstance {
  /// The configuration for this component instance.
  final StatefulComponent component;

  /// The list of child components returned by [ComponentState.build].
  List<Component>? _children;

  /// Cached runtime instances for [_children].
  List<ComponentInstance>? _childrenInstances;

  /// Vertical spacing between children when laid out.
  final int childGap = 1;

  /// The mutable state associated with this component.
  ComponentState? _state;

  /// The render manager that may schedule renders for this instance.
  RenderManager? renderManager;

  /// Creates a new [StatefulComponentInstance] for the given [component].
  ///
  /// Immediately triggers an initial build of the child components
  /// via [state.build], which itself lazily initializes the state.
  StatefulComponentInstance(this.component) : super(component) {
    _children ??= state.build();
  }

  /// Lazily initializes and returns this component’s state.
  ///
  /// The state is created via [StatefulComponent.createState],
  /// linked to this instance, and its [ComponentState.initState] is called.
  ComponentState get state {
    _state ??= _initState();
    return _state!;
  }

  /// Internal helper to create and initialize the [ComponentState].
  ComponentState _initState() {
    final newState = component.createState();
    newState.component = component;
    newState.instance = this;
    newState.initState();
    return newState;
  }

  /// Returns the list of runtime child instances.
  ///
  /// If this is the first time it’s accessed or after a [rebuild],
  /// the children are built from the current [state] and
  /// converted into [ComponentInstance] objects.
  @override
  List<ComponentInstance> get childrenInstance {
    if (_childrenInstances == null) {
      _children ??= state.build();
      _childrenInstances = _children!
          .map((comp) => comp.createInstance())
          .toList();
    }
    return _childrenInstances!;
  }

  /// Replaces the list of child components without building them.
  set children(List<Component> newChildren) => _children = newChildren;

  /// Calculates the total height required to fit all children,
  /// including the [childGap] between them.
  @override
  int fitHeight() {
    int height = 0;
    for (final child in childrenInstance) {
      height += child.fitHeight();
    }
    height += max(0, childrenInstance.length - 1) * childGap;
    return height;
  }

  /// Rebuilds the child component list from the current [state].
  ///
  /// This clears the cached [ComponentInstance]s so they
  /// will be recreated on the next access.
  void rebuild() {
    _children = state.build();
    _childrenInstances = null;
  }

  /// Calculates the maximum width required to fit all children.
  @override
  int fitWidth() {
    int width = 0;
    for (final child in childrenInstance) {
      width = max(child.fitWidth(), width);
    }
    return width;
  }

  /// Measures the size this component would take given [maxSize].
  ///
  /// This delegates to [fitWidth] and [fitHeight].
  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  /// Renders all children into the given [buffer] within [bounds].
  ///
  /// Logs each render action for tracing via [Logger.trace].
  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in childrenInstance) {
      Logger.trace("StatefulComponent", "Item $child is being rendered");
      child.render(buffer, child.bounds);
    }
  }
}
