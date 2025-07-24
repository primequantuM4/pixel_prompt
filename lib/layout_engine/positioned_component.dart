import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';

class PositionedComponentInstance {
  ComponentInstance componentInstance;
  final Rect rect;
  ComponentInstance? parentComponentInstance;

  PositionedComponentInstance({
    required this.componentInstance,
    required this.rect,
    this.parentComponentInstance,
  });
}
