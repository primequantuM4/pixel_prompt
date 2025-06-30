import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';

class RenderManager {
  final CanvasBuffer buffer;
  int? _cursorX;
  int? _cursorY;

  final List<Component> _dirtyComponents = [];

  RenderManager({required this.buffer});

  void markDirty(Component comp) => _dirtyComponents.add(comp);

  void requestRedraw() {
    for (var component in _dirtyComponents) {
      buffer.clearBufferArea(component.getBounds());
      buffer.flushArea(component.getBounds());
      component.render(buffer, component.getBounds());
    }

    _dirtyComponents.clear();
    render();
  }

  void requestCursorMove(int x, int y) {
    _cursorX = x;
    _cursorY = y;
  }

  void render() {
    buffer.render();

    if (_cursorX != null && _cursorY != null) {
      buffer.moveCursorTo(_cursorX!, _cursorY!);
      buffer.showCursor();
      _cursorX = null;
      _cursorY = null;
    } else {
      buffer.hideCursor();
    }
  }
}
