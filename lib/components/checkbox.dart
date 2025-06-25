import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';

class Checkbox extends InteractableComponent {
  final String label;
  bool checked = false;

  final AnsiColorType? selectionColor;
  final AnsiColorType? hoverColor;
  final AnsiColorType? textColor;

  Checkbox({
    required this.label,
    int? padding,
    this.selectionColor,
    this.hoverColor,
    this.textColor,
  });

  int get contentWidth => 4 + label.length;

  @override
  int fitHeight() => 1;

  @override
  int fitWidth() => 4 + label.length;

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final checkbox = (checked) ? '[X]' : '[]';
    final component = '$checkbox $label';

    TextComponentStyle style = TextComponentStyle().foreground(
      textColor ?? Colors.white,
    );

    if (checked) {
      style.background(selectionColor ?? Colors.black);
    } else if (isHovered || isFocused) {
      style.background(hoverColor ?? Colors.black);
    }

    buffer.drawAt(bounds.x, bounds.y, component, style);
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    switch (event) {
      case SpaceKeyEvent():
      case EnterKeyEvent():
        checked = !checked;
      default:
      // handle other inputs
    }

    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: [this],
    );
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void onBlur() {}

  @override
  void onFocus() {
    // TODO: implement onFocus
  }

  @override
  void onHover() {
    // TODO: implement onHover
  }
}
