import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

class InteractableRegistry {
  void registerInteractables(
    Component component,
    FocusManager focusManager,
    RenderManager renderManager,
  ) {
    if (component is InteractableComponent) {
      focusManager.register(component);
      component.renderManager = renderManager;
    }

    if (component is ParentComponent) {
      for (var child in component.children) {
        registerInteractables(child, focusManager, renderManager);
      }
    }
  }
}


// App
    // Checkbox List
        // checkbox
        // checkbox
        // checkbox

