import 'dart:math';

import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/checkbox.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/interactable_component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/renderer/border_renderer.dart';

class CheckboxList extends Component {
  final List<String> items;
  final int spacing;
  final AnsiColorType? selectionColor;
  final AnsiColorType? hoverColor;
  final AnsiColorType? textColor;
  final BorderStyle? borderStyle;
  final Axis direction;
  final EdgeInsets padding;

  const CheckboxList({
    required this.items,
    this.selectionColor,
    this.hoverColor,
    this.textColor,
    this.borderStyle,
    this.padding = const EdgeInsets.all(1),
    this.spacing = 1,
    this.direction = Axis.vertical,
  }) : super(padding: padding);
  @override
  ComponentInstance createInstance() => _CheckboxListInstance(this);
}

class _CheckboxListInstance extends InteractableComponentInstance
    implements ParentComponentInstance {
  List<CheckboxInstance> children;
  final BorderRenderer _borderRenderer;

  int focusedItem = 0;
  int backgroundLength = 0;
  final Set<int> _selected = {};

  final CheckboxList component;
  _CheckboxListInstance(this.component)
      : _borderRenderer = BorderRenderer(
          style: component.borderStyle ?? BorderStyle.rounded,
        ),
        children = component.items
            .map(
              (label) => Checkbox(
                label: label,
                selectionColor: component.selectionColor,
                hoverColor: component.hoverColor,
                width: component.items.map((s) => s.length).reduce(max) -
                    label.length,
                textColor: component.textColor,
              ).createInstance() as CheckboxInstance,
            )
            .toList(),
        super(padding: component.padding) {
    assignParent();
  }

  @override
  List<ComponentInstance> get childrenInstance => children;

  @override
  Axis get direction => component.direction;

  void assignParent() {
    for (var checkbox in children) {
      checkbox.focusable = false;
    }
  }

  @override
  bool shouldRenderChild(ComponentInstance child) {
    return child is CheckboxInstance;
  }

  @override
  bool get isFocusable => true;

  @override
  bool get wantsInput => true;

  @override
  int fitHeight() {
    switch (direction) {
      case Axis.vertical:
        return component.items.length +
            component.padding.vertical +
            (component.items.length - 1) * component.spacing;
      case Axis.horizontal:
        return 1 + component.padding.horizontal;
    }
  }

  @override
  int fitWidth() {
    final int checkboxWidth =
        4; // considering the characters '[]' with an empty space/'X' and a trailing space
    switch (direction) {
      case Axis.vertical:
        int width = 0;
        for (var item in component.items) {
          width = max(item.length, width);
        }
        return width + checkboxWidth + component.padding.vertical;
      case Axis.horizontal:
        int width = 0;
        for (var item in component.items) {
          width += checkboxWidth + item.length;
        }

        return width +
            component.padding.horizontal +
            (component.items.length - 1) * component.spacing;
    }
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    _borderRenderer.draw(buffer, bounds, (buffer, innerBounds) {
      for (final child in children) {
        child.render(buffer, child.bounds);
      }
    });
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent) return ResponseInput.ignored();
    if (event.code == KeyCode.arrowUp ||
        event.code == KeyCode.arrowDown ||
        event.code == KeyCode.arrowLeft ||
        event.code == KeyCode.arrowRight) {
      int prevFocusedItem = focusedItem;

      _handleArrowEvents(event);

      children[prevFocusedItem].isHovered = false;
      children[focusedItem].isHovered = true;

      final List<CheckboxInstance> dirtyComponents = [
        children[focusedItem],
        children[prevFocusedItem],
      ];
      return ResponseInput(
        commands: ResponseCommands.none,
        handled: true,
        dirty: dirtyComponents,
      );
    }

    if (event.char == '\n' || event.char == ' ') {
      if (_selected.contains(focusedItem)) {
        _selected.remove(focusedItem);
      } else {
        _selected.add(focusedItem);
      }
      return children[focusedItem].handleInput(event);
    }

    return ResponseInput.ignored();
  }

  void _handleArrowEvents(KeyEvent event) {
    switch (event.code) {
      case KeyCode.arrowUp:
        if (direction == Axis.vertical && focusedItem > 0) {
          focusedItem = (focusedItem - 1 + children.length) % children.length;
        }
        break;
      case KeyCode.arrowDown:
        if (direction == Axis.vertical && focusedItem < children.length - 1) {
          focusedItem = (focusedItem + 1) % children.length;
        }
        break;
      case KeyCode.arrowRight:
        if (direction == Axis.horizontal && focusedItem < children.length - 1) {
          focusedItem = (focusedItem + 1) % children.length;
        }
      case KeyCode.arrowLeft:
        if (direction == Axis.horizontal && focusedItem > 0) {
          focusedItem = (focusedItem - 1 + children.length) % children.length;
        }
        break;
      default:
        throw Exception("Trying to handle other key than arrow key");
    }
  }

  @override
  void onBlur() {
    // make sure to remove any unrelated drawings like hovering color etc when blurred
    for (final child in children) {
      child.isHovered = false;
    }
  }

  @override
  void onFocus() {
    // when checkbox list gains focus
    // make sure to have one of the components as hovered
    for (int i = 0; i < children.length; i++) {
      children[i].isHovered = i == focusedItem;
    }
  }

  @override
  void onHover() {}

  @override
  void onClick() {}
}
