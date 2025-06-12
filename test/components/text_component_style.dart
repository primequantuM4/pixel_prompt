import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:test/test.dart';

void main() {
  group("Text component style string tests", () {
    test(
      "Style code for expected composable styles should return expected corresponding ANSI code",
      () {
        final style = TextComponentStyle()
            .foreground(Colors.red)
            .background(Colors.white)
            .bold();

        final expectedAnsiString = "31;47;1";
        final actualAnsiString = style.getStyleAnsi();

        expect(expectedAnsiString == actualAnsiString, isTrue);
      },
    );
  });
}
