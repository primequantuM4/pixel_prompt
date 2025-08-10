import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

/// Defines a handler that processes [InputEvent]s and produces [ResponseInput]s.
///
/// Implementations are responsible for interpreting user input
/// and returning an appropriate [ResponseInput] describing how the app
/// should respond (e.g., exit, redraw components, or ignore the input).
///
/// ### Lifecycle
/// - An `InputHandler` instance typically lives for as long as its
///   owning component is active.
/// - The [handleInput] method is called whenever a new [InputEvent]
///   needs to be processed.
///
/// ### Example
/// ```dart
/// class QuitOnEscapeHandler extends InputHandler {
///   @override
///   ResponseInput handleInput(InputEvent event) {
///     if (event is KeyEvent && event.code == KeyCode.escape) {
///       return ResponseInput(commands: ResponseCommands.exit, handled: true);
///     }
///     return ResponseInput.ignored();
///   }
/// }
/// ```
///
/// {@category Input}
abstract class InputHandler {
  /// Processes an incoming [InputEvent] and returns a [ResponseInput]
  /// describing the result of handling it.
  ResponseInput handleInput(InputEvent event);
}
