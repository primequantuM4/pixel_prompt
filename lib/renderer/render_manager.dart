import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';

class RenderManager {
  final CanvasBuffer buffer;

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

  void render() {
    buffer.render();
  }
}
