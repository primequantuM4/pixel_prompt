# PixelPrompt 


[![pub package](https://img.shields.io/pub/v/pixel_prompt.svg)](https://pub.dev/packages/pixel_prompt)  
[![documentation](https://img.shields.io/badge/documentation-dartdoc-blue)](https://pub.dev/documentation/pixel_prompt/latest/)

PixelPrompt is a **Terminal UI (TUI) framework for Dart**, inspired by Flutter’s widget-driven architecture.  
It brings Dart’s familiar, declarative UI style to the command line, letting you build interactive, styled terminal applications with **layouts, stateful components, and keyboard/mouse events**.

> **Note:**  
> The API is **experimental and may break between versions**.  
> The `pub.dev` package may **lag behind the latest features** on `main`.

---

## Why PixelPrompt?

Dart has proven itself in the GUI world (via Flutter), but building TUIs often requires low-level terminal handling or foreign libraries.  
PixelPrompt bridges that gap by offering:

- A **component-based architecture** (similar to Flutter widgets).
- Built-in **layouts, stateful components, keyboard & mouse input**.
- **Customizable styling** (colors, padding, margin, borders).
- Extensible **API** via `BuilableComponent` and `StatefulComponent`.
- Cross-platform: supports Linux, macOS, and Windows terminals.

---

## Installation

### From `pub.dev` (may lag behind `main`):

```yaml
dependencies:
  pixel_prompt: ^0.1.0
```
or using `pub add`
```bash
dart pub add pixel_prompt
```
### From GitHub (latest, potentially unstable):
```yaml
dependencies:
  pixel_prompt:
    git:
      url: https://github.com/primequantuM4/pixel_prompt.git
      ref: main
```

Then run:
```bash
dart pub get
```

---
## Quick Start - Hello World

```dart
import 'package:pixel_prompt/pixel_prompt.dart';

void main() {
  App(
    children: [
      TextComponent(
        "Hello, PixelPrompt!",
        // style is optional
        style: TextComponentStyle(
          // foreground color for the text
          color: ColorRGB(200, 200, 200),
          // background color for the text
          bgColor: ColorRGB(30, 30, 30),
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        ),
      ),
    ],
  ).run();
}
```

Run it:
```bash
dart run hello_world.dart
```
---
### Examples 
- [Counter App](https://github.com/primequantuM4/pixel_prompt/blob/main/example/stateful_component_demo/bin/counter_demo.dart) — demonstrates stateful components and buttons.
- [Stopwatch App](https://github.com/primequantuM4/pixel_prompt/blob/main/example/buildable_component_demo/bin/stop_watch_demo.dart)  — demonstrates timers and dynamic updates.
---
### Roadmap
- Optimizations and verbosity for layout.
- Additional Components (menus, tables, textfield area).
- Visual Debugger
---
### Contributing
1. Fork the repo and clone it.
2. Install dependencies with:
```bash
dart pub get
```
3. Run tests:
```bash
dart test
```
4. Open a PR
---
### License 
**MIT**

