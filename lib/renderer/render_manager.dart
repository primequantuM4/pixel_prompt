import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class RenderManager {
  final CanvasBuffer buffer;
  int? _cursorX;
  int? _cursorY;

  final List<Component> _dirtyComponents = [];

  static const String _tag = 'RenderManager';

  RenderManager({required this.buffer});
  bool needsRecompute = false;
  bool get hasDirtyComponents => _dirtyComponents.isNotEmpty;

  void markDirty(Component comp) => _dirtyComponents.add(comp);

  void clear() {
    _dirtyComponents.clear();
  }

  void requestRedraw() {
    if (needsRecompute || App.instance.shouldRebuild) return;
    for (var component in _dirtyComponents) {
      buffer.clearBufferArea(component.bounds);
      buffer.flushArea(component.bounds);
      component.render(buffer, component.bounds);
    }

    _dirtyComponents.clear();
    render();
  }

  void requestRecompute(Rect bounds) {
    buffer.clear();
    _dirtyComponents.clear();
  }

  void recalculateScreen() {}

  void requestCursorMove(int x, int y) {
    _cursorX = x;
    _cursorY = y;
  }

  void render() {
    Logger.trace(_tag, 'Redraw requested to canvas buffer');
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
