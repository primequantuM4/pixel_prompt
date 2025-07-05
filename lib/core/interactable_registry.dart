import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// A utility class for recursively registering interactable components.
///
/// [InteractableRegistry] walks the component tree and registers any
/// [InteractableComponent] instances with the provided [FocusManager],
/// and assigns the given [RenderManager] to them.
///
/// This is typically called once during the initialization of a UI scene
/// to wire up interactivity and state-driven rendering.
///
/// Example usage:
/// ```dart
/// final registry = InteractableRegistry();
/// registry.registerInteractables(rootComponent, focusManager, renderManager);
/// ```
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
