import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';

class PositionedComponent {
  Component component;
  final Rect rect;

  PositionedComponent({required this.component, required this.rect});
}
