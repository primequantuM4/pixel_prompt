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
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/manager/command_mode_handler.dart';
import 'package:pixel_prompt/manager/component_input_handler.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/manager/input_dispatcher.dart';
import 'package:pixel_prompt/manager/input_manager.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';
import 'package:pixel_prompt/terminal/terminal_functions.dart';

/// The root component of a PixelPrompt terminal UI application.
///
/// [App] is the top-level component that contains and lays out all children,
/// and is responsible for initializing the terminal environment, layout,
/// rendering, and input event handling.
///
/// It lays out its children using the provided [direction] (horizontal or vertical),
/// and acts as a container implementing [ParentComponent].
///
/// The [run] extension method initializes the terminal screen, builds the layout,
/// configures focus and input handlers, and renders the first frame.
class App extends Component with ParentComponent {
  /// The list of components that make up the UI.
  @override
  final List<Component> children;

  /// The layout direction for arranging [children] — vertical or horizontal.
  final Axis direction;

  static const String _tag = 'App';

  /// Constructs an [App] with the given [children] and layout [direction].
  App({required this.children, this.direction = Axis.vertical});

  /// Measures the total size needed to render the app based on [maxSize].
  ///
  /// Components with `PositionType.absolute` are ignored in layout measurement.
  /// Returns the combined height (or width) and max child width (or height),
  /// depending on the layout [direction].
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

  /// Renders all children into the given [buffer] using layout bounds [bounds].
  ///
  /// Delegates layout to [LayoutEngine] and recursively renders all children
  /// in computed positions.
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
      Logger.trace(_tag, "Component instance of $component being rendered");
      component.render(buffer, item.rect);
    }
  }

  /// Reserved for future use with dynamic height layout.
  ///
  /// Not yet implemented.
  @override
  int fitHeight() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }

  /// Reserved for future use with dynamic width layout.
  ///
  /// Not yet implemented.
  @override
  int fitWidth() {
    // TODO: Implement once dynamic sizing (flex/grow/shrink) is supported
    throw UnimplementedError();
  }
}

/// Extension that runs the TUI application by bootstrapping all core managers.
///
/// The [run] method initializes:
/// - Terminal size
/// - Canvas rendering
/// - Input handling
/// - Focus and interactivity
///
/// It is the main entry point for any terminal UI application built with
/// the PixelPrompt framework.
///
/// Example usage:
/// ```dart
/// void main() {
///   final app = App(children: [...]);
///   app.run();
/// }
/// ```
extension AppRunner on App {
  /// Initializes and runs the app.
  ///
  /// 1. Reads terminal size using [TerminalFunctions].
  /// 2. Creates a [CanvasBuffer] for rendering.
  /// 3. Initializes input handling, focus, and interactivity.
  /// 4. Measures layout and renders the component tree.
  void run() async {
    final rawTerminalWidth = TerminalFunctions.hasTerminal
        ? TerminalFunctions.terminalWidth + 80
        : 80;
    final rawTerminalHeight = TerminalFunctions.hasTerminal
        ? TerminalFunctions.terminalHeight + 20
        : 20;

    final LayoutEngine engine = LayoutEngine(
      children: children,
      direction: direction,
      bounds:
          Rect(x: 0, y: 0, width: rawTerminalWidth, height: rawTerminalHeight),
    );

    final layoutHeight = engine.fitHeight();
    final layoutWidth = engine.fitWidth();

    final terminalWidth = min(rawTerminalWidth, layoutWidth);
    final terminalHeight = min(rawTerminalHeight, layoutHeight);

    final buffer = CanvasBuffer(
      width: terminalWidth + 40,
      height: terminalHeight + 20,
    );
    final RenderManager renderer = RenderManager(buffer: buffer);
    final Context context = Context();

    final InputDispatcher dispatcher = InputDispatcher(renderer: renderer);
    final InputManager inputManager = InputManager(
      dispatcher: dispatcher,
    );
    final supportsCursor = await inputManager.isCursorSupported();
    if (supportsCursor) {
      Logger.trace(App._tag, "Supports cursor fetching cursor position");
      inputManager.getCursorPosition((x, y) {
        buffer.setTerminalOffset(x + 1, y + 1);
        context.setInitialCursorPosition(x, y);

        inputManager.returnedCursorPositionX = x + 1;
        inputManager.returnedCursorPositionY = y + terminalHeight + 2;
      });
    } else {
      Logger.warn(
        App._tag,
        "Terminal doesn't support cursor. Ignore if this is a test environment",
      );
    }

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
      Size(width: rawTerminalWidth, height: rawTerminalHeight),
    );

    final bounds = Rect(
      x: 0,
      y: 0,
      width: measuredSize.width,
      height: measuredSize.height,
    );

    Logger.trace(App._tag, 'Writing Components to Canvas Buffer');
    render(buffer, bounds);
    Logger.trace(
      App._tag,
      'READY',
    );
    buffer.render();
  }
}
