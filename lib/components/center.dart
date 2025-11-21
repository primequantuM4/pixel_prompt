import 'package:pixel_prompt/core/component_instance.dart';
import 'package:pixel_prompt/core/parent_component_instance.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

/// A component that centers its [child] within the available space.
///
/// The [Center] component attempts to size itself to the largest possible
/// extent in its parent, and then centers its [child] within that space.
/// If the child is larger than the available space, the child will be
/// clipped.
///
/// Example:
/// ```dart
/// Center(
///   child: TextComponent('Centered Text'),
/// );
/// ```
///
/// {@category Components}
class Center extends Component {
  /// The component to be centered.
  final Component child;

  /// Creates a [Center] component with the given [child].
  const Center({required this.child});

  @override
  ComponentInstance createInstance() => _CenterInstance(component: this);
}

/// The runtime instance of a [Center] component.
///
/// This class manages the layout and rendering of the [Center] component
/// at runtime, ensuring its child is centered within the available bounds.
///
class _CenterInstance extends ParentComponentInstance {
  /// The child component instance to be centered.
  final ComponentInstance _childInstance;

  /// Creates a [_CenterInstance] for the given [Center] component.
  _CenterInstance({required Center component})
    : _childInstance = component.child.createInstance(),
      super(component);

  @override
  List<ComponentInstance> get childrenInstance => [_childInstance];

  @override
  Size measure(Size maxSize) => maxSize;

  @override
  int fitHeight() => _childInstance.fitHeight();

  @override
  int fitWidth() => _childInstance.fitWidth();

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final childSize = _childInstance.measure(
      Size(width: bounds.width, height: bounds.height),
    );

    final double offsetX = (bounds.width - childSize.width) / 2;
    final double offsetY = (bounds.height - childSize.height) / 2;

    final childRect = Rect(
      x: bounds.x + offsetX.toInt(),
      y: bounds.y + offsetY.toInt(),
      width: childSize.width,
      height: childSize.height,
    );

    _childInstance.render(buffer, childRect);
  }
}
