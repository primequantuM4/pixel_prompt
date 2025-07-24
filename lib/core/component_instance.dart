import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

abstract class ComponentInstance {
  Rect? _bounds;
  final EdgeInsets padding;
  final Position position;

  ComponentInstance({
    this.padding = const EdgeInsets.all(0),
    this.position =
        const Position(x: 0, y: 0, positionType: PositionType.relative),
  });

  Rect get bounds {
    if (_bounds == null) throw Exception('Bounds for $this not set yet');
    return _bounds!;
  }

  set bounds(Rect rect) => _bounds = rect;
  Size measure(Size maxSize);
  int fitWidth();
  int fitHeight();

  void render(CanvasBuffer buffer, Rect bounds);
}
