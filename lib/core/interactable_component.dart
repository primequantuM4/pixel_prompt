import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// A base class for components that support interaction, focus, hover, and input.
///
/// [InteractableComponent] defines the lifecycle for UI elements that can receive
/// user input (e.g., keypresses, mouse events), be focused, hovered, and clicked.
///
/// Subclasses must implement the interaction lifecycle methods:
/// - [onFocus]
/// - [onBlur]
/// - [onHover]
/// - [onClick]
/// - [handleInput]
///
/// This class works in conjunction with the [RenderManager] to notify the system
/// when the component needs to be redrawn via [markDirty].
///
/// It also exposes overridable flags for interactivity:
/// - [isFocusable]: whether the component can be focused
/// - [isHoverable]: whether it can be hovered
/// - [wantsInput]: whether it actively listens for input events
///
/// Components that extend this must be part of a widget tree managed by a
/// [RenderManager] for state updates and re-rendering to function correctly.
abstract class InteractableComponent extends Component {
  /// The render manager responsible for repaint and state coordination.
  ///
  /// Must be assigned for [markDirty] to trigger UI updates.
  RenderManager? renderManager;

  /// Whether this component is currently focused.
  bool isFocused = false;

  /// Whether this component is currently being hovered.
  bool isHovered = false;

  /// Whether this component can receive focus.
  ///
  /// Override to return `true` if the component should be focusable.
  bool get isFocusable => false;

  /// Whether this component can be hovered.
  ///
  /// Override to return `true` if the component should respond to hover state.
  bool get isHoverable => false;

  /// Whether this component wants to receive input events.
  ///
  /// Override to return `true` if the component handles input directly.
  bool get wantsInput => false;

  /// Removes focus and hover state from this component.
  ///
  /// Triggers the [onBlur] lifecycle method.

  void blur() {
    isFocused = false;
    isHovered = false;
    onBlur();

    return;
  }

  /// Gives focus to this component.
  ///
  /// Triggers the [onFocus] lifecycle method.
  void focus() {
    isFocused = true;
    onFocus();

    return;
  }

  /// Marks this component as hovered.
  ///
  /// Triggers the [onHover] lifecycle method.
  void hover() {
    isHovered = true;
    onHover();

    return;
  }

  /// Removes hover state from this component.
  void unhover() {
    isHovered = false;
    return;
  }

  /// Called when the component gains focus.
  void onFocus();

  /// Called when the component loses focus.
  void onBlur();

  /// Called when the component is hovered.
  void onHover();

  /// Called when the component is clicked.
  void onClick();

  /// Handles raw input events from the input system.
  ///
  /// Must return a [ResponseInput] to indicate whether the event was consumed.
  ResponseInput handleInput(InputEvent event);
}
