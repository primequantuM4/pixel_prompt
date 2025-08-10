import 'package:pixel_prompt/handler/input_handler.dart';

///
/// Maintains a global registry of [InputHandler] instances.
///
/// This class acts as a centralized registry where input handlers can be
/// registered or unregistered to participate in input event processing.
///
/// Users can extend this registry to include their own custom input handlers,
/// enabling modular and extensible input handling in an application.
///
/// Registered handlers can be accessed by input dispatchers or managers
/// to process input events in sequence.
///
/// ### Example
/// ```dart
/// class CustomInputHandler implements InputHandler {
///   @override
///   ResponseInput handleInput(InputEvent event) {
///     // Custom input handling logic here.
///     return ResponseInput.ignored();
///   }
/// }
///
/// // Register your handler globally
/// InputRegistry.register(CustomInputHandler());
/// ```
///
/// ### See Also
/// - [InputHandler]: The interface that input handlers must implement.
/// - [InputDispatcher]: Dispatches input events to registered handlers.
/// - [ResponseInput]: The standardized response returned by handlers.
///
/// {@category Input}
class InputRegistry {
  static final List<InputHandler> _handlers = [];

  /// Registers an [InputHandler] if not already registered.
  ///
  /// Prevents duplicate registrations.
  static void register(InputHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  /// Unregisters a previously registered [InputHandler].
  ///
  /// Does nothing if the handler was not registered.
  static void unregister(InputHandler handler) {
    _handlers.remove(handler);
  }

  /// Returns an unmodifiable list of all currently registered input handlers.
  static List<InputHandler> get handlers => List.unmodifiable(_handlers);
}
