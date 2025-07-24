import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/core/context.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

class FocusManager implements InputHandler {
  final Context context;

  final List<InteractableComponentInstance> componentInstances = [];
  InteractableComponentInstance? currentComponent;
  InteractableComponentInstance? _hoveredComponent;
  int currentIndex = -1;

  FocusManager({required this.context});

  void register(InteractableComponentInstance c) {
    componentInstances.add(c);
  }

  void reset() {
    currentComponent = null;
    _hoveredComponent = null;
    currentIndex = -1;
    componentInstances.clear();
  }

  ResponseInput _handleTab(bool shiftPressed) {
    if (componentInstances.isEmpty) return ResponseInput.ignored();

    final List<InteractableComponentInstance> dirtyComponents = [];

    int nextIndex = currentIndex;
    final int direction = shiftPressed ? -1 : 1;
    final int total = componentInstances.length;

    if (nextIndex == -1) {
      nextIndex = shiftPressed ? 0 : -1;
    }

    for (int attempt = 0; attempt < total; attempt++) {
      nextIndex = (nextIndex + direction + total) % total;
      if (componentInstances[nextIndex].isFocusable) {
        // blur previous component
        if (currentComponent != null) {
          currentComponent!.blur();
          dirtyComponents.add(currentComponent!);
        }

        // focus on new component
        currentComponent = componentInstances[nextIndex];
        currentIndex = nextIndex;
        currentComponent!.focus();
        dirtyComponents.add(currentComponent!);

        return ResponseInput(
          commands: ResponseCommands.none,
          handled: true,
          dirty: dirtyComponents,
        );
      }
    }
    return ResponseInput.ignored();
  }

  ResponseInput _handleMouseInput(MouseEvent event) {
    final dirtyComponents = <InteractableComponentInstance>[];
    InteractableComponentInstance? hoveredNow;

    for (int i = componentInstances.length - 1; i >= 0; i--) {
      final component = componentInstances[i];

      if (!component.isHoverable) continue;

      if (_isWithinBounds(event.x, event.y, component)) {
        hoveredNow = component;

        if (event.type == MouseEventType.release ||
            event.type == MouseEventType.hover) {
          component.hover();
          dirtyComponents.add(component);
        } else if (event.type == MouseEventType.click) {
          if (component.isFocusable) {
            currentComponent?.blur();

            if (currentComponent != null) {
              dirtyComponents.add(currentComponent!);
            }

            component.focus();
            currentComponent = component;
            currentIndex = i;
            dirtyComponents.add(component);
          }

          component.onClick();
        }
        break;
      }
    }

    if (_hoveredComponent != hoveredNow) {
      if (_hoveredComponent != null) {
        _hoveredComponent!.unhover();
        dirtyComponents.add(_hoveredComponent!);
      }
      _hoveredComponent = hoveredNow;
    }

    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: dirtyComponents,
    );
  }

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

  bool _isWithinBounds(
      int x, int y, InteractableComponentInstance componentInstance) {
    final bounds = componentInstance.bounds;

    final adjustedX = bounds.x + context.cursorX;
    final adjustedY = bounds.y + context.cursorY;

    final graceWidth = adjustedX + bounds.width + 5;
    final graceHeight = adjustedY + bounds.height;

    return (x >= adjustedX && x < graceWidth) &&
        (y >= adjustedY && y < graceHeight);
  }
}
