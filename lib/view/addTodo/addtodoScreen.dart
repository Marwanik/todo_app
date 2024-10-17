import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/addtodo/addtodo_bloc.dart';
import 'package:todoapp/bloc/addtodo/addtodo_event.dart';
import 'package:todoapp/bloc/addtodo/addtodo_state.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/design/widgets/customTextField.dart';
import 'package:todoapp/model/addTodoModel.dart';
import 'package:todoapp/model/todoModel.dart'; // Import Todo model

class AddTodoScreen extends StatelessWidget {
  final TextEditingController _todoController = TextEditingController();
  final Color progressIndicatorColor = const Color(0xF055847A); // Custom color

  // Save the new todo to SharedPreferences
  Future<void> _saveTaskToSharedPreferences(Todo task) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTodosString = prefs.getString('saved_todos') ?? '[]';
    final List<dynamic> savedTodosJson = jsonDecode(savedTodosString);

    savedTodosJson.insert(0, task.toJson()); // Add new todo at the start of the list
    await prefs.setString('saved_todos', jsonEncode(savedTodosJson)); // Save the updated list
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
              SizedBox(height: 30),
              Text(
                'Add what you want to do later on...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xF055847A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomTextField(
                  controller: _todoController,
                  hintText: 'Enter your task',
                ),
              ),
              SizedBox(height: 40),
              BlocConsumer<AddTodoBloc, AddTodoState>(
                listener: (context, state) {
                  if (state is AddTodoSuccess) {
                    final todoText = _todoController.text.trim();
                    if (todoText.isNotEmpty) {
                      // Convert AddTodoModel to Todo before returning
                      final newTodo = Todo(
                        id: DateTime.now().millisecondsSinceEpoch,
                        todo: todoText,
                        completed: false,
                        userId: 5, deletedOn: '',
                      );

                      // Save the new task to SharedPreferences
                      _saveTaskToSharedPreferences(newTodo);

                      // Pop with Todo object (not AddTodoModel)
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
                  color: progressIndicatorColor,
                  );
                  }
                  return CustomButton(
                    text: 'Add to List',
                    onPressed: () {
                      final todoText = _todoController.text.trim();
                      if (todoText.isNotEmpty) {
                        final newTodo = AddTodoModel(
                          todo: todoText,
                          completed: false,
                          userId: 5,
                        );

                        // Dispatch the AddNewTodo event to the Bloc
                        context.read<AddTodoBloc>().add(
                          AddNewTodo(newTodo),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a task')),
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
