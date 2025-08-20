/// Base type for all input events.
///
/// All specific event types such as key presses,
/// mouse clicks, and escape sequences extend [InputEvent].
/// {@category Events}
sealed class InputEvent {
  const InputEvent();
}

/// Represents a keyboard event.
///
/// Includes the key code and optional character value.
/// {@category Events}
class KeyEvent extends InputEvent {
  /// The code identifying the key pressed.
  final KeyCode code;

  /// The character associated with the key, if applicable.
  final String? char;

  /// Creates a keyboard event with the given key code and optional character.
  const KeyEvent({required this.code, this.char});
}

/// Identifies different kinds of key presses.
/// {@category Events}
enum KeyCode {
  /// A printable character key
  character,

  /// Enter/Return key
  enter,

  /// Tab key
  tab,

  /// Shift+Tab combination
  shiftTab,

  /// Escape key
  escape,

  /// Backspace key
  backspace,

  /// Up arrow key
  arrowUp,

  /// Down arrow key
  arrowDown,

  /// Left arrow key
  arrowLeft,

  /// Right arrow key
  arrowRight,

  /// Ctrl+C combination
  ctrlC,
}

/// Represents a raw character input event.
///
/// Typically used for printable characters.
/// {@category Events}
class CharEvent extends InputEvent {
  /// The character that was input.
  final String char;

  /// Creates a character event with the given character.
  const CharEvent({required this.char});
}

/// Indicates where a terminal escape sequence originated.
/// {@category Events}
enum SequenceOrigin {
  /// Generic origin
  generic,

  /// Windows terminal origin
  windows,

  /// Linux terminal origin
  linux,
}

/// Represents a terminal escape sequence event.
///
/// Used for control sequences that are not simple key presses.
/// {@category Events}
class SequenceEvent extends InputEvent {
  /// The raw sequence bytes.
  final List<int> sequence;

  /// The origin of the escape sequence.
  final SequenceOrigin origin;

  /// Creates an escape sequence event with the given bytes and origin.
  const SequenceEvent({
    required this.sequence,
    this.origin = SequenceOrigin.generic,
  });
}

/// Represents an escape key event with no additional data.
/// {@category Events}
class EscapeEvent extends InputEvent {}

/// Represents a mouse input event.
///
/// Includes the event type, position, and button used.
/// {@category Events}
class MouseEvent extends InputEvent {
  /// The type of mouse action performed.
  final MouseEventType type;

  /// The horizontal position of the cursor.
  final int x;

  /// The vertical position of the cursor.
  final int y;

  /// The mouse button pressed.
  final int button;

  /// Creates a mouse event with the given [type], [x], [y] and [button].
  MouseEvent({
    required this.type,
    required this.x,
    required this.y,
    required this.button,
  });

  @override
  String toString() {
    return 'MouseEvent{type: $type, x: $x, y: $y, button: $button}';
  }
}

/// Represents an unrecognized or unsupported input event.
/// {@category Events}
class UnknownEvent extends InputEvent {
  /// The raw byte received, if available.
  final int? byte;

  /// Creates an unknown event with the optional raw byte.
  const UnknownEvent({this.byte});
}

/// Enumerates possible mouse event actions.
/// {@category Events}
enum MouseEventType {
  /// Mouse button press
  click,

  /// Mouse button release
  release,

  /// Mouse movement without button press
  hover,

  /// Invalid or malformed mouse event
  error,
}
