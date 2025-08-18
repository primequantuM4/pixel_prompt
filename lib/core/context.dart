import 'package:pixel_prompt/core/interactable_component_instance.dart';

/// Maintains the state of user interaction within a UI context.
///
/// The [Context] class tracks the cursor position and manages interactive
/// components that can receive focus or hover states. It acts as a central
/// store for determining which component should respond to keyboard or mouse
/// input at any given time.
class Context {
  /// Current X position of the cursor in the UI.
  ///
  /// Defaults to `-1` if not set.
  int cursorX = -1;

  /// Current Y position of the cursor in the UI.
  ///
  /// Defaults to `-1` if not set.
  int cursorY = -1;

  /// All interactive components registered for focus and hover tracking.
  ///
  /// Components in this list may receive focus or hover state changes,
  /// and are indexed by [currentComponentIndex].
  final List<InteractableComponentInstance> componentInstances = [];

  /// Index of the [currentComponent] in [componentInstances].
  ///
  /// A value of `-1` indicates that no component is currently focused.
  int currentComponentIndex = -1;

  /// The component that currently has keyboard focus, if any.
  ///
  /// `null` if no component is focused.
  InteractableComponentInstance? currentComponent;

  /// The component currently under the mouse cursor (hovered), if any.
  ///
  /// `null` if no component is hovered.
  InteractableComponentInstance? hoveredComponent;

  /// Sets the initial cursor position within the UI.
  ///
  /// Useful for initializing cursor state before any interactions occur.
  ///
  /// - [x]: The horizontal position of the cursor.
  /// - [y]: The vertical position of the cursor.
  void setInitialCursorPosition(int x, int y) {
    cursorX = x;
    cursorY = y;
  }
}
