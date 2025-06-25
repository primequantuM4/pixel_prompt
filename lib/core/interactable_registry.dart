import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';

class InteractableRegistry {
  void registerInteractables(Component component, FocusManager focusManager) {
    if (component is InteractableComponent) {
      focusManager.register(component);
    }

    if (component is ParentComponent) {
      for (var child in component.children) {
        registerInteractables(child, focusManager);
      }
    }
  }
}


// App
    // Checkbox List
        // checkbox
        // checkbox
        // checkbox

