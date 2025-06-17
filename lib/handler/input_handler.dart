import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/common/response_input.dart';

abstract class InputHandler {
  ResponseInput handleInput(InputEvent event);
}
