import 'package:pixel_prompt/core/component_instance.dart';

/// Represents the type of response command returned
/// after processing an input event.
///
///{@category Input}
enum ResponseCommands {
  /// No response is required; the program continues running normally.
  none,

  /// Indicates the program should terminate.
  exit,
}

/// Encapsulates the result of processing an input event.
///
/// A [ResponseInput] specifies whether an event was handled,
/// any response commands to execute, and optionally which
/// [ComponentInstance]s need to be re-rendered.
///
///{@category Input}
class ResponseInput {
  /// The command to be executed after processing the event.
  final ResponseCommands commands;

  /// Indicates whether the event was handled.
  final bool handled;

  /// The list of [ComponentInstance]s that require a redraw.
  final List<ComponentInstance>? dirty;

  /// Creates a [ResponseInput] with the given parameters.
  ///
  /// The [commands] parameter specifies the response commands to execute
  /// after processing the input event.
  ///
  /// The [handled] parameter indicates whether the input event was
  /// successfully processed and handled by the component.
  ///
  /// The [dirty] parameter optionally specifies which [ComponentInstance]s
  /// require re-rendering as a result of processing the input event.
  ///
  /// Example:
  /// ```dart
  /// ResponseInput(
  ///   commands: ResponseCommands.none,
  ///   handled: true,
  ///   dirty: [myComponentInstance],
  /// );
  const ResponseInput({
    required this.commands,
    required this.handled,
    this.dirty,
  });

  /// Creates a [ResponseInput] indicating the event was ignored.
  static ResponseInput ignored() {
    return ResponseInput(commands: ResponseCommands.none, handled: false);
  }
}
