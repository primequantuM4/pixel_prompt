import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

abstract class Component {
  final Position? position;

  Rect? _bounds;

  void setBounds(Rect bounds) {
    _bounds = bounds;
  }

  Rect getBounds() {
    if (_bounds == null) throw Exception("Component bounds not set yet");
    return _bounds!;
  }

  void markDirty() {}
  Component({this.position});

  Size measure(Size maxSize);
  int fitWidth();
  int fitHeight();
  void render(CanvasBuffer buffer, Rect bounds);
}

mixin ParentComponent on Component {
  List<Component> get children;
}
