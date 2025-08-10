import 'package:pixel_prompt/core/app.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/logger/logger.dart';

/// Manages the rendering lifecycle of components onto a [CanvasBuffer].
///
/// Tracks which [ComponentInstance]s need to be redrawn (dirty components),
/// handles clearing and redrawing their areas, and manages cursor position
/// updates on the terminal screen.
///
/// Coordinates redraw requests efficiently by only rendering components
/// marked as dirty, reducing unnecessary redraws.
///
/// ### Example
/// ```dart
/// final buffer = CanvasBuffer(width: 80, height: 24);
/// final renderManager = RenderManager(buffer: buffer);
///
/// // Mark a component as dirty to trigger redraw
/// renderManager.markDirty(componentInstance);
///
/// // Request redraw of all dirty components
/// renderManager.requestRedraw();
///
/// // Move the cursor to position (10, 5)
/// renderManager.requestCursorMove(10, 5);
/// renderManager.render();
/// ```
///
/// ### See Also
/// - [CanvasBuffer]: The drawing surface used by [RenderManager].
/// - [ComponentInstance]: Represents UI components managed for rendering.
/// - [AppInstance]: Provides app-level flags like [shouldRebuild].
///
/// {@category Core}
/// {@category Rendering}
class RenderManager {
  /// The canvas buffer onto which components are drawn.
  final CanvasBuffer buffer;

  int? _cursorX;
  int? _cursorY;

  /// List of components marked dirty and needing redraw.
  final List<ComponentInstance> _dirtyComponents = [];

  static const String _tag = 'RenderManager';

  /// Creates a [RenderManager] for the given [buffer].
  RenderManager({required this.buffer});

  /// Indicates if a full recompute of layout and rendering is needed.
  bool needsRecompute = false;

  /// Whether there are any dirty components queued for redraw.
  bool get hasDirtyComponents => _dirtyComponents.isNotEmpty;

  /// Marks the given [comp] as dirty, scheduling it for redraw.
  void markDirty(ComponentInstance comp) => _dirtyComponents.add(comp);

  /// Clears the list of dirty components, effectively cancelling redraw requests.
  void clear() {
    _dirtyComponents.clear();
  }

  /// Requests a redraw of all dirty components.
  ///
  /// Does nothing if a full recompute is already pending or app requests rebuild.
  ///
  /// After redrawing dirty components, triggers a final [render] call.
  void requestRedraw() {
    if (needsRecompute || AppInstance.instance.shouldRebuild) return;

    for (var component in _dirtyComponents) {
      buffer.clearBufferArea(component.bounds);
      component.render(buffer, component.bounds);
    }

    _dirtyComponents.clear();
    render();
  }

  /// Requests a full recompute/redraw of the screen inside [bounds].
  ///
  /// Currently clears the entire buffer and clears dirty components.
  void requestRecompute(Rect bounds) {
    buffer.clear();
    _dirtyComponents.clear();
  }

  /// Placeholder to recalculate screen layout or state if needed.
  void recalculateScreen() {}

  /// Requests the cursor be moved to coordinates (x, y) on next render.
  void requestCursorMove(int x, int y) {
    _cursorX = x;
    _cursorY = y;
  }

  /// Renders the buffer to the terminal and moves/shows the cursor if requested.
  ///
  /// If no cursor position was requested, hides the cursor.
  void render() {
    Logger.trace(_tag, 'Redraw requested to canvas buffer');
    buffer.render();

    if (_cursorX != null && _cursorY != null) {
      buffer.moveCursorTo(_cursorX!, _cursorY!);
      buffer.showCursor();
      _cursorX = null;
      _cursorY = null;
    } else {
      buffer.hideCursor();
    }
  }
}
