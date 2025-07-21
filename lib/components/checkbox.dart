import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/logger/logger.dart';

class Checkbox extends Component {
  final String label;

  final AnsiColorType? selectionColor;
  final AnsiColorType? hoverColor;
  final AnsiColorType? textColor;
  final int width;

  const Checkbox({
    required this.label,
    this.selectionColor,
    this.hoverColor,
    this.textColor,
    this.width = 0,
  });

  @override
  ComponentInstance createInstance() => CheckboxInstance(this);
}

class CheckboxInstance extends InteractableComponentInstance {
  bool checked = false;
  bool focusable = true;

  static const int prefixCheckboxLength = 4;

  final Checkbox component;

  CheckboxInstance(this.component);

  int get contentWidth => prefixCheckboxLength + component.label.length;

  @override
  bool get isHoverable => true;

  @override
  bool get isFocusable => focusable;
  @override
  int fitHeight() => 1;

  @override
  int fitWidth() => prefixCheckboxLength + component.label.length;

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    Logger.trace("Checkbox", "Checkbox is being called and drawn");
    String checkbox = (checked) ? '[X]' : '[ ]';

    if ((isFocused || isHovered) && checked) {
      checkbox = '[-]';
    } else if ((isFocused || isHovered) && !checked) {
      checkbox = '[.]';
    }

    final renderedComponent = '$checkbox ${component.label}';

    final padded = '$renderedComponent${' ' * component.width}';

    TextComponentStyle style =
        TextComponentStyle(color: component.textColor ?? Colors.white);
    if (checked) {
      style = TextComponentStyle(
        color: component.textColor ?? Colors.white,
        bgColor: component.selectionColor ?? Colors.black,
        padding: EdgeInsets.symmetric(horizontal: component.width),
      );
    } else if (isHovered || isFocused) {
      style = TextComponentStyle(
        color: component.textColor ?? Colors.white,
        bgColor: component.hoverColor ?? Colors.black,
        padding: EdgeInsets.symmetric(horizontal: component.width),
      );
    }

    buffer.drawAt(bounds.x, bounds.y, padded, style);
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
