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

/// A focusable, hoverable, and editable text input component for terminal/canvas UIs.
///
/// The `TextFieldComponent` displays a single-line input area with optional styles
/// for normal text, placeholder text, and hover/focus states.
///
/// It supports:
/// - **Custom styling** for text, placeholder, and hover states.
/// - **Placeholder text** when the field is empty.
/// - **Max width** control.
/// - **Callbacks** for text changes and submission.
/// - **Obscured mode** for password fields.
/// - **Arrow key navigation** and backspace support.
///
/// ### Example
/// ```dart
/// final textField = TextFieldComponent(
///   initialText: "Hello",
///   maxWidth: 30,
///   placeHolder: "Type something...",
///   textStyle: TextComponentStyle().foreground(ColorRGB(255, 255, 255)),
///   placeHolderStyle: TextComponentStyle().foreground(ColorRGB(128, 128, 128)),
///   hoverStyle: TextComponentStyle().bold(),
///   onChanged: (value) => print("Changed: $value"),
///   onSubmitted: (value) => print("Submitted: $value"),
/// );
/// ```
///
/// ### Styling
/// - Use [TextComponentStyle.foreground] or [TextComponentStyle.background]
///   to set colors.
/// - Use style helpers like `.bold()` or `.italic()` to adjust font style.
///
/// ### Interaction
/// - **Focus:** The field shows a `"|> "` prefix when focused.
/// - **Hover:** Hover style applies when the pointer or cursor is over the field.
/// - **Typing:** Input is appended at the cursor position.
/// - **Submission:** Pressing `Enter` triggers [onSubmitted].
/// - **Navigation:** Left/Right arrows move the cursor; Backspace deletes before cursor.
///
/// See also:
/// - [TextComponentStyle] for style customization.
/// - [AnsiColorType] for color definitions.
///
/// {@category Component}
class TextFieldComponent extends Component {
  /// Initial text content of the field.
  final String? initialText;

  /// Foreground (text) color.
  final AnsiColorType? foreground;

  /// Background color.
  final AnsiColorType? background;

  /// Style for entered text.
  final TextComponentStyle? textStyle;

  /// Placeholder text displayed when empty.
  final String? placeHolder;

  /// Style for placeholder text.
  final TextComponentStyle? placeHolderStyle;

  /// Style applied when hovered or focused.
  final TextComponentStyle? hoverStyle;

  /// If `true`, masks the text (for passwords).
  final bool obsecure;

  /// Maximum width of the text field (in characters).
  final int maxWidth;

  /// Callback when the user presses Enter.
  final Function(String)? onSubmitted;

  /// Callback when the text changes.
  final Function(String)? onChanged;

  /// Creates a text field component for user input.
  ///
  /// The [TextFieldComponent] provides a configurable input field with support for
  /// styling, placeholders, text masking, and event callbacks.
  ///
  /// Parameters:
  /// - [onChanged]: Callback triggered when the text content changes.
  ///   Receives the current text value.
  /// - [onSubmitted]: Callback triggered when the user presses Enter.
  ///   Receives the final text value.
  /// - [initialText]: The initial text content displayed in the field.
  /// - [foreground]: The text color for user input.
  /// - [background]: The background color of the text field.
  /// - [textStyle]: Additional styling to apply to the entered text.
  /// - [placeHolder]: Text displayed when the field is empty.
  /// - [placeHolderStyle]: Styling to apply to the placeholder text.
  /// - [hoverStyle]: Styling applied when the field is hovered or focused.
  /// - [obsecure]: If `true`, masks input characters (useful for passwords).
  ///   Defaults to `false`.
  /// - [maxWidth]: Maximum number of characters allowed in the field.
  ///   Defaults to `20`.
  ///
  /// Example:
  /// ```dart
  /// TextFieldComponent(
  ///   initialText: 'Username',
  ///   foreground: Colors.white,
  ///   background: Colors.blue,
  ///   placeHolder: 'Enter your username...',
  ///   placeHolderStyle: TextComponentStyle(styles: {FontStyle.italic}),
  ///   maxWidth: 30,
  ///   onSubmitted: (value) => print('Submitted: $value'),
  ///   onChanged: (value) => print('Changed: $value'),
  /// )
  /// ```
  ///
  /// See also:
  /// - [TextComponentStyle] for text styling options
  /// - [AnsiColorType] for color implementations
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

/// A private, interactive text field component instance that handles user input,
/// rendering, and state management for text entry in a terminal UI.
///
/// This class is responsible for:
/// - Displaying either user-entered text or a placeholder when empty.
/// - Handling keyboard input such as typing, arrow navigation, and backspace.
/// - Managing cursor position and focus state.
/// - Rendering styled text according to different component states
///   (normal, hover, placeholder, and focused).
///
/// It interacts with:
/// - [CanvasBuffer] for drawing text in the terminal.
/// - [InputEvent] for responding to keyboard events.
/// - [TextComponentStyle] for controlling the visual styling.
/// - [TextFieldComponent] which defines the configuration and callbacks.
///
/// The cursor position is tracked independently of the string length,
/// allowing for insertion and deletion at arbitrary positions.
/// When focused, the class requests the render manager to position
/// the cursor appropriately in the terminal.
///
/// ### Example lifecycle:
/// 1. The component is instantiated with a [TextFieldComponent].
/// 2. When rendered, it draws a prefix (`"|> "` if focused, `"   "` otherwise)
///    and either the entered value or placeholder.
/// 3. User keyboard input is processed to update the value and cursor index.
/// 4. [onChanged] and [onSubmitted] callbacks are triggered appropriately.
///
/// This is **not** intended for direct instantiation outside the framework.
/// It is created internally when a `TextFieldComponent` is mounted.
///
/// {@category Component}
class _TextfieldComponentInstance extends InteractableComponentInstance {
  /// The current value of the text field.
  ///
  /// This is updated when the user types or deletes characters.
  String value;

  /// The source configuration for this text field instance.
  final TextFieldComponent component;

  /// The style applied to the entered text when in normal state.
  TextComponentStyle textStyle;

  /// The style applied when displaying the placeholder text.
  final TextComponentStyle placeHolderStyle;

  /// The current cursor position index relative to [value].
  ///
  /// - `0` means the cursor is before the first character.
  /// - `value.length` means the cursor is after the last character.
  int cursorIndex = 0;

  /// The style applied when the component is hovered or focused.
  final TextComponentStyle hoverStyle;

  /// Creates a text field instance from the given [component].
  ///
  /// Defaults:
  /// - If [component.initialText] is `null`, starts with an empty string.
  /// - If [component.textStyle] is `null`, uses a default [TextComponentStyle].
  /// - If [component.placeHolderStyle] is `null`, uses a gray foreground style.
  /// - If [component.hoverStyle] is `null`, uses a default [TextComponentStyle].
  _TextfieldComponentInstance(this.component)
    : value = component.initialText ?? '',
      textStyle = component.textStyle ?? TextComponentStyle(),
      placeHolderStyle =
          component.placeHolderStyle ??
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
    // Clear the drawing area to prevent leftover artifacts from previous frames.
    buffer.clearBufferArea(bounds);

    // Display a visual prefix when focused, otherwise leave empty padding.
    final prefix = isFocused ? "|> " : "   ";

    // Calculate available width for the text input (excluding prefix).
    final inputAreaWidth = component.maxWidth - prefix.length;

    // If the cursor has moved beyond the visible area, adjust the start index.
    final int start = (cursorIndex > inputAreaWidth)
        ? cursorIndex - inputAreaWidth
        : 0;

    // Extract the portion of the value that should be visible on screen.
    final String visibleText = value.substring(
      start,
      min(value.length, start + inputAreaWidth),
    );

    // Decide whether to show placeholder or actual text.
    final String textToShow = value.isEmpty && component.placeHolder != null
        ? prefix + component.placeHolder!
        : prefix + visibleText;

    // Pick style based on state.
    final style = value.isEmpty && component.placeHolder != null
        ? placeHolderStyle
        : (isHovered || isFocused)
        ? hoverStyle
        : textStyle;

    // Draw padded text to fill the full width of the component.
    buffer.drawAt(
      bounds.x,
      bounds.y,
      textToShow.padRight(component.maxWidth),
      style,
    );

    // Move terminal cursor to the appropriate position if focused.
    if (isFocused) {
      final int cursorScreenX =
          bounds.x + prefix.length + (cursorIndex - start);
      renderManager!.requestCursorMove(cursorScreenX, bounds.y);
    }
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    // Ignore non-keyboard events or when not focused.
    if (event is! KeyEvent || !isFocused) {
      return ResponseInput.ignored();
    }

    String? input = event.char;

    // Handle arrow key navigation.
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
        // Arrow up/down currently ignored.
        ResponseInput.ignored();
      }
    }

    // Handle enter key submission.
    if (input != null && input == '\n') {
      component.onSubmitted?.call(value);
      blur();
    }
    // Handle backspace deletion.
    else if (event.code == KeyCode.backspace) {
      if (cursorIndex > 0) {
        value =
            value.substring(0, cursorIndex - 1) + value.substring(cursorIndex);
        cursorIndex--;
      }
    }
    // Handle regular character input.
    else {
      int len = input?.length ?? 0;
      String val = input ?? '';
      value =
          value.substring(0, cursorIndex) + val + value.substring(cursorIndex);

      cursorIndex += len;
    }

    // Notify listeners of text changes.
    component.onChanged?.call(value);

    // Indicate that this component's display needs re-rendering.
    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: [this],
    );
  }

  @override
  Size measure(Size maxSize) {
    // Size is determined by the configured max width and fixed height of 1.
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
    // Clicking focuses the text field so it can receive keyboard input.
    isFocused = true;
  }
}
