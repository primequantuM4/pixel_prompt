import 'package:pixel_prompt/components/button_component.dart';
import 'package:pixel_prompt/components/text_field_component.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_state.dart';
import 'package:pixel_prompt/core/edge_insets.dart';
import 'package:pixel_prompt/core/stateful_component.dart';
import 'package:pixel_prompt/pixel_prompt.dart';

class TodoListApp extends StatefulComponent {
  @override
  ComponentState<TodoListApp> createState() => _TodoListState();
}

class _TodoListState extends ComponentState<TodoListApp> {
  List<String> todos = [];
  String newTask = "";

  @override
  List<Component> build() {
    return [
      Column(
        children: [
          TextComponent(
            "Todo List",
            style: TextComponentStyle(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              bgColor: ColorRGB(30, 60, 180),
            ).bold(),
          ),
          Row(
            children: [
              TextFieldComponent(
                placeHolder: 'Add Task',
                hoverStyle: TextComponentStyle().background(
                  ColorRGB(20, 20, 20),
                ),
                onChanged: (val) {
                  newTask = val;
                },
              ),
              ButtonComponent(
                label: "Add",
                buttonColor: ColorRGB(0, 180, 0),
                onPressed: () {
                  if (newTask.trim().isEmpty) return;
                  setState(() {
                    todos.add(newTask.trim());
                    newTask = "";
                  });
                },
              ),
            ],
          ),
          ...todos.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return Row(
              children: [
                TextComponent(task,
                    style: TextComponentStyle(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    )
                        .foreground(ColorRGB(20, 20, 20))
                        .background(ColorRGB(255, 255, 200))),
                TextComponent(' ', style: TextComponentStyle()),
                ButtonComponent(
                  label: "Remove",
                  buttonColor: ColorRGB(200, 50, 50),
                  onPressed: () {
                    setState(() {
                      todos.removeAt(index);
                    });
                  },
                ),
              ],
            );
          }),
        ],
      ),
    ];
  }
}

void main() {
  App(children: [TodoListApp()]).run();
}
