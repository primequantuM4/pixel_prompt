import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/logger/logger.dart';

abstract class StatefulComponent extends Component {
  const StatefulComponent();

  @override
  ComponentInstance createInstance() => StatefulComponentInstance(this);

  ComponentState createState();
}

class StatefulComponentInstance extends ParentComponentInstance {
  final StatefulComponent component;
  final List<ComponentInstance> children;

  StatefulComponentInstance(this.component);

  @override
  int fitHeight() {
    int height = 0;

    for (final child in children) {
      height += child.fitHeight();
    }

    height += max(0, children.length - 1) * childGap;
    return height;
  }

  @override
  int fitWidth() {
    int width = 0;

    for (final child in children) {
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
      Logger.trace("StatefulComponent", "Item $child is being rendered");
      child.render(buffer, child.bounds);
    }
  }
}
