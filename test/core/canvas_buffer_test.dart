import 'package:pixel_prompt/components/colors.dart';
import 'package:pixel_prompt/components/text_component.dart';
import 'package:pixel_prompt/components/text_component_style.dart';
import 'package:pixel_prompt/core/buffer_cell.dart';
import 'package:pixel_prompt/core/canvas_buffer.dart';
import 'package:pixel_prompt/core/rect.dart';
import 'package:pixel_prompt/core/size.dart';
import 'package:test/test.dart';

void main() {
  group('Canvas Buffer', () {
    final List<List<BufferCell>> expectedBuffer = [
      [BufferCell(char: 'H'), BufferCell(char: 'e'), BufferCell(char: 'y')],
      [BufferCell(char: 'T'), BufferCell(char: 'h'), BufferCell(char: 'e')],
    ];

    final List<String> expectedRenderedBuff = [
      '\x1B[0mHey\x1B[0m',
      '\x1B[0mThe\x1B[0m',
    ];

    test(
      'After creating and writing on canvas using draw at the buffer should match the expected buffer',
      () {
        final CanvasBuffer canvasBuffer = CanvasBuffer(width: 3, height: 2);
        canvasBuffer.drawAt(0, 0, 'Hey', TextComponentStyle());
        canvasBuffer.drawAt(0, 1, 'The', TextComponentStyle());

        expect(canvasBuffer.getRenderedString(), expectedRenderedBuff);
        expect(canvasBuffer.getDrawnCanvas(), expectedBuffer);
      },
    );
  });

  test(
    'Some with styling and others with different styling should render the expected output',
    () {
      final CanvasBuffer canvasBuffer = CanvasBuffer(width: 3, height: 2);
      canvasBuffer.drawAt(
        0,
        0,
        'He',
        TextComponentStyle()
            .foreground(ColorRGB(200, 12, 10))
            .background(Colors.white),
      );

      canvasBuffer.drawAt(
        2,
        0,
        'y',
        TextComponentStyle()
            .foreground(ColorRGB(2, 12, 10))
            .background(Colors.highBlack),
      );

      canvasBuffer.drawAt(
        0,
        1,
        'The',
        TextComponentStyle().foreground(Colors.blue),
      );

      final expectedStringBuffer = [
        "\x1B[0;38;2;200;12;10;47mHe\x1B[0;38;2;2;12;10;100my\x1B[0m",
        "\x1B[0;34mThe\x1B[0m",
      ];

      expect(canvasBuffer.getRenderedString(), expectedStringBuffer);
    },
  );

  test('Extra empty space should not interupt the render string', () {
    final CanvasBuffer canvasBuffer = CanvasBuffer(width: 5, height: 3);
    canvasBuffer.drawAt(
      0,
      0,
      'He',
      TextComponentStyle()
          .foreground(ColorRGB(200, 12, 10))
          .background(Colors.white),
    );

    canvasBuffer.drawAt(
      2,
      0,
      'y',
      TextComponentStyle()
          .foreground(ColorRGB(2, 12, 10))
          .background(Colors.highBlack),
    );

    canvasBuffer.drawAt(
      0,
      1,
      'There',
      TextComponentStyle().foreground(Colors.blue).background(Colors.black),
    );

    final expectedStringBuffer = [
      "\x1B[0;38;2;200;12;10;47mHe\x1B[0;38;2;2;12;10;100my\x1B[0m  \x1B[0m",
      "\x1B[0;34;40mThere\x1B[0m",
      "\x1B[0m     \x1B[0m",
    ];

    expect(canvasBuffer.getRenderedString(), expectedStringBuffer);
  });

  test('Two text components with full padding can render next to each other', () {
    final CanvasBuffer canvasBuffer = CanvasBuffer(width: 20, height: 20);
    final TextComponent firstText = TextComponent(
      "Fire",
      style: TextComponentStyle()
          .foreground(ColorRGB(255, 255, 255))
          .background(ColorRGB(255, 68, 34))
          .paddingTop(2)
          .paddingBottom(2)
          .paddingLeft(2)
          .paddingRight(2),
    );

    final TextComponent secondText = TextComponent(
      "Water",
      style: TextComponentStyle()
          .foreground(ColorRGB(255, 255, 255))
          .background(ColorRGB(51, 153, 255))
          .paddingTop(3)
          .paddingBottom(3)
          .paddingLeft(3)
          .paddingRight(3),
    );

    final TextComponent thirdText = TextComponent(
      "Ice",
      style: TextComponentStyle()
          .foreground(ColorRGB(255, 255, 255))
          .background(ColorRGB(102, 204, 255))
          .paddingTop(1)
          .paddingBottom(1)
          .paddingLeft(1)
          .paddingRight(1),
    );
    final firstSize = firstText.measure(Size(width: 20, height: 20));
    final secondSize = secondText.measure(
      Size(width: 20 - firstSize.width, height: 20),
    );
    final thirdSize = firstText.measure(
      Size(width: 20, height: 20 - secondSize.height),
    );

    final firstBounds = Rect(
      x: 0,
      y: 0,
      width: firstSize.width,
      height: firstSize.height,
    );
    final secondBounds = Rect(
      x: firstBounds.x + firstBounds.width,
      y: 0,
      height: secondSize.height,
      width: secondSize.width,
    );
    final thirdBound = Rect(
      x: 0,
      y: firstBounds.x + firstBounds.height,
      width: thirdSize.width,
      height: thirdSize.height,
    );

    firstText.render(canvasBuffer, firstBounds);
    secondText.render(canvasBuffer, secondBounds);
    thirdText.render(canvasBuffer, thirdBound);
    final emptySpace = " " * 20;
    final emptyStyle = "\x1B[0m$emptySpace\x1B[0m";

    final rendered = canvasBuffer.getRenderedString();
    final expected = [
      "\x1B[0;38;2;255;255;255;48;2;255;68;34m        \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;255;68;34m        \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;255;68;34m  Fire  \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;255;68;34m        \x1B[0;38;2;255;255;255;48;2;51;153;255m   Water   \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;255;68;34m        \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;102;204;255m     \x1B[0m   \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;102;204;255m Ice \x1B[0m   \x1B[0;38;2;255;255;255;48;2;51;153;255m           \x1B[0m \x1B[0m",
      "\x1B[0;38;2;255;255;255;48;2;102;204;255m     \x1B[0m               \x1B[0m",
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
      emptyStyle,
    ];

    expect(rendered, expected);
  });
}
