import 'dart:math';

import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/pixel_prompt.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

typedef VoidCallback = void Function();

abstract class StatefulComponent extends Component with ParentComponent {
  List<Component> _children = [];
  final int childGap = 1;

  RenderManager? renderManager;

  StatefulComponent({this.renderManager}) {
    _children = build();
  }
  @override
  List<Component> get children => _children;

  set children(List<Component> childrens) => _children = childrens;

  void setState(VoidCallback fn) {
    fn();
    rebuild();
    App.instance.requestRebuild();
  }

  void rebuild() {
    children = build();
  }

  List<Component> build();

  void markDirty() {
    if (renderManager != null) {
      renderManager!.needsRecompute = true;
    }
  }

  @override
  int fitHeight() {
    int height = 0;

    for (final child in _children) {
      height += child.fitHeight();
    }

    height += max(0, children.length - 1) * childGap;
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
        "Item $child is being rendered",
      );
      child.render(buffer, child.bounds);
    }
  }
}
