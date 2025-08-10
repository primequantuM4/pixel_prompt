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

/// A terminal-based checkbox UI component.
///
/// A [Checkbox] displays a label with a selectable box prefix.
/// It does **not** hold its own state directly — an internal [CheckboxInstance]
/// tracks whether the box is checked or unchecked.
///
/// ### Features:
/// - Toggle between checked/unchecked states via keyboard (`space` or `enter`) or mouse click.
/// - Visual state changes when hovered or focused.
/// - Optional styling for selection, hover, and text colors.
/// - Configurable width padding.
///
/// This class is a **configuration object** — actual rendering and interaction
/// is handled by [CheckboxInstance].
///
/// ### Example:
/// ```dart
/// final checkbox = Checkbox(
///   label: 'Enable feature',
///   selectionColor: Colors.green,
///   hoverColor: Colors.blue,
///   textColor: Colors.white,
///   width: 2,
/// );
/// ```
///
/// See also:
/// - [CheckboxInstance] for the runtime state and behavior.
/// - [TextComponentStyle] for styling options.
///
/// {@category Components}
/// {@category InteractableComponents}
class Checkbox extends Component {
  /// The text label displayed next to the checkbox.
  final String label;

  /// The background color applied when the checkbox is **checked**.
  final AnsiColorType? selectionColor;

  /// The background color applied when the checkbox is **hovered** but not checked.
  final AnsiColorType? hoverColor;

  /// The text color for the label.
  final AnsiColorType? textColor;

  /// Extra horizontal space (padding) to the right of the label.
  final int width;

  /// Creates a [Checkbox] with the given [label] and optional styling.
  ///
  /// - [label] is required and will always be displayed.
  /// - [selectionColor] sets the background color when checked.
  /// - [hoverColor] sets the background color when hovered but unchecked.
  /// - [textColor] sets the label text color.
  /// - [width] adds extra spacing after the label.
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

/// The runtime instance of a [Checkbox] component.
///
/// This class:
/// - Tracks whether the checkbox is checked.
/// - Handles user interactions (keyboard and mouse).
/// - Renders the checkbox and its label.
/// - Applies different styles based on hover/focus/checked state.
///
/// ### Checkbox display logic:
/// - Normal checked: `[X] Label`
/// - Normal unchecked: `[ ] Label`
/// - Hovered/focused checked: `[-] Label`
/// - Hovered/focused unchecked: `[.] Label`
///
/// This instance is created internally by [Checkbox.createInstance].
///
/// See also:
/// - [Checkbox] for configuration.
/// - [InteractableComponentInstance] for focus, hover, and click handling.
///
/// {@category Components}
/// {@category InteractableComponents}
class CheckboxInstance extends InteractableComponentInstance {
  /// Whether the checkbox is currently checked.
  bool checked = false;

  /// Whether this checkbox can receive focus.
  bool focusable = true;

  /// Length of the visual checkbox prefix (e.g., `[X] `).
  static const int prefixCheckboxLength = 4;

  /// The configuration source for this instance.
  final Checkbox component;

  /// Creates a [CheckboxInstance] bound to the given [component].
  CheckboxInstance(this.component);

  /// The total width of the checkbox content (prefix + label).
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

    // Determine checkbox symbol based on state
    String checkbox = (checked) ? '[X]' : '[ ]';
    if ((isFocused || isHovered) && checked) {
      checkbox = '[-]';
    } else if ((isFocused || isHovered) && !checked) {
      checkbox = '[.]';
    }

    // Full string to render
    final renderedComponent = '$checkbox ${component.label}';

    // Add fixed width padding if configured
    final padded = '$renderedComponent${' ' * component.width}';

    // Determine style based on state
    TextComponentStyle style = TextComponentStyle(
      color: component.textColor ?? Colors.white,
    );
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

    // Draw checkbox at position
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
        // Other keys are ignored
      }

      return ResponseInput(
        commands: ResponseCommands.none,
        handled: true,
        dirty: [this], // Mark self as needing re-render
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
    // TODO: implement onFocus
  }

  @override
  void onClick() {
    checked = !checked;
  }
}
