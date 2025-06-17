import 'package:pixel_prompt/core/component.dart';

abstract class InteractableComponent extends Component {
  bool isFocused = false;
  bool isHovered = false;

  void blur() {
    isFocused = false;
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

  void handleInput(String input);
}
