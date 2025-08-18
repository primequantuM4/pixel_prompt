import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';

/// Routes input events to the currently focused interactive component.
///
/// This [InputHandler] queries the provided [FocusManager] for the
/// component currently in focus, then forwards input events to that
/// component’s own input handler.
///
/// If no component is focused, or the focused component does not handle
/// the event, this handler returns an ignored [ResponseInput].
///
/// ## Example
/// ```dart
/// final focusManager = FocusManager(context: appContext);
/// final inputHandler = ComponentInputHandler(focusManager);
///
/// // When an input event arrives:
/// ResponseInput response = inputHandler.handleInput(inputEvent);
/// if (response.handled) {
///   // Update UI accordingly
/// }
/// ```
///
/// {@category Input}
/// {@category Focus}
class ComponentInputHandler implements InputHandler {
  final FocusManager _focusManager;

  /// Creates a new [ComponentInputHandler] that delegates input events
  /// to the component currently focused by [focusManager].
  ComponentInputHandler(this._focusManager);

  /// Forwards the input [event] to the focused component's input handler,
  /// if any.
  ///
  /// Returns a [ResponseInput] indicating whether the event was handled.
  /// If no component is focused, or the focused component ignores the event,
  /// returns [ResponseInput.ignored].
  @override
  ResponseInput handleInput(InputEvent event) {
    final focused = _focusManager.context.currentComponent;

    if (focused == null) {
      return ResponseInput.ignored();
    }

    InteractableComponentInstance handler = focused;

    final result = handler.handleInput(event);
    if (result.handled) return result;

    return ResponseInput.ignored();
  }
}
