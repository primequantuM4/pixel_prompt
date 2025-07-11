import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/logger/logger.dart';

class Checkbox extends InteractableComponent {
  final String label;
  bool checked = false;
  bool focusable = true;

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
  bool get isHoverable => true;

  @override
  bool get isFocusable => focusable;
  @override
  int fitHeight() => 1;

  @override
  int fitWidth() => 4 + label.length;

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    Logger.trace("Checkbox", "Checkbox is being called and drawn");
    String checkbox = (checked) ? '[X]' : '[ ]';

    if ((isFocused || isHovered) && checked) {
      checkbox = '[-]';
    } else if ((isFocused || isHovered) && !checked) {
      checkbox = '[.]';
    }

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
    if (event is KeyEvent) {
      switch (event.char) {
        case ' ':
        case '\n':
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

    return ResponseInput.ignored();
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

  @override
  void onClick() {
    checked = !checked;
  }
}
