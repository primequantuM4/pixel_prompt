import 'dart:async';
import 'dart:math';

import 'package:pixel_prompt/common/response_input.dart';
import 'package:pixel_prompt/events/input_event.dart';
import 'package:pixel_prompt/handler/input_handler.dart';
import 'package:pixel_prompt/manager/input_registry.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

import 'snake_segment.dart';

enum GameState { title, playing, paused, gameOver }

class Snake extends StatefulComponent {
  @override
  ComponentState<Snake> createState() => _SnakeState();
}

class _SnakeState extends ComponentState<Snake> implements InputHandler {
  _SnakeState() {
    InputRegistry.register(this);
  }

  List<SnakeSegment> snake = [];
  final Set<Point<int>> walls = {};
  Point<int> food = Point(2, 7);

  bool foodBig = false;
  int score = 0;
  Timer? gameLoop;

  Direction direction = Direction.right;
  Direction? nextDirection;
  final int rows = 20;
  final int cols = 60;

  GameState state = GameState.title;

  @override
  void initState() {
    super.initState();
    initWalls();
  }

  void initWalls() {
    for (int r = 0; r < rows; r++) {
      walls.add(Point(r, 0));
      walls.add(Point(r, cols - 1));
    }
    for (int c = 0; c < cols; c++) {
      walls.add(Point(0, c));
      walls.add(Point(rows - 1, c));
    }
  }

  void startGame() {
    setState(() {
      snake = [
        SnakeSegment(5, 5, Direction.right),
        SnakeSegment(5, 4, Direction.right),
        SnakeSegment(5, 3, Direction.right),
      ];
      direction = Direction.right;
      nextDirection = null;
      score = 0;
      foodBig = false;
      _spawnFood();
      state = GameState.playing;
    });
    _startLoop();
  }

  void _startLoop() {
    gameLoop?.cancel();
    gameLoop = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (state == GameState.playing) {
        setState(() {
          moveSnake();
          foodBig = !foodBig;
        });
      }
    });
  }

  void moveSnake() {
    if (nextDirection != null && !_isOpposite(nextDirection!, direction)) {
      direction = nextDirection!;
      nextDirection = null;
    }

    final head = snake.first;
    Point<int> newHead;
    switch (direction) {
      case Direction.up:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.down:
        newHead = Point(head.x + 1, head.y);
        break;
      case Direction.left:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.right:
        newHead = Point(head.x, head.y + 1);
        break;
    }

    if (_isCollision(newHead)) {
      _gameOver();
      return;
    }

    if (newHead == food) {
      snake.insert(0, SnakeSegment(newHead.x, newHead.y, direction));
      score++;
      _spawnFood();
    } else {
      snake.insert(0, SnakeSegment(newHead.x, newHead.y, direction));
      snake.removeLast();
    }
  }

  bool _isCollision(Point<int> head) {
    if (walls.contains(head)) return true;
    if (snake.any((seg) => seg.pos == head)) return true;
    if (head.x < 0 || head.x >= rows || head.y < 0 || head.y >= cols) {
      return true;
    }
    return false;
  }

  void setDirection(Direction newDir) {
    if (_isOpposite(newDir, direction)) return;
    nextDirection = newDir;
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.up && b == Direction.down) ||
        (a == Direction.down && b == Direction.up) ||
        (a == Direction.left && b == Direction.right) ||
        (a == Direction.right && b == Direction.left);
  }

  void _gameOver() {
    gameLoop?.cancel();
    setState(() {
      state = GameState.gameOver;
    });
  }

  void pauseGame() {
    setState(() {
      if (state == GameState.playing) {
        state = GameState.paused;
      } else if (state == GameState.paused) {
        state = GameState.playing;
      }
    });
  }

  void _spawnFood() {
    final rand = Random();
    Point<int> pos;
    do {
      pos = Point(rand.nextInt(rows), rand.nextInt(cols));
    } while (snake.any((segment) => segment.pos == pos) || walls.contains(pos));
    food = pos;
  }

  @override
  List<Component> build() {
    switch (state) {
      case GameState.title:
        return [
          Column(
            children: [
              TextComponent(
                "SNAKE GAME",
                style: TextComponentStyle(
                  color: ColorRGB(0, 255, 100),
                  styles: {FontStyle.bold},
                  margin: EdgeInsets.symmetric(vertical: 1),
                ),
              ),
              ButtonComponent(
                label: "Start Game",
                onPressed: startGame,
                buttonColor: ColorRGB(0, 0, 0),
                textColor: ColorRGB(255, 255, 255),
                outerBorderColor: ColorRGB(0, 200, 200),
                borderStyle: BorderStyle.thin,
              ),
            ],
          ),
        ];

      case GameState.playing:
      case GameState.paused:
        return [
          Column(
            children: [
              TextComponent(
                "Score: $score ${state == GameState.paused ? '(PAUSED)' : ''}",
                style: TextComponentStyle(
                  color: state == GameState.paused
                      ? ColorRGB(255, 140, 0) // amber when paused
                      : ColorRGB(255, 215, 0), // gold when playing
                  styles: {FontStyle.bold},
                  margin: EdgeInsets.only(bottom: 1),
                ),
              ),
              Column(
                children: List.generate(rows, (r) {
                  return Row(
                    children: List.generate(cols, (c) {
                      final here = Point(r, c);
                      return _buildCell(here);
                    }),
                  );
                }),
              ),
            ],
          ),
        ];

      case GameState.gameOver:
        return [
          Column(
            children: [
              TextComponent(
                "GAME OVER",
                style: TextComponentStyle(
                  color: ColorRGB(255, 0, 0),
                  styles: {FontStyle.bold},
                  margin: EdgeInsets.symmetric(vertical: 1),
                ),
              ),
              TextComponent(
                "Final Score: $score",
                style: TextComponentStyle(
                  color: ColorRGB(255, 255, 0),
                  styles: {FontStyle.bold},
                ),
              ),
              Row(
                children: [
                  ButtonComponent(
                    label: "Try Again",
                    onPressed: startGame,
                    buttonColor: ColorRGB(0, 0, 0),
                    textColor: ColorRGB(255, 255, 255),
                    outerBorderColor: ColorRGB(0, 200, 0),
                    borderStyle: BorderStyle.thin,
                  ),
                  ButtonComponent(
                    label: "Back to Title",
                    onPressed: () => setState(() => state = GameState.title),
                    buttonColor: ColorRGB(20, 20, 20),
                    textColor: ColorRGB(200, 200, 200),
                    outerBorderColor: ColorRGB(100, 100, 100),
                    borderStyle: BorderStyle.thin,
                  ),
                ],
              ),
            ],
          ),
        ];
    }
  }

  Component _buildCell(Point<int> pos) {
    if (walls.contains(pos)) {
      return _styledCell('▓', ColorRGB(150, 150, 150));
    }
    final int index = snake.indexWhere((s) => s.pos == pos);
    if (index != -1) {
      // brighter head
      return _styledCell(
        index == 0 ? '█' : '█',
        index == 0
            ? ColorRGB(0, 255, 80) // snake head neon green
            : ColorRGB(0, 200, 0),
      ); // body darker green
    }
    if (food == pos) {
      return _styledCell(foodBig ? '●' : '•', ColorRGB(220, 0, 0));
    }
    return _styledCell(' ', null);
  }

  Component _styledCell(String char, ColorRGB? color) {
    return TextComponent(char, style: TextComponentStyle(color: color));
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is! KeyEvent) return ResponseInput.ignored();

    switch (event.code) {
      case KeyCode.arrowUp:
        setDirection(Direction.up);
        break;
      case KeyCode.arrowDown:
        setDirection(Direction.down);
        break;
      case KeyCode.arrowLeft:
        setDirection(Direction.left);
        break;
      case KeyCode.arrowRight:
        setDirection(Direction.right);
        break;
      case KeyCode.character: // pause toggle
        if (event.char == 'p') {
          pauseGame();
        }
        break;
      case KeyCode.escape: // back to title
        setState(() {
          state = GameState.title;
          gameLoop?.cancel();
        });
        break;
      default:
        return ResponseInput.ignored();
    }
    return ResponseInput(commands: ResponseCommands.none, handled: true);
  }
}

void main() {
  App(children: [Snake()]).run();
}
