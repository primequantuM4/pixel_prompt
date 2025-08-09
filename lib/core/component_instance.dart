import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/position.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';

/// The runtime representation of a [Component] in a layout or rendering process.
///
/// A [ComponentInstance] is created from a [Component] and is responsible for:
/// - Tracking layout bounds
/// - Measuring its required size
/// - Rendering itself to a [CanvasBuffer]
///
/// Unlike a [Component], which is an immutable configuration object,
/// a [ComponentInstance] holds mutable state such as [_bounds] and is tied
/// to a specific rendering pass.
///
/// Subclasses must implement:
/// - [measure] to report the component’s desired size
/// - [fitWidth] and [fitHeight] for layout constraints
/// - [render] to draw the component on the screen
///
/// Example:
/// ```dart
/// class MyButtonInstance extends ComponentInstance {
///   @override
///   Size measure(Size maxSize) {
///     // Determine size based on content
///   }
///
///   @override
///   int fitWidth() => 10;
///
///   @override
///   int fitHeight() => 3;
///
///   @override
///   void render(CanvasBuffer buffer, Rect bounds) {
///     // Draw the button
///   }
/// }
/// ```
///
/// See also:
/// - [Component] for the immutable configuration counterpart
/// - [EdgeInsets] for padding
/// - [Position] for placement
/// - [Rect] and [Size] for layout geometry
abstract class ComponentInstance {
  /// The current layout bounds of this component instance.
  ///
  /// These are set by the layout engine before rendering. Accessing [bounds]
  /// before it is set will throw an [Exception].
  Rect? _bounds;

  /// The padding inside the component’s allocated space.
  ///
  /// Defaults to [EdgeInsets.all] with a value of 0.
  final EdgeInsets padding;

  /// The position of this component relative to its parent or container.
  ///
  /// Defaults to `(0, 0)` with a [PositionType.relative] mode.
  final Position position;

  /// Creates a [ComponentInstance] with optional [padding] and [position].
  ComponentInstance({
    this.padding = const EdgeInsets.all(0),
    this.position = const Position(
      x: 0,
      y: 0,
      positionType: PositionType.relative,
    ),
  });

  /// The current layout bounds for this component instance.
  ///
  /// Throws an [Exception] if accessed before being set by the layout engine.
  Rect get bounds {
    if (_bounds == null) throw Exception('Bounds for $this not set yet');
    return _bounds!;
  }

  /// Updates the layout bounds for this component instance.
  set bounds(Rect rect) => _bounds = rect;

  /// Measures the size this component would like to occupy,
  /// given a maximum available size.
  Size measure(Size maxSize);

  /// Returns the width this component should occupy
  /// based on its content or layout rules.
  int fitWidth();

  /// Returns the height this component should occupy
  /// based on its content or layout rules.
  int fitHeight();

  /// Renders the component into the provided [CanvasBuffer]
  /// using the given [bounds] as the drawing area.
  void render(CanvasBuffer buffer, Rect bounds);
}
