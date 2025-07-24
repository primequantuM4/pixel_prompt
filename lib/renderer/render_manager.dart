import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/logger/logger.dart';

class RenderManager {
  final CanvasBuffer buffer;
  int? _cursorX;
  int? _cursorY;

  final List<ComponentInstance> _dirtyComponents = [];

  static const String _tag = 'RenderManager';

  RenderManager({required this.buffer});
  bool needsRecompute = false;
  bool get hasDirtyComponents => _dirtyComponents.isNotEmpty;

  void markDirty(ComponentInstance comp) => _dirtyComponents.add(comp);

  void clear() {
    _dirtyComponents.clear();
  }

  void requestRedraw() {
    if (needsRecompute || AppInstance.instance.shouldRebuild) return;
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
