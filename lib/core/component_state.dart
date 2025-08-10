import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/stateful_component.dart';

/// Signature for functions with no arguments and no return value.
typedef VoidCallback = void Function();

/// Base class for managing the state of a [StatefulComponent].
///
/// A `ComponentState` represents the mutable data and behavior
/// associated with a [StatefulComponent] instance. The framework
/// will create a [ComponentState] object when a [StatefulComponent]
/// is inserted into the component tree, and may call its lifecycle
/// methods during rendering.
///
/// ### Responsibilities:
/// - Hold and mutate state that affects how the component is built.
/// - Build and return a tree of child [Component]s via [build].
/// - Notify the framework to rebuild when state changes via [setState].
///
/// ### Lifecycle:
/// - [initState] is called once when the state object is first created.
/// - [build] is called whenever the component needs to render itself.
/// - [setState] is used to schedule a rebuild after mutating state.
///
///
/// {@category Core}
/// {@category Components}
/// {@category State Management}
abstract class ComponentState<T extends StatefulComponent> {
  /// The associated [StatefulComponent] that owns this state.
  late T component;

  /// The concrete instance for this [StatefulComponent] in the tree.
  late StatefulComponentInstance instance;

  /// Called exactly once when the state is initialized.
  /// Override to set up state, subscribe to data sources, etc.
  void initState() {}

  /// Describes the component subtree for this state.
  /// Called every time the component needs to rebuild.
  List<Component> build();

  /// Marks this state as dirty and schedules a rebuild.
  ///
  /// - Executes the given callback [fn] to mutate the state.
  /// - Triggers the owning instance and the app to rebuild.
  void setState(VoidCallback fn) {
    fn();
    instance.rebuild();
    AppInstance.instance.requestRebuild();
  }
}
