import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

class InputDispatcher {
  final RenderManager _renderManager;
  final List<InputHandler> _handlers = [];

  InputDispatcher({required RenderManager renderer})
      : _renderManager = renderer;

  void registerHandler(InputHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  void unregisterHandler(InputHandler handler) {
    _handlers.remove(handler);
  }

  bool dispatchEvent(InputEvent event) {
    for (var handler in _handlers) {
      final response = handler.handleInput(event);
      if (response.handled) {
        if (!_renderManager.needsRecompute) {
          for (final component in response.dirty ?? []) {
            _renderManager.markDirty(component);
          }

          if ((response.dirty ?? []).isNotEmpty) _renderManager.requestRedraw();
        }
        if (response.commands == ResponseCommands.exit) return true;
      }
    }

    return false;
  }
}
