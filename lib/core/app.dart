import 'dart:async';
import 'dart:math';

import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
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
import 'package:pixel_prompt/layout_engine/positioned_component.dart';
import 'package:pixel_prompt/logger/logger.dart';
import 'package:pixel_prompt/manager/command_mode_handler.dart';
import 'package:pixel_prompt/manager/component_input_handler.dart';
import 'package:pixel_prompt/manager/focus_manager.dart';
import 'package:pixel_prompt/manager/input_dispatcher.dart';
import 'package:pixel_prompt/manager/input_manager.dart';
import 'package:pixel_prompt/manager/input_registry.dart';
import 'package:pixel_prompt/renderer/render_manager.dart';
import 'package:pixel_prompt/terminal/terminal_functions.dart';

/// The root-level [Component] of an application.
///
/// An [App] serves as the entry point and container for the entire UI tree.
/// It holds a list of child [Component]s and defines the layout direction
/// (horizontal or vertical) for arranging them.
///
/// The [layoutDirection] determines how the [children] are laid out:
/// - [Axis.vertical] (default) stacks them top-to-bottom.
/// - [Axis.horizontal] arranges them left-to-right.
///
/// Example:
/// ```dart
/// final app = App(
///   layoutDirection: Axis.vertical, // default
///   children: [
///     TextComponent('Hello'),
///     ButtonComponent(label: 'Click me', onPressed: () {}),
///   ],
/// ).run();
/// ```
///
/// The [run] extension method initializes the terminal screen, builds the layout,
/// configures focus and input handlers, and renders the first frame.
/// See also:
/// - [AppInstance], the runtime representation of an [App] during rendering.
/// - [ComponentInstance], the base type for all runtime component instances.
///
/// {@category Core}
class App extends Component {
  /// The list of [Component]s that make up this application’s UI.
  final List<Component> children;

  /// The direction in which [children] are arranged.
  final Axis layoutDirection;

  static const String _tag = 'App';

  /// Creates an [App] with the given [children] and an optional
  /// [layoutDirection] (default is [Axis.vertical]).
  const App({required this.children, this.layoutDirection = Axis.vertical});

  /// Returns the [layoutDirection] for this [App].
  Axis get direction => layoutDirection;

  @override
  ComponentInstance createInstance() => AppInstance(this);
}

/// The root [ComponentInstance] for a Pixel Prompt application.
///
/// An `AppInstance` is a specialized [ParentComponentInstance]
/// that owns the top-level component tree and coordinates rendering.
///
/// It is a singleton during the app's lifetime, accessible via [AppInstance.instance].
///
/// ### Responsibilities:
/// - Hold the root component ([App]) and its child instances.
/// - Perform layout measurement for the entire application.
/// - Render components to the terminal buffer.
/// - Schedule and manage rebuilds.
///
/// ### Lifecycle:
/// - Created once at app startup.
/// - Rebuilds occur when [requestRebuild] is called.
/// - Rendering happens through [render], which delegates to the layout engine.
/// ### See also:
/// - [App] — the root component type used to define the application's UI.
/// - [ComponentInstance] — the base interface implemented by all component instances.
///
/// {@category Core}
class AppInstance extends ParentComponentInstance {
  /// The root [App] component.
  final App component;

  /// Current set of root-level child component instances.
  List<ComponentInstance> _childrenInstance;

  /// The initially created children, preserved for reference.
  List<ComponentInstance> initialChildren;

  AppInstance(this.component)
    : _childrenInstance = [],
      initialChildren = [],
      super(component) {
    // Make this the global singleton instance.
    AppInstance.instance = this;

    // Build the initial child component instances.
    final created = component.children
        .map((Component comp) => comp.createInstance())
        .toList();

    _childrenInstance = created;
    initialChildren = List.from(created);
  }

  /// Returns the current set of root-level children.
  @override
  List<ComponentInstance> get childrenInstance => _childrenInstance;

  static const String _tag = 'App';

  /// Global singleton instance of the app.
  static late AppInstance instance;

  /// Whether the app should perform a rebuild in the next cycle.
  bool shouldRebuild = false;

  /// Marks the app as needing a rebuild.
  void requestRebuild() {
    shouldRebuild = true;
  }

  @override
  int fitHeight() {
    // Not yet implemented.
    throw UnimplementedError();
  }

  @override
  int fitWidth() {
    // Not yet implemented.
    throw UnimplementedError();
  }

  /// Measures the total size required to render all children.
  ///
  /// Skips absolutely positioned children since they don't contribute
  /// to the parent's flow layout dimensions.
  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    for (final child in _childrenInstance) {
      if (child.position.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalHeight += childSize.height;
      maxWidth = max(childSize.width, maxWidth);
    }

    return Size(width: maxWidth, height: totalHeight);
  }

  /// Renders the app by delegating to the layout engine and drawing
  /// each positioned child to the [CanvasBuffer].
  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final LayoutEngine engine = LayoutEngine(
      rootInstance: this,
      children: _childrenInstance,
      direction: direction,
      bounds: bounds,
    );

    final maxSize = Size(
      width: TerminalFunctions.hasTerminal
          ? TerminalFunctions.terminalWidth
          : 80,
      height: TerminalFunctions.hasTerminal
          ? TerminalFunctions.terminalHeight
          : 20,
    );

    final positionedItems = engine.compute(maxSize);
    _renderPositionedComponents(buffer, positionedItems);
  }

  /// Helper for rendering each component at its assigned position.
  void _renderPositionedComponents(
    CanvasBuffer buffer,
    List<PositionedComponentInstance> positionedComponents,
  ) {
    for (var item in positionedComponents) {
      final component = item.componentInstance;

      if (item.parentComponentInstance != null) {
        Logger.trace(
          _tag,
          "Component instance of $component is being rendered by their parent component",
        );
        continue;
      }

      Logger.trace(_tag, "Component instance of $component being rendered");
      component.render(buffer, item.rect);
    }
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
    final AppInstance appInstance = createInstance() as AppInstance;

    final rawTerminalWidth = TerminalFunctions.hasTerminal
        ? TerminalFunctions.terminalWidth
        : 80;
    final rawTerminalHeight = TerminalFunctions.hasTerminal
        ? TerminalFunctions.terminalHeight
        : 20;

    final LayoutEngine engine = LayoutEngine(
      rootInstance: appInstance,
      children: appInstance.childrenInstance,
      direction: direction,
      bounds: Rect(
        x: 0,
        y: 0,
        width: rawTerminalWidth,
        height: rawTerminalHeight,
      ),
    );

    final layoutHeight = engine.fitHeight();
    final layoutWidth = engine.fitWidth();

    final terminalWidth = min(rawTerminalWidth, layoutWidth);
    final terminalHeight = min(rawTerminalHeight, layoutHeight);

    final buffer = CanvasBuffer(width: terminalWidth, height: terminalHeight);
    final RenderManager renderer = RenderManager(buffer: buffer);
    final Context context = Context();

    final InputDispatcher dispatcher = InputDispatcher(renderer: renderer);
    final InputManager inputManager = InputManager(dispatcher: dispatcher);
    final supportsCursor = await inputManager.isCursorSupported();
    if (supportsCursor) {
      Logger.trace(App._tag, "Supports cursor fetching cursor position");
      final point = await inputManager.fetchCursorPosition();
      buffer.setTerminalOffset(point.x + 1, point.y + 1);
      context.setInitialCursorPosition(point.x, point.y);

      inputManager.returnedCursorPositionX = point.x + 1;
      inputManager.returnedCursorPositionY = point.y + terminalHeight + 2;
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

    registry.registerInteractables(appInstance, focusManager, renderer);

    final List<InputHandler> handlers = [
      focusManager,
      CommandModeHandler(),
      componentInputHandler,
    ];

    for (var handler in handlers) {
      dispatcher.registerHandler(handler);
    }

    for (final handler in InputRegistry.handlers) {
      Logger.trace(App._tag, 'Registering handler $handler');
      dispatcher.registerHandler(handler);
    }

    final measuredSize = appInstance.measure(
      Size(width: rawTerminalWidth, height: rawTerminalHeight),
    );

    final bounds = Rect(
      x: 0,
      y: 0,
      width: measuredSize.width,
      height: measuredSize.height,
    );

    Logger.trace(App._tag, 'Writing Components to Canvas Buffer');
    appInstance.render(buffer, bounds);
    Logger.trace(App._tag, 'READY');
    buffer.render();

    Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (appInstance.shouldRebuild || renderer.needsRecompute) {
        appInstance.shouldRebuild = false;
        appInstance._childrenInstance =
            appInstance.initialChildren; // reassign to reset any tree state

        buffer.clear();

        focusManager.reset();
        registry.registerInteractables(appInstance, focusManager, renderer);

        final engine = LayoutEngine(
          rootInstance: appInstance,
          children: appInstance.childrenInstance,
          direction: direction,
          bounds: Rect(x: 0, y: 0, width: bounds.width, height: bounds.height),
        );

        final int termWidth = min(engine.fitWidth(), rawTerminalWidth);
        final int termHeight = min(engine.fitHeight(), rawTerminalHeight);

        var (x, y) = buffer.getTerminalOffset();

        inputManager.returnedCursorPositionX = x + 1;
        inputManager.returnedCursorPositionY = y + termWidth + 2;

        buffer.updateDimensions(termWidth, termHeight);

        final items = engine.compute(
          Size(width: bounds.width, height: bounds.height),
        );

        renderer.requestRecompute(bounds);
        renderer.needsRecompute = false;
        appInstance._renderPositionedComponents(buffer, items);
        buffer.render();
      }
    });
  }
}
