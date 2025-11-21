import 'package:pixel_prompt/components/sized_box_style.dart';
import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/pixel_prompt.dart';
import 'package:pixel_prompt/renderer/border_renderer.dart';

/// A component that provides a fixed [size] constraint for its child.
///
/// The [SizedBox] component is used to impose specific [width] and [height]
/// constraints on its [child]. If the child component is smaller than the
/// specified [size], the [SizedBox] will fill the remaining space with
/// whitespace. It does not force the child to expand to fill the entire box,
/// but rather limits the maximum available space for the child.
///
/// This is particularly useful for:
/// - Creating fixed-size spacers or gaps in layouts.
/// - Providing a maximum size constraint for a child, while allowing it to be smaller.
/// - Ensuring consistent sizing for interactive elements like buttons or text fields.
///
/// The [margin] property adds empty space around the [SizedBox] itself,
/// effectively pushing other components away. The [padding] property adds
/// empty space *inside* the [SizedBox], between its own border and its [child].
///
/// Example:
/// ```dart
/// SizedBox(
///   size: Size(width: 10, height: 5),
///   margin: EdgeInsets.all(1),
///   padding: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
///   child: TextComponent('Limited Size'),
/// );
/// ```
///
/// See also:
/// - [Size], for defining the width and height.
/// - [EdgeInsets], for defining margins and paddings.
///
/// {@category Components}
class SizedBox extends Component {
  /// The component to be constrained by this [SizedBox].
  final Component child;

  /// The fixed [Size] that this [SizedBox] will provide as a constraint to its child.
  /// If the child is smaller, the remaining space will be filled with whitespace.
  final Size size;

  /// Empty space to inscribe around the [SizedBox].
  ///
  /// The [margin] is added to the total size of the [SizedBox] when measured
  /// by its parent.
  final EdgeInsets margin;

  /// The style to apply to the [SizedBox], including background color and border.
  final SizedBoxStyle? style;

  /// Creates a [SizedBox] with a specific [size] for its [child].
  ///
  /// The [child] and [size] parameters are required. The [margin] defaults
  /// to [EdgeInsets.all(0)] if not provided.
  const SizedBox({
    required this.child,
    required this.size,
    this.margin = const EdgeInsets.all(0),
    this.style,
    super.padding,
  });

  @override
  ComponentInstance createInstance() =>
      _SizedBoxInstance(this, size, padding: padding, margin: margin, style: style);
}

/// The runtime instance of a [SizedBox] component.
///
/// This class manages the layout and rendering of the [SizedBox] at runtime.
/// It ensures that the child component is rendered within the specified [size]
/// and applies any [margin] or [padding] defined by the [SizedBox].
///
/// {@category Components}
class _SizedBoxInstance extends ComponentInstance {
  final ComponentInstance _childInstance;

  final Size size;
  final EdgeInsets margin;
  final SizedBoxStyle? style;

  _SizedBoxInstance(
    SizedBox component,
    this.size, {
    super.padding,
    this.margin = const EdgeInsets.all(0),
    this.style,
  }) : _childInstance = component.child.createInstance();

  @override
  Size measure(Size maxSize) {
    return Size(
      width: size.width + margin.horizontal,
      height: size.height + margin.vertical,
    );
  }

  @override
  int fitHeight() => size.height + margin.vertical;

  @override
  int fitWidth() => size.width + margin.horizontal;

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    if (style?.backgroundColor != null) {
      buffer.fill(bounds, style!.backgroundColor!);
    }

    if (style?.border != null) {
      final borderRenderer = BorderRenderer(
        style: style!.border!,
        borderColor: style!.backgroundColor,
      );
      borderRenderer.draw(buffer, bounds, (buffer, innerBounds) {
        _childInstance.render(
          buffer,
          Rect(
            x: innerBounds.x + padding.left,
            y: innerBounds.y + padding.top,
            width: innerBounds.width - padding.horizontal,
            height: innerBounds.height - padding.vertical,
          ),
        );
      });
    } else {
      _childInstance.render(
        buffer,
        Rect(
          x: bounds.x + padding.left,
          y: bounds.y + padding.top,
          width: bounds.width - padding.horizontal,
          height: bounds.height - padding.vertical,
        ),
      );
    }
  }
}
