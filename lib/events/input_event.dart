sealed class InputEvent {
  const InputEvent();
}

class CharEvent extends InputEvent {
  final String char;

  const CharEvent({required this.char});
}

enum SequenceOrigin { generic, windows, linux }

class SequenceEvent extends InputEvent {
  final List<int> sequence;
  final SequenceOrigin origin;

  const SequenceEvent({
    required this.sequence,
    this.origin = SequenceOrigin.generic,
  });
}

enum NavigationKeyType { tab, shiftTab, escape, unknown }

class NavigationKeyEvent {
  final NavigationKeyType type;

  const NavigationKeyEvent({required this.type});
}

class TabEvent extends InputEvent {}

class ShiftTabEvent extends InputEvent {}

class EscapeEvent extends InputEvent {}

class MouseEvent extends InputEvent {
  final MouseEventType type;
  final int x;
  final int y;
  final int button;

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

class UnknownEvent extends InputEvent {
  final int? byte;

  const UnknownEvent({this.byte});
}

enum MouseEventType { click, release, hover, error }
