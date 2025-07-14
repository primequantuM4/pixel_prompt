import 'package:pixel_prompt/components/button_component.dart';
import 'package:pixel_prompt/components/text_field_component.dart';
import 'package:pixel_prompt/core/component.dart';
import 'package:pixel_prompt/core/component_state.dart';
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
            style: TextComponentStyle()
                .bold()
                .background(ColorRGB(30, 60, 180))
                .paddingLeft(8)
                .paddingRight(8)
                .paddingTop(1)
                .paddingBottom(1),
          ),
          Row(
            children: [
              TextfieldComponent(
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
                TextComponent(
                  task,
                  style: TextComponentStyle()
                      .paddingTop(1)
                      .foreground(ColorRGB(20, 20, 20))
                      .background(ColorRGB(255, 255, 200))
                      .paddingBottom(1)
                      .paddingLeft(2)
                      .paddingRight(2),
                ),
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
