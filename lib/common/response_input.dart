import 'package:pixel_prompt/core/component_instance.dart';

enum ResponseCommands { none, exit }

class ResponseInput {
  final ResponseCommands commands;
  final bool handled;
  final List<ComponentInstance>? dirty;

  const ResponseInput({
    required this.commands,
    required this.handled,
    this.dirty,
  });

  static ResponseInput ignored() {
    return ResponseInput(commands: ResponseCommands.none, handled: false);
  }
}
