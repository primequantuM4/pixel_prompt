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

/// A scrollable list of checkboxes arranged either vertically or horizontally.
///
/// The [CheckboxList] component renders a list of labeled checkboxes, supports
/// navigation via arrow keys, and allows toggling selections with the `space`
/// or `enter` keys.
///
/// Each item in the list is represented as a [Checkbox] component internally.
/// Focus and hover states are managed to provide interactive feedback.
///
/// ### Features
/// - Vertical or horizontal layout ([direction]).
/// - Customizable spacing between items ([spacing]).
/// - Supports ANSI color customization for selected, hovered, and text states.
/// - Optional border styling using [BorderStyle].
/// - Keyboard navigation with arrow keys.
/// - Selection toggling via `space` or `enter`.
///
/// ### Example
/// ```dart
/// CheckboxList(
///   items: ['Option A', 'Option B', 'Option C'],
///   selectionColor: AnsiColorType.green,
///   hoverColor: AnsiColorType.yellow,
///   textColor: AnsiColorType.white,
///   borderStyle: BorderStyle.rounded,
///   spacing: 1,
///   direction: Axis.vertical,
/// )
/// ```
///
/// ### See also
/// - [Checkbox] — the individual checkbox component used by [CheckboxList].
/// - [BorderStyle] — to customize the border appearance.
/// - [Axis] — to control vertical or horizontal layout.
///
/// {@category Components}
/// {@category InteractableComponents}
class CheckboxList extends Component {
  /// The text labels for each checkbox.
  final List<String> items;

  /// The number of character spaces between adjacent checkboxes.
  final int spacing;

  /// The ANSI color applied to selected checkboxes.
  final AnsiColorType? selectionColor;

  /// The ANSI color applied to a hovered checkbox.
  final AnsiColorType? hoverColor;

  /// The ANSI color applied to checkbox labels.
  final AnsiColorType? textColor;

  /// The style of the border drawn around the checkbox list.
  final BorderStyle? borderStyle;

  /// The layout direction of the list — either [Axis.vertical] or [Axis.horizontal].
  final Axis direction;

  /// Padding applied around the entire checkbox list.
  final EdgeInsets padding;

  /// Creates a [CheckboxList].
  ///
  /// - [items] must not be null or empty.
  /// - [spacing] controls the gap between items.
  /// - [direction] sets layout orientation.
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

/// Runtime representation of a [CheckboxList] during rendering and interaction.
///
/// Handles measuring, rendering, focus, hover, and keyboard input for a
/// [CheckboxList] component.
///
/// This instance:
/// - Manages the [children] list of [CheckboxInstance] objects.
/// - Keeps track of focus ([focusedItem]) and selection state ([selected]).
/// - Responds to arrow key navigation and space/enter toggles.
/// - Draws a border via [_borderRenderer] if specified.
/// **Note:** This is not meant to be used directly. Instead, construct
/// a [CheckboxList] and let the framework manage its instance.
///
/// {@category Components}
/// {@category InteractableComponents}
class _CheckboxListInstance extends InteractableComponentInstance
    implements ParentComponentInstance {
  /// Child checkbox components representing each list item.
  List<CheckboxInstance> children;

  /// Responsible for rendering the list border.
  final BorderRenderer _borderRenderer;

  /// Index of the currently focused checkbox.
  int focusedItem = 0;

  /// Tracks the total background length (currently unused).
  int backgroundLength = 0;

  /// The set of indices representing selected checkboxes.
  final Set<int> _selected = {};

  /// The original [CheckboxList] component definition.
  final CheckboxList component;

  /// Creates a [_CheckboxListInstance] from a [CheckboxList] definition.
  ///
  /// This constructor:
  /// - Creates a [CheckboxInstance] for each label in [component.items].
  /// - Calculates width padding so all checkboxes align.
  /// - Disables focus for child checkboxes to allow parent list control.
  _CheckboxListInstance(this.component)
    : _borderRenderer = BorderRenderer(
        style: component.borderStyle ?? BorderStyle.rounded,
      ),
      children = component.items
          .map(
            (label) =>
                Checkbox(
                      label: label,
                      selectionColor: component.selectionColor,
                      hoverColor: component.hoverColor,
                      width:
                          component.items.map((s) => s.length).reduce(max) -
                          label.length,
                      textColor: component.textColor,
                    ).createInstance()
                    as CheckboxInstance,
          )
          .toList(),
      super(padding: component.padding) {
    assignParent();
  }

  @override
  List<ComponentInstance> get childrenInstance => children;

  @override
  Axis get direction => component.direction;

  /// Assigns the current instance as the parent to all child checkboxes.
  ///
  /// Also disables focus on individual checkboxes so that navigation is handled
  /// at the list level.
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

  /// Returns the total height needed to fit the checkbox list.
  ///
  /// Depends on [direction]:
  /// - Vertical: number of items + vertical padding + spacing between items.
  /// - Horizontal: a single row plus horizontal padding.
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

  /// Returns the total width needed to fit the checkbox list.
  ///
  /// Includes checkbox symbols (`[]`), label text, padding, and spacing.
  @override
  int fitWidth() {
    final int checkboxWidth = 4;
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

  /// Renders the checkbox list and its children inside an optional border.
  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    _borderRenderer.draw(buffer, bounds, (buffer, innerBounds) {
      for (final child in children) {
        child.render(buffer, child.bounds);
      }
    });
  }

  /// Handles keyboard input for navigation and selection.
  ///
  /// - Arrow keys: move focus between checkboxes.
  /// - `space` or `enter`: toggle selection for the focused checkbox.
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
      return ResponseInput(
        commands: ResponseCommands.none,
        handled: true,
        dirty: [children[focusedItem], children[prevFocusedItem]],
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

  /// Updates [focusedItem] based on arrow key events and list direction.
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
    // Clear hover state when the list loses focus.
    for (final child in children) {
      child.isHovered = false;
    }
  }

  @override
  void onFocus() {
    // Highlight the currently focused checkbox when the list gains focus.
    for (int i = 0; i < children.length; i++) {
      children[i].isHovered = i == focusedItem;
    }
  }

  @override
  void onHover() {}

  @override
  void onClick() {}
}
