import 'dart:math';

import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

typedef VoidCallback = void Function();

abstract class StatefulComponent extends Component with ParentComponent {
  List<Component> _children = [];

  RenderManager? renderManager;

  final Axis direction = Axis.vertical;

  StatefulComponent({this.renderManager}) {
    _children = build();
  }
  @override
  List<Component> get children => _children;

  void setState(VoidCallback fn) {
    fn();
    _children = build();
    markDirty();
  }

  List<Component> build();

  void markDirty() {
    if (renderManager != null) {
      renderManager!.markDirty(this);
      renderManager!.requestRedraw();
    }
  }

  @override
  int fitHeight() {
    int height = 0;

    for (final child in _children) {
      height += child.fitHeight();
    }
    return height;
  }

  @override
  int fitWidth() {
    int width = 0;

    for (final child in _children) {
      width = max(child.fitWidth(), width);
    }

    return width;
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    for (final child in children) {
      Logger.trace(
        "StatefulComponent",
        "Item ${child} is being rendered",
      );
      child.render(buffer, child.bounds);
    }
  }
}
