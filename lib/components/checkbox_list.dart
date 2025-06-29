import 'dart:math';

import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/components/checkbox.dart';
import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/interactable_component.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';

class CheckboxList extends InteractableComponent with ParentComponent {
  @override
  List<Checkbox> children;
  final List<String> items;
  final Axis direction;
  final int spacing;
  final AnsiColorType? selectionColor;
  final AnsiColorType? hoverColor;
  final AnsiColorType? textColor;
  int focusedItem = 0;
  // final Set<int> _selected = {};

  CheckboxList({
    required this.items,
    Axis? direction,
    int? spacing,
    this.selectionColor,
    this.hoverColor,
    this.textColor,
  }) : direction = direction ?? Axis.vertical,
       children = items
           .map(
             (label) => Checkbox(
               label: label,
               selectionColor: selectionColor,
               hoverColor: hoverColor,
               textColor: textColor,
             ),
           )
           .toList(),
       spacing = spacing ?? 1;

  @override
  int fitHeight() {
    switch (direction) {
      case Axis.vertical:
        return items.length + (items.length - 1) * spacing;
      case Axis.horizontal:
        return 1;
    }
  }

  @override
  int fitWidth() {
    final int checkboxWidth =
        4; // considering the characters '[]' with an empty space/'X' and a trailing space
    switch (direction) {
      case Axis.vertical:
        int width = 0;
        for (var item in items) {
          width = max(item.length, width);
        }
        return width + checkboxWidth;
      case Axis.horizontal:
        int width = 0;
        for (var item in items) {
          width += checkboxWidth + item.length;
        }

        return width + (items.length - 1) * spacing;
    }
  }

  @override
  Size measure(Size maxSize) {
    return Size(width: fitWidth(), height: fitHeight());
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final engine = LayoutEngine(
      children: children,
      direction: direction,
      bounds: bounds,
    );

    switch (direction) {
      case Axis.vertical:
        _renderVertical(buffer, bounds, engine);
      case Axis.horizontal:
        _renderHorizontal(buffer, bounds, engine);
    }
  }

  void _renderVertical(CanvasBuffer buffer, Rect bounds, LayoutEngine engine) {
    int y = bounds.y;
    int x = bounds.x;

    final positionedComponent = engine.compute();
    for (int i = 0; i < positionedComponent.length; i++) {
      final item = positionedComponent[i];
      item.component.render(
        buffer,
        Rect(width: bounds.width, height: bounds.height, x: x, y: y),
      );
      y += spacing + 1;
    }
  }

  void _renderHorizontal(
    CanvasBuffer buffer,
    Rect bounds,
    LayoutEngine engine,
  ) {
    int x = bounds.x;
    int y = bounds.y;

    final positionedComponent = engine.compute();

    for (int i = 0; i < positionedComponent.length; i++) {
      final item = positionedComponent[i];
      (item.component as Checkbox).isHovered = i == focusedItem;
      item.component.render(
        buffer,
        Rect(width: bounds.width, height: bounds.height, x: x, y: y),
      );
      x += (item.component as Checkbox).contentWidth + spacing;
    }
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent) return ResponseInput.ignored();

    bool handled = false;
    int prevFocusedItem = focusedItem;
    switch (event.code) {
      case KeyCode.arrowUp:
        if (direction == Axis.vertical && focusedItem > 0) {
          focusedItem = (focusedItem - 1 + children.length) % children.length;
        }
        handled = true;
        break;
      case KeyCode.arrowDown:
        if (direction == Axis.vertical && focusedItem < children.length - 1) {
          focusedItem = (focusedItem + 1) % children.length;
        }
        handled = true;
        break;
      case KeyCode.arrowRight:
        if (direction == Axis.horizontal && focusedItem < children.length - 1) {
          focusedItem = (focusedItem + 1) % children.length;
        }
        handled = true;
      case KeyCode.arrowLeft:
        if (direction == Axis.horizontal && focusedItem > 0) {
          focusedItem = (focusedItem - 1 + children.length) % children.length;
        }
        handled = true;
        break;

      default:
      // handle other cases here ignore for now
    }

    if (handled) {
      children[prevFocusedItem].isHovered = false;
      children[focusedItem].isHovered = true;
      children[focusedItem].handleInput(event);
    }
    final List<Checkbox> dirtyComponents = [
      children[focusedItem],
      children[prevFocusedItem],
    ];
    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: dirtyComponents,
    );
  }

  @override
  void onBlur() {
    // TODO: implement onBlur
  }

  @override
  void onFocus() {
    // TODO: implement onFocus
  }

  @override
  void onHover() {
    // TODO: implement onHover
  }
  @override
  void onClick() {}
}
