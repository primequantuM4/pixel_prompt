import 'package:pixel_prompt/core/axis.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';

/// The base class for all renderable UI components in the framework.
///
/// A [Component] defines the minimal contract for a terminal UI element,
/// including layout sizing, positioning, and rendering.
///
/// It is intended to be subclassed by concrete widgets such as boxes, text,
/// buttons, etc.
///
/// Each component may be optionally positioned using a [Position].
/// The layout engine is responsible for calling [bounds] during layout
/// computation, which must happen before [render] is called.
///
/// Subclasses must implement:
/// - [measure] to report their preferred size given a constraint,
/// - [fitWidth] and [fitHeight] to determine growth behavior in layout,
/// - [render] to draw themselves into a [CanvasBuffer].
abstract class Component {
  EdgeInsets padding = EdgeInsets.all(0);

  /// Optional position specifier.
  final Position? position;

  Rect? _bounds;

  /// The bounding rectangle of the component.
  ///
  /// This is set by the layout engine during layout, and is required
  /// before rendering. Accessing [bounds] before it is set will throw
  /// an [Exception]
  Rect get bounds {
    if (_bounds == null) throw Exception("Component bounds not set yet");
    return _bounds!;
  }

  set bounds(Rect bounds) => _bounds = bounds;

  /// Creates a component with an optional [position].
  Component({this.position});

  /// Measures the component’s preferred size given a [maxSize] constraint.
  ///
  /// This is used by the layout system to determine how much space the
  /// component would like to occupy.
  Size measure(Size maxSize);

  /// Returns the minimum width this component needs to be laid out.
  int fitWidth();

  /// Returns the minimum height this component needs to be laid out.
  int fitHeight();

  /// Renders this component into the [buffer] using the given [bounds].
  ///
  /// Called during the paint phase after layout is complete.
  void render(CanvasBuffer buffer, Rect bounds);
}

/// A mixin for components that act as containers for child components.
///
/// Classes mixing in [ParentComponent] must expose a list of [children]
/// which the layout system will recursively measure, layout, and render.
///
/// This is used by layout containers like `Column`, `Row`, or custom panels
/// that nest multiple child components.
mixin ParentComponent on Component {
  List<Component> get children;

  Axis get direction => Axis.vertical;
}
