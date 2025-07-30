import 'dart:math';

import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';

import 'colors.dart';
import 'text_component_style.dart';

class TextFieldComponent extends Component {
  final String? initialText;
  final AnsiColorType? foreground;
  final AnsiColorType? background;
  final TextComponentStyle? textStyle;
  final String? placeHolder;
  final TextComponentStyle? placeHolderStyle;
  final TextComponentStyle? hoverStyle;
  final bool obsecure;
  final int maxWidth;

  final Function(String)? onSubmitted;
  final Function(String)? onChanged;

  const TextFieldComponent({
    this.onChanged,
    this.onSubmitted,
    this.initialText,
    this.foreground,
    this.background,
    this.textStyle,
    this.placeHolder,
    this.placeHolderStyle,
    this.hoverStyle,
    this.obsecure = false,
    this.maxWidth = 20,
  });

  @override
  ComponentInstance createInstance() => _TextfieldComponentInstance(this);
}

class _TextfieldComponentInstance extends InteractableComponentInstance {
  String value;

  final TextFieldComponent component;

  TextComponentStyle textStyle;
  final TextComponentStyle placeHolderStyle;
  int cursorIndex = 0;

  final TextComponentStyle hoverStyle;

  _TextfieldComponentInstance(this.component)
      : value = component.initialText ?? '',
        textStyle = component.textStyle ?? TextComponentStyle(),
        placeHolderStyle = component.placeHolderStyle ??
            TextComponentStyle().foreground(ColorRGB(128, 128, 128)),
        hoverStyle = component.hoverStyle ?? TextComponentStyle();

  @override
  bool get isFocusable => true;

  @override
  bool get wantsInput => true;

  @override
  bool get isHoverable => true;

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    buffer.clearBufferArea(bounds);

    final prefix = isFocused ? "|> " : "   ";
    final inputAreaWidth = component.maxWidth - prefix.length;

    final int start =
        (cursorIndex > inputAreaWidth) ? cursorIndex - inputAreaWidth : 0;

    final String visibleText = value.substring(
      start,
      min(value.length, start + inputAreaWidth),
    );

    final String textToShow = value.isEmpty && component.placeHolder != null
        ? prefix + component.placeHolder!
        : prefix + visibleText;

    final style = value.isEmpty && component.placeHolder != null
        ? placeHolderStyle
        : (isHovered || isFocused)
            ? hoverStyle
            : textStyle;

    buffer.drawAt(
        bounds.x, bounds.y, textToShow.padRight(component.maxWidth), style);

    if (isFocused) {
      final int cursorScreenX =
          bounds.x + prefix.length + (cursorIndex - start);
      renderManager!.requestCursorMove(cursorScreenX, bounds.y);
    }
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent || !isFocused) {
      return ResponseInput.ignored();
    }

    String? input = event.char;

    Set<KeyCode> arrowKeys = {
      KeyCode.arrowUp,
      KeyCode.arrowDown,
      KeyCode.arrowLeft,
      KeyCode.arrowRight,
    };

    if (arrowKeys.contains(event.code)) {
      if (event.code == KeyCode.arrowLeft && cursorIndex > 0) {
        cursorIndex--;
      } else if (event.code == KeyCode.arrowRight &&
          cursorIndex < value.length) {
        cursorIndex++;
      } else {
        ResponseInput.ignored();
      }
    }

    if (input != null && input == '\n') {
      component.onSubmitted?.call(value);
      blur();
    } else if (event.code == KeyCode.backspace) {
      if (cursorIndex > 0) {
        value =
            value.substring(0, cursorIndex - 1) + value.substring(cursorIndex);
        cursorIndex--;
      }
    } else {
      int len = input?.length ?? 0;
      String val = input ?? '';
      value =
          value.substring(0, cursorIndex) + val + value.substring(cursorIndex);

      cursorIndex += len;
    }

    component.onChanged?.call(value);

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
  void onFocus() {}

  @override
  int fitHeight() => 1;

  @override
  int fitWidth() => component.maxWidth;

  @override
  void onHover() {}

  @override
  void onClick() {
    isFocused = true;
  }
}
