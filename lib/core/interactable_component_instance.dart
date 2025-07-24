import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

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
