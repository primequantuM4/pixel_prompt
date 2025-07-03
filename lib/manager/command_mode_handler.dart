import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

class CommandModeHandler implements InputHandler {
  bool _inCommandMode = false;
  final StringBuffer _buffer = StringBuffer();

  @override
  ResponseInput handleInput(InputEvent event) {
    if (!_shouldHandle(event)) {
      return ResponseInput(commands: ResponseCommands.none, handled: false);
    }

    event = event as KeyEvent;
    if (event.code == KeyCode.character &&
        (event.char == '\r' || event.char == '\n')) {
      return executeCommand();
    } else if (event.code == KeyCode.backspace) {
      String value = _buffer.toString();
      if (value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
        _buffer.clear();
        _buffer.write(value);
      }
    } else {
      _buffer.write(event.char);
    }

    return ResponseInput(commands: ResponseCommands.none, handled: true);
  }

  ResponseInput executeCommand() {
    final ResponseCommands responseCommands;
    if (_buffer.toString() == ':q') {
      responseCommands = ResponseCommands.exit;
    } else {
      responseCommands = ResponseCommands.none;
    }

    _exitCommandMode();
    return ResponseInput(commands: responseCommands, handled: true);
  }

  bool _shouldHandle(InputEvent event) {
    if (event is! KeyEvent) return false;
    if (!_inCommandMode && event.char == ':') {
      _enterCommandMode();
    }
    return _inCommandMode || (!_inCommandMode && event.char == ':');
  }

  void _enterCommandMode() {
    _inCommandMode = true;
    _buffer.clear();
  }

  void _exitCommandMode() {
    _inCommandMode = false;
    _buffer.clear();
  }
}
