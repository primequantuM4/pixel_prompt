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
  InteractableComponentInstance({super.padding, super.position});
  bool isFocused = false;
  bool isHovered = false;

  bool get isFocusable => false;
  bool get isHoverable => false;
  bool get wantsInput => false;

  RenderManager? renderManager;

  void focus() {
    isFocused = true;
    onFocus();
  }

  void blur() {
    isFocused = false;
    isHovered = false;
    onBlur();
  }

  void hover() {
    isHovered = true;
    onHover();
  }

  void unhover() {
    isHovered = false;
  }

  void onFocus();
  void onBlur();
  void onHover();
  void onClick();

  ResponseInput handleInput(InputEvent event);
}
