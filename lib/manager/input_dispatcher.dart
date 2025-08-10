import 'dart:io';

import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/manager/input_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

/// Central dispatcher for input events.
///
/// The `InputDispatcher` manages a list of [InputHandler]s and forwards
/// input events to them sequentially until one handles the event.
///
/// It coordinates with [RenderManager] to mark components dirty and request
/// redraws when necessary, based on the handlers' responses.
///
/// ### Responsibilities:
/// - Register and unregister input handlers.
/// - Dispatch input events to handlers in order.
/// - Manage render invalidation for updated components.
/// - Return `true` if any handler signals an exit command.
///
/// ### Lifecycle:
/// - Created with a [RenderManager] instance.
/// - Handlers can be added or removed dynamically.
/// - Should be used as the single entry point for input events.
///
///
/// ### See also
/// - [InputHandler]: The interface for input event handlers.
/// - [RenderManager]: Manages rendering and redraw requests based on input.
/// - [ResponseInput]: Represents handler response including commands and dirty components.
/// - [InputManager]: The Class that manages all raw byte stream from [stdin]
///
/// {@category Input}
class InputDispatcher {
  final RenderManager _renderManager;
  final List<InputHandler> _handlers = [];

  InputDispatcher({required RenderManager renderer})
    : _renderManager = renderer;

  /// Registers an [InputHandler] to receive dispatched input events.
  ///
  /// Duplicate registrations are ignored.
  void registerHandler(InputHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  /// Unregisters an [InputHandler], so it no longer receives events.
  void unregisterHandler(InputHandler handler) {
    _handlers.remove(handler);
  }

  /// Dispatches an [InputEvent] to all registered handlers sequentially.
  ///
  /// If a handler returns a handled response, marks the affected components dirty
  /// and requests redraw via [RenderManager].
  ///
  /// Returns `true` if any handler signals the [ResponseCommands.exit] command,
  /// indicating the application should exit.
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
