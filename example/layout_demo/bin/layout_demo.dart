import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  App(children: [
    Column(
      children: [
        TextComponent(
          "Pixel Prompt TUI demo",
          style: TextComponentStyle()
              .foreground(ColorRGB(143, 188, 187))
              .background(ColorRGB(46, 52, 64))
              .paddingOnly(left: 12, right: 12, top: 1, bottom: 1)
              .marginOnly(left: 4),
        ),
        Row(
          children: [
            TextComponent(
              'Status: [Ok]',
              style: TextComponentStyle(
                color: ColorRGB(100, 255, 100),
                bgColor: ColorRGB(30, 33, 41),
                padding: EdgeInsets.symmetric(horizontal: 4),
                margin: EdgeInsets.only(left: 4),
              ),
            ),
            TextComponent(
              'Uptime: [03:42:12]',
              style: TextComponentStyle(
                color: ColorRGB(255, 100, 100),
                bgColor: ColorRGB(30, 33, 41),
                padding: EdgeInsets.symmetric(horizontal: 4),
                margin: EdgeInsets.only(left: 4),
              ),
            )
          ],
        ),
        TextComponent("Info: ",
            style: TextComponentStyle()
                .foreground(ColorRGB(229, 233, 240))
                .background(ColorRGB(20, 25, 35))
                .paddingOnly(left: 2, right: 2)
                .marginOnly(left: 4)),
        TextComponent(
          "Welcome to PixelPrompt!",
          style: TextComponentStyle().marginOnly(left: 8).italic(),
        ),
        TextComponent(
          "This TUI demo shows how rows and columns work.",
          style: TextComponentStyle().marginOnly(left: 8).bold(),
        ),
      ],
    )
  ]).run();
}
