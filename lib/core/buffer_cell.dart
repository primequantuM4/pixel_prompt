import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/font_style.dart';

/// A single character cell in the terminal UI buffer.
///
/// Each [BufferCell] represents one printable cell on the terminal grid,
/// holding a character, foreground/background color, and font styling.
/// This is the fundamental unit used by the rendering engine to track
/// visual content.
///
/// The cell is mutable and can be cleared or compared to others
/// for optimized redraws or diffing purposes.
class BufferCell {
  /// The character rendered in the cell.
  ///
  /// **Must** be a single character string.
  String char;

  /// The optional foreground color of the cell.
  AnsiColorType? fg;

  /// The optional background color of the cell.
  AnsiColorType? bg;

  /// A set of font styles (e.g., bold, italic) applied to this cell.
  Set<FontStyle> styles;

  /// Creates a [BufferCell] with the given [char], optional [fg], [bg],
  /// and a set of [styles].
  ///
  /// If [styles] is not provided, it defaults to an empty set.
  BufferCell({
    required this.char,
    this.fg,
    this.bg,
    Set<FontStyle>? styles,
  }) : styles = {
          ...(styles ?? {})
        }; // copying since TextComponentStyle is not modifiable

  /// Clears the contents of this cell.
  ///
  /// Resets [char] to a space `' '`, removes any foreground/background color,
  /// and clears all font styles.
  void clear() {
    char = ' ';
    fg = null;
    bg = null;
    styles.clear();
  }

  /// Compares this cell to [other] for value equality.
  ///
  /// Two cells are equal if their character, foreground, background,
  /// and styles match.
  @override
  bool operator ==(Object other) {
    return other is BufferCell &&
        (other.char == char &&
            other.fg == fg &&
            other.bg == bg &&
            _setEquals(other.styles, styles));
  }

  /// Returns a hash code based on the character, colors, and styles.
  @override
  int get hashCode =>
      Object.hash(char, fg, bg, Object.hashAllUnordered(styles));

  /// Compares two sets for unordered equality.
  bool _setEquals(Set a, Set b) {
    return a.length == b.length && a.containsAll(b);
  }
}
