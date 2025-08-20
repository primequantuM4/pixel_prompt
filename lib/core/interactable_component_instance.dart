import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// Base class for a [ComponentInstance] that can respond to user interaction.
///
/// An `InteractableComponentInstance` adds focus, hover, and input-handling
/// capabilities to a component instance. Subclasses can override interaction
/// flags and event handlers to define custom behavior.
///
/// ### Interaction flags:
/// - [isFocusable] — whether the component can gain focus.
/// - [isHoverable] — whether the component can be hovered.
/// - [wantsInput] — whether the component requests input events when focused.
///
/// ### State:
/// - [isFocused] — whether the component is currently focused.
/// - [isHovered] — whether the component is currently hovered.
///
/// ### Event lifecycle:
/// - [focus] → [onFocus]
/// - [blur] → [onBlur]
/// - [hover] → [onHover]
/// - [onClick] — triggered on user click/tap.
/// - [handleInput] — process raw [InputEvent]s and return a [ResponseInput].
///
/// ### Rendering:
/// May optionally hold a [RenderManager] reference for rendering coordination.
///
/// ### See also:
/// - [ComponentInstance] — the base type for all renderable component instances.
/// - [ResponseInput] — standard return type for processing user input.
/// - [InputEvent] — encapsulates raw user interaction events.
///
/// {@category Core}
/// {@category Components}
/// {@category Interaction}
abstract class InteractableComponentInstance extends ComponentInstance {
  /// Creates an interactable component instance with optional layout properties.
  ///
  /// The constructor allows setting initial [padding] and [position] values
  /// which are passed to the parent [ComponentInstance] constructor.
  ///
  /// Parameters:
  /// - [padding]: Optional padding around the component's content
  /// - [position]: Optional positioning information for layout
  InteractableComponentInstance({super.padding, super.position});

  /// Indicates whether this component instance currently has input focus.
  ///
  /// When `true`, the component is the primary recipient of keyboard input
  /// and may have visual focus indicators.
  bool isFocused = false;

  /// Indicates whether the cursor is currently hovering over this component.
  ///
  /// When `true`, the component may display hover effects or tooltips.
  bool isHovered = false;

  /// Whether this component can receive focus.
  ///
  /// Override this getter to return `true` if the component should be
  /// focusable. Focusable components can be navigated to via keyboard
  /// or pointer interaction.
  bool get isFocusable => false;

  /// Whether this component can detect hover events.
  ///
  /// Override this getter to return `true` if the component should respond
  /// to mouse or pointer hover movements.
  bool get isHoverable => false;

  /// Whether this component wants to receive raw input events when focused.
  ///
  /// Override this getter to return `true` if the component should process
  /// individual input events (key presses, mouse movements) rather than
  /// relying on higher-level events like [onClick].
  bool get wantsInput => false;

  /// Optional reference to the render manager for coordinating rendering operations.
  ///
  /// When set, allows the component to request redraws or access rendering context.
  RenderManager? renderManager;

  /// Gives focus to this component.
  ///
  /// Sets [isFocused] to `true` and calls [onFocus]. Only effective if
  /// [isFocusable] returns `true`.
  void focus() {
    isFocused = true;
    onFocus();
  }

  /// Removes focus from this component.
  ///
  /// Sets both [isFocused] and [isHovered] to `false` and calls [onBlur].
  void blur() {
    isFocused = false;
    isHovered = false;
    onBlur();
  }

  /// Sets the hover state for this component.
  ///
  /// Sets [isHovered] to `true` and calls [onHover]. Only effective if
  /// [isHoverable] returns `true`.
  void hover() {
    isHovered = true;
    onHover();
  }

  /// Removes the hover state from this component.
  ///
  /// Sets [isHovered] to `false` without calling any additional handlers.
  void unhover() {
    isHovered = false;
  }

  /// Called when this component gains focus.
  ///
  /// Override this method to implement custom behavior when the component
  /// becomes focused, such as showing a focus indicator or selecting text.
  void onFocus();

  /// Called when this component loses focus.
  ///
  /// Override this method to implement custom behavior when the component
  /// loses focus, such as validating input or hiding focus indicators.
  void onBlur();

  /// Called when the cursor begins hovering over this component.
  ///
  /// Override this method to implement custom hover behavior, such as
  /// displaying tooltips or changing visual appearance.
  void onHover();

  /// Called when the user clicks or taps on this component.
  ///
  /// Override this method to handle click/tap interactions, such as
  /// submitting forms, toggling states, or navigating.
  void onClick();

  /// Processes a raw input event and returns a response.
  ///
  /// This method is called when [wantsInput] is `true` and the component
  /// is focused. It allows for low-level input processing.
  ///
  /// [event]: The input event to process (key press, mouse event, etc.)
  /// Returns a [ResponseInput] indicating how the event was handled and
  /// any resulting commands or rendering needs.
  ResponseInput handleInput(InputEvent event);
}
