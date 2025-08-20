import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/stateful_component.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// A utility class for recursively registering interactable components.
///
/// [InteractableRegistry] walks the component tree and registers any
/// [InteractableComponentInstance] instances with the provided [FocusManager],
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
///
/// {@category Core}
/// {@category Interaction}
class InteractableRegistry {
  /// Recursively registers interactable components with the focus and render systems.
  ///
  /// This method traverses the component tree starting from [componentInstance] and:
  /// 1. Registers all [InteractableComponentInstance] instances with the [focusManager]
  /// 2. Assigns the [renderManager] to both interactable and stateful components
  /// 3. Recursively processes all children of parent components
  ///
  /// Parameters:
  /// - [componentInstance]: The root component instance to start registration from
  /// - [focusManager]: The focus manager that handles focus navigation and state
  /// - [renderManager]: The render manager responsible for coordinating rendering operations
  ///
  /// Usage:
  /// Typically called during application or scene initialization to wire up
  /// interactivity and ensure all components have access to rendering services.
  ///
  /// Example:
  /// ```dart
  /// final registry = InteractableRegistry();
  /// registry.registerInteractables(
  ///   rootComponentInstance,
  ///   focusManager,
  ///   renderManager,
  /// );
  /// ```
  void registerInteractables(
    ComponentInstance componentInstance,
    FocusManager focusManager,
    RenderManager renderManager,
  ) {
    if (componentInstance is InteractableComponentInstance) {
      focusManager.register(componentInstance);
      componentInstance.renderManager = renderManager;
    }
    if (componentInstance is StatefulComponentInstance) {
      Logger.trace(
        "InteractableRegistry",
        'Stateful Component $componentInstance registered',
      );
      componentInstance.renderManager = renderManager;
    }

    if (componentInstance is ParentComponentInstance) {
      for (var child in componentInstance.childrenInstance) {
        registerInteractables(child, focusManager, renderManager);
      }
    }
  }
}
