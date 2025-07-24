import 'dart:math';

import 'package:pixel_prompt/components/text_component.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';
import 'package:test/test.dart';

class DummyComponent extends Component with ParentComponent {
  final List<Component> _children;
  DummyComponent({required List<Component> children}) : _children = children;

  @override
  List<Component> get children => _children;

  @override
  int fitHeight() {
    int total = 0;
    for (final child in children) {
      total += child.fitHeight();
    }
    return total;
  }

  @override
  int fitWidth() {
    int maxWidth = 0;

    for (final child in children) {
      maxWidth = max(child.fitWidth(), maxWidth);
    }

    return maxWidth;
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (var child in _children) {
      child.render(buffer, bounds);
    }
  }
}

void main() {
  group('initial width and height fitting pre size requirements', () {
    test('calculated width and expected width should match', () {
      final firstText = "hello world!";
      final secondText = "what is your name";

      final List<Component> children = [
        TextComponent(firstText, style: TextComponentStyle()),
        TextComponent(secondText, style: TextComponentStyle()),
      ];
      final direction = Axis.horizontal;
      final bounds = Rect(
        x: 0,
        y: 0,
        width: 80,
        height: 24,
      ); // arbitrary number of width and height;
      final DummyComponent dummyComponent = DummyComponent(children: children);
      final engine = LayoutEngine(
        rootInstance: dummyComponent,
        children: children,
        direction: direction,
        bounds: bounds,
      );
      final expectedWidth = firstText.length + secondText.length + 1;
      final actualWidth = engine.fitWidth();

      final expectedHeight = 1;
      final actualHeight = engine.fitHeight();

      expect(expectedWidth, actualWidth);
      expect(expectedHeight, actualHeight);
    });
  });
}
