import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  final CanvasBuffer buffer = CanvasBuffer(width: 100, height: 30);
  final Rect rect = Rect(x: 0, y: 0, width: 0, height: 0);

  App(children: [
    Column(
      children: [
        TextComponent(
          "Pixel Prompt TUI demo",
          style: TextComponentStyle()
              .foreground(ColorRGB(143, 188, 187)) // Frost Blue
              .background(ColorRGB(46, 52, 64)) // Dark Slate
              .paddingTop(1)
              .paddingBottom(1)
              .paddingLeft(12)
              .paddingRight(12)
              .marginLeft(4),
        ),
        Row(
          children: [
            TextComponent(
              'Status: [Ok]',
              style: TextComponentStyle()
                  .foreground(ColorRGB(100, 255, 100))
                  .background(ColorRGB(30, 33, 41))
                  .paddingLeft(4)
                  .paddingRight(4)
                  .marginLeft(4),
            ),
            TextComponent(
              'Uptime: [ 03:42:12]',
              style: TextComponentStyle()
                  .foreground(ColorRGB(255, 100, 100))
                  .background(ColorRGB(30, 33, 41))
                  .paddingLeft(4)
                  .paddingRight(4)
                  .marginLeft(4),
            ),
          ],
        ),
        TextComponent(
          "Info: ",
          style: TextComponentStyle()
              .foreground(ColorRGB(229, 233, 240))
              .background(ColorRGB(20, 25, 35))
              .paddingLeft(2)
              .paddingRight(2)
              .marginLeft(4),
        ),
        TextComponent(
          "Welcome to PixelPrompt!",
          style: TextComponentStyle().marginLeft(8).italic(),
        ),
        TextComponent(
          "This TUI demo shows how rows and columns work.",
          style: TextComponentStyle().marginLeft(8).bold(),
        ),
      ],
    )
  ]).render(buffer, rect);

  buffer.render();
}
