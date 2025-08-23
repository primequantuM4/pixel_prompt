import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/core/context.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

/// Manages which [InteractableComponentInstance] currently has keyboard
/// or mouse focus, and updates focus state in response to user input.
///
/// The [FocusManager] is the bridge between raw input events (keyboard/mouse)
/// and the focus/hover/interaction state of interactive components. It:
///
/// - Tracks all registered focusable and hoverable components.
/// - Moves focus between components when the user presses `Tab` or `Shift+Tab`.
/// - Updates hover and click state in response to mouse events.
/// - Notifies components when they gain or lose focus/hover.
/// - Produces a [ResponseInput] describing what changed and what needs to be redrawn.
///
/// ## Lifecycle
/// 1. **Registration** — Components must be registered via [register] each frame
///    before input is handled.
/// 2. **Handling input** — [handleInput] is called with incoming [InputEvent]s.
/// 3. **Updating state** — The focus manager mutates internal focus/hover state
///    and produces a [ResponseInput] marking components that should be re-rendered.
/// 4. **Reset** — Call [reset] when the component tree changes drastically or
///    when the UI is torn down.
///
/// ## Example: External usage
/// ```dart
/// final focusManager = FocusManager(context: appContext);
///
/// // During layout or component build:
/// for (final component in interactableComponents) {
///   focusManager.register(component);
/// }
///
/// // During event loop:
/// final response = focusManager.handleInput(event);
/// if (response.handled) {
///   // write handling logic here
/// }
/// ```
///
/// {@category Input}
/// {@category Focus}
///
/// See also:
/// - [InteractableComponentInstance], because it defines `focus`, `blur`,
///   `hover`, `unhover`, and `onClick` which [FocusManager] depends on.
/// - [InputHandler], because [FocusManager] implements it to integrate with
///   the app’s event dispatch system.
/// - [ResponseInput], because it’s the structured result you use to decide
///   what to re-render after focus changes.
class FocusManager implements InputHandler {
  /// The rendering and event [Context] this focus manager operates within.
  ///
  /// The [Context] provides cursor offsets, which are used to translate
  /// mouse coordinates into component bounds space in [_isWithinBounds].
  final Context context;

  /// Creates a new [FocusManager] bound to the given [context].
  FocusManager({required this.context});

  /// Registers a component to be considered for focus and hover handling.
  ///
  /// Must be called once for each interactive component in the UI before
  /// handling input. Components should be re-registered every frame after
  /// layout, since [componentInstances] is cleared on [reset].
  void register(InteractableComponentInstance c) {
    context.componentInstances.add(c);
    if (context.componentInstances.length - 1 ==
        context.currentComponentIndex) {
      context.currentComponent = c;
      context.currentComponent!.focus();
    }
  }

  /// Clears all registered components.
  ///
  /// Call this before rebuilding the component tree or when tearing down
  /// the UI to avoid dangling references.
  void reset() {
    context.componentInstances.clear();
    context.hoveredComponent = null;
  }

  /// Handles cycling focus forward (`Tab`) or backward (`Shift+Tab`).
  ///
  /// - If no component is currently focused, will start from the beginning
  ///   (Shift+Tab) or end (Tab) of the list depending on [shiftPressed].
  /// - Skips components that are not focusable.
  ///
  /// Returns a [ResponseInput] with the components that were blurred or focused.
  ResponseInput _handleTab(bool shiftPressed) {
    if (context.componentInstances.isEmpty) return ResponseInput.ignored();

    if (context.currentComponentIndex >= context.componentInstances.length) {
      context.currentComponentIndex = -1;
      context.currentComponent = null;
      context.hoveredComponent = null;
    }

    final List<InteractableComponentInstance> dirtyComponents = [];
    int nextIndex = context.currentComponentIndex;
    final int direction = shiftPressed ? -1 : 1;
    final int total = context.componentInstances.length;

    if (nextIndex == -1) {
      nextIndex = shiftPressed ? 0 : -1;
    }
    for (int attempt = 0; attempt < total; attempt++) {
      nextIndex = (nextIndex + direction + total) % total;
      if (context.componentInstances[nextIndex].isFocusable) {
        if (context.currentComponent != null) {
          context.currentComponent!.blur();
          dirtyComponents.add(context.currentComponent!);
        }
        context.currentComponent = context.componentInstances[nextIndex];
        context.currentComponentIndex = nextIndex;
        context.currentComponent!.focus();
        dirtyComponents.add(context.currentComponent!);

        return ResponseInput(
          commands: ResponseCommands.none,
          handled: true,
          dirty: dirtyComponents,
        );
      }
    }
    return ResponseInput.ignored();
  }

  /// Handles all mouse-driven focus and hover updates.
  ///
  /// Supports:
  /// - Hover tracking ([MouseEventType.hover] / [MouseEventType.release])
  /// - Focus on click ([MouseEventType.click])
  /// - Calling `onClick` on clicked components
  ///
  /// Returns a [ResponseInput] containing any components that changed state.
  ResponseInput _handleMouseInput(MouseEvent event) {
    final dirtyComponents = <InteractableComponentInstance>[];
    InteractableComponentInstance? hoveredNow;

    for (int i = context.componentInstances.length - 1; i >= 0; i--) {
      final component = context.componentInstances[i];
      if (!component.isHoverable) continue;

      if (_isWithinBounds(event.x, event.y, component)) {
        hoveredNow = component;

        if (event.type == MouseEventType.release ||
            event.type == MouseEventType.hover) {
          component.hover();
          dirtyComponents.add(component);
        } else if (event.type == MouseEventType.click) {
          if (component.isFocusable) {
            context.currentComponent?.blur();
            if (context.currentComponent != null) {
              dirtyComponents.add(context.currentComponent!);
            }
            component.focus();
            context.currentComponent = component;
            context.currentComponentIndex = i;
            dirtyComponents.add(component);
          }
          component.onClick();
        }
        break;
      }
    }

    if (context.hoveredComponent != hoveredNow) {
      if (context.hoveredComponent != null) {
        context.hoveredComponent!.unhover();
        dirtyComponents.add(context.hoveredComponent!);
      }
      context.hoveredComponent = hoveredNow;
    }

    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: dirtyComponents,
    );
  }

  /// Handles a generic [InputEvent] by delegating to tab navigation or
  /// mouse processing as appropriate.
  ///
  /// - `KeyCode.tab` → move focus forward
  /// - `KeyCode.shiftTab` → move focus backward
  /// - [MouseEvent] → handle hover and clicks
  ///
  /// Returns [ResponseInput.ignored] if the event does not affect focus/hover.
  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is KeyEvent && event.code == KeyCode.shiftTab) {
      return _handleTab(true);
    } else if (event is KeyEvent && event.code == KeyCode.tab) {
      return _handleTab(false);
    } else if (event is MouseEvent) {
      return _handleMouseInput(event);
    }
    return ResponseInput.ignored();
  }

  /// Returns whether the given screen-space point ([x], [y]) is inside
  /// the bounds of [componentInstance], with a small horizontal grace area.
  ///
  /// This method uses [Context.cursorX] and [Context.cursorY] to translate
  /// component bounds into screen coordinates.
  bool _isWithinBounds(
    int x,
    int y,
    InteractableComponentInstance componentInstance,
  ) {
    final bounds = componentInstance.bounds;
    final adjustedX = bounds.x + context.cursorX;
    final adjustedY = bounds.y + context.cursorY;
    final graceWidth = adjustedX + bounds.width + 5;
    final graceHeight = adjustedY + bounds.height;

    return (x >= adjustedX && x < graceWidth) &&
        (y >= adjustedY && y < graceHeight);
  }
}
