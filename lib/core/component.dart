import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/position.dart';

/// The base class for all renderable UI components.
///
/// A [Component] defines the minimal contract for a terminal UI element,
/// including its padding, optional position, and the ability to create
/// a corresponding [ComponentInstance] for rendering.
///
/// Components are immutable configuration objects. They are not directly
/// rendered; instead, they produce [ComponentInstance] objects that handle
/// rendering and state management.
///
/// Example:
/// ```dart
/// class MyButton extends Component {
///   const MyButton({super.padding, super.position});
///
///   @override
///   ComponentInstance createInstance() {
///     return MyButtonInstance();
///   }
/// }
/// ```
///
/// See also:
/// - [EdgeInsets] for defining padding
/// - [Position] for specifying placement
abstract class Component {
  /// The padding inside the component’s layout bounds.
  ///
  /// Defaults to [EdgeInsets.all] with a value of 0.
  final EdgeInsets padding;

  /// The position of the component within its parent or layout.
  ///
  /// If `null`, the component’s placement is determined by the layout system.
  final Position? position;

  /// Creates a [Component] with optional [padding] and [position].
  const Component({this.padding = const EdgeInsets.all(0), this.position});

  /// Creates a [ComponentInstance] that can be rendered.
  ///
  /// Must be implemented by concrete subclasses to provide the instance
  /// responsible for managing this component's rendering and state.
  ComponentInstance createInstance();
}
