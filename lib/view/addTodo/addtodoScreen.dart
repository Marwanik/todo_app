import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/addtodo/addtodo_bloc.dart';
import 'package:todoapp/bloc/addtodo/addtodo_event.dart';
import 'package:todoapp/bloc/addtodo/addtodo_state.dart';
import 'package:todoapp/design/text/string.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/design/widgets/customTextField.dart';
import 'package:todoapp/model/addTodoModel.dart';
import 'package:todoapp/model/todoModel.dart';

import '../../design/color/color.dart';

class AddTodoScreen extends StatelessWidget {
  final TextEditingController _todoController = TextEditingController();

  AddTodoScreen({super.key});


  Future<void> _saveTaskToSharedPreferences(Todo task) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTodosString = prefs.getString('saved_todos') ?? '[]';
    final List<dynamic> savedTodosJson = jsonDecode(savedTodosString);

    savedTodosJson.insert(0, task.toJson());
    await prefs.setString('saved_todos', jsonEncode(savedTodosJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  'assets/images/addtodo/addtodo.png',
                ),
              ),
              const SizedBox(height: 30),
              Text(
                Addwhatyouwant,
                style: TextStyle(
                  fontSize: 16,
                  color: MainColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomTextField(
                  controller: _todoController,
                  hintText: Enteryourtask,
                ),
              ),
              const SizedBox(height: 40),
              BlocConsumer<AddTodoBloc, AddTodoState>(
                listener: (context, state) {
                  if (state is AddTodoSuccess) {
                    final todoText = _todoController.text.trim();
                    if (todoText.isNotEmpty) {

                      final newTodo = Todo(
                        id: DateTime.now().millisecondsSinceEpoch,
                        todo: todoText,
                        completed: false,
                        userId: 5, deletedOn: '',
                      );

                      _saveTaskToSharedPreferences(newTodo);

                      Navigator.pop(context, newTodo);
                    }
                  } else if (state is AddTodoFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AddTodoLoading) {
                    return CircularProgressIndicator(
                  color: MainColor,
                  );
                  }
                  return CustomButton(
                    text: AddtoList,
                    onPressed: () {
                      final todoText = _todoController.text.trim();
                      if (todoText.isNotEmpty) {
                        final newTodo = AddTodoModel(
                          todo: todoText,
                          completed: false,
                          userId: 5,
                        );

                        context.read<AddTodoBloc>().add(
                          AddNewTodo(newTodo),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(Pleaseenteratask)),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
