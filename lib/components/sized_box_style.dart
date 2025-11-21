import 'package:pixel_prompt/components/border_style.dart';
import 'package:pixel_prompt/components/colors.dart';

/// Defines the visual style for a [SizedBox] component, including its
/// background color and border.
///
/// A [SizedBoxStyle] encapsulates the styling information that determines
/// how a [SizedBox] is displayed in the terminal.
///
/// ### Styling Options
/// - **Background Color:** Controlled by [backgroundColor] using [AnsiColorType].
/// - **Border:** Controlled by [border] using [BorderStyle].
///
/// ### Example
/// ```dart
/// final style = SizedBoxStyle(
///   backgroundColor: Colors.blue,
///   border: BorderStyle.solid,
/// );
/// ```
///
/// ### See Also
/// - [AnsiColorType] for color definitions.
/// - [BorderStyle] for border definitions.
///
/// {@category Styling}
class SizedBoxStyle {
  /// The background color of the [SizedBox].
  final AnsiColorType? backgroundColor;

  /// The border style of the [SizedBox].
  final BorderStyle? border;

  /// Creates a [SizedBoxStyle] with an optional background color and border.
  const SizedBoxStyle({
    this.backgroundColor,
    this.border,
  });

  /// Returns a new [SizedBoxStyle] with the given properties overridden.
  ///
  /// Properties not specified will be copied from the current style.
  SizedBoxStyle copyWith({
    AnsiColorType? backgroundColor,
    BorderStyle? border,
  }) {
    return SizedBoxStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
    );
  }
}
