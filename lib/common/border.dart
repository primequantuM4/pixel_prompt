enum BorderType { border, rounded, solid }

String horizontalBorderLine(BorderType border) {
  switch (border) {
    case BorderType.rounded:
    case BorderType.border:
      return '─';
    case BorderType.solid:
      return '━';
  }
}

String verticalBorderLine(BorderType border) {
  switch (border) {
    case BorderType.rounded:
    case BorderType.border:
      return '│';

    case BorderType.solid:
      return '┃';
  }
}

String topLeftBorderCorner(BorderType border) {
  switch (border) {
    case BorderType.rounded:
      return '╭';
    case BorderType.border:
      return '┌';
    case BorderType.solid:
      return '┏';
  }
}

String bottomLeftBorderCorner(BorderType border) {
  switch (border) {
    case BorderType.rounded:
      return '╰';
    case BorderType.border:
      return '└';
    case BorderType.solid:
      return '┗';
  }
}

String topRightBorderCorner(BorderType border) {
  switch (border) {
    case BorderType.rounded:
      return '╮';
    case BorderType.border:
      return '┐';
    case BorderType.solid:
      return '┓';
  }
}

String bottomRightBorderCorner(BorderType border) {
  switch (border) {
    case BorderType.rounded:
      return '╯';
    case BorderType.border:
      return '┘';
    case BorderType.solid:
      return '┛';
  }
}
