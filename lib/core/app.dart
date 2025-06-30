import 'dart:math';

import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/context.dart';
import 'package:pixel_prompt/core/interactable_registry.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/layout_engine/layout_engine.dart';
import 'package:pixel_prompt/manager/command_mode_handler.dart';
import 'package:pixel_prompt/manager/component_input_handler.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/manager/input_dispatcher.dart';
import 'package:pixel_prompt/manager/input_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';

class App extends Component with ParentComponent {
  @override
  final List<Component> children;
  final Axis direction;

  App({required this.children, this.direction = Axis.vertical});

  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    for (final child in children) {
      if (child.position?.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalHeight += childSize.height;

      maxWidth = max(childSize.width, maxWidth);
    }

    return Size(width: maxWidth, height: totalHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final LayoutEngine engine = LayoutEngine(
      children: children,
      direction: direction,
      bounds: bounds,
    );

    final positionedItems = engine.compute();

    for (var item in positionedItems) {
      final component = item.component;
      component.render(buffer, item.rect);
    }
  }

  @override
  int fitHeight() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }

  @override
  int fitWidth() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }
}

extension AppRunner on App {
  void run() {
    // TODO: replace constant integers with terminalColumns and terminalLines
    final terminalWidth = 80;
    final terminalHeight = 44;

    final buffer = CanvasBuffer(width: terminalWidth, height: terminalHeight);
    final RenderManager renderer = RenderManager(buffer: buffer);
    final Context context = Context();

    final InputDispatcher dispatcher = InputDispatcher(renderer: renderer);
    final InputManager inputManager = InputManager(dispatcher: dispatcher);

    inputManager.getCursorPosition((x, y) {
      buffer.setTerminalOffset(x + 1, y + 1);
      context.setInitialCursorPosition(x, y);

      final FocusManager focusManager = FocusManager(context: context);
      final ComponentInputHandler componentInputHandler = ComponentInputHandler(
        focusManager,
      );

      final InteractableRegistry registry = InteractableRegistry();

      registry.registerInteractables(this, focusManager, renderer);

      final List<InputHandler> handlers = [
        focusManager,
        CommandModeHandler(),
        componentInputHandler,
      ];

      for (var handler in handlers) {
        dispatcher.registerHandler(handler);
      }

      final measuredSize = measure(
        Size(width: terminalWidth, height: terminalHeight),
      );

      final bounds = Rect(
        x: 0,
        y: 0,
        width: measuredSize.width,
        height: measuredSize.height,
      );

      render(buffer, bounds);
      buffer.render();
    });
  }
}
