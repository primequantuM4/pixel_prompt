import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';

class ComponentInputHandler implements InputHandler {
  final FocusManager _focusManager;

  ComponentInputHandler(this._focusManager);
  @override
  ResponseInput handleInput(InputEvent event) {
    final focused = _focusManager.currentComponent;

    if (focused == null) {
      return ResponseInput.ignored();
    }

    InteractableComponent handler = focused;

    final result = handler.handleInput(event);
    if (result.handled) return result;

    return ResponseInput.ignored();
  }
}
