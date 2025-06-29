import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

abstract class InteractableComponent extends Component {
  RenderManager? renderManager;
  bool isFocused = false;
  bool isHovered = false;

  bool get isFocusable => false;
  bool get isHoverable => false;
  bool get wantsInput => false;

  void markDirty() {
    if (renderManager != null) {
      renderManager!.markDirty(this);
      renderManager!.requestRedraw();
    }
  }

  void blur() {
    isFocused = false;
    isHovered = false;
    onBlur();

    return;
  }

  void focus() {
    isFocused = true;
    onFocus();

    return;
  }

  void hover() {
    isHovered = true;
    onHover();

    return;
  }

  void unhover() {
    isHovered = false;
    return;
  }

  void onFocus();
  void onBlur();
  void onHover();
  void onClick();

  ResponseInput handleInput(InputEvent event);
}
