import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/todo/todo_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/todo/todo_state.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/model/todoModel.dart';
import 'package:todoapp/service/todoService.dart';
import 'package:todoapp/view/addTodo/addtodoScreen.dart';
import 'package:todoapp/view/login/login.dart';

// Add a capitalize extension for String
extension StringExtension on String {
  String capitalize() {
    if (this == null || isEmpty) {
      return '';
    }
    return this[0].toUpperCase() + substring(1);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final Color progressIndicatorColor = const Color(0xF055847A); // Custom color
  bool _isPaginating = false; // For tracking pagination loading
  List<Todo> savedTodos = []; // List to hold saved new todos from SharedPreferences

  @override
  void initState() {
    super.initState();
    _fetchSavedTodos(); // Fetch saved todos from SharedPreferences
    _scrollController.addListener(_onScroll);
  }

  // Fetch saved todos from SharedPreferences
  Future<void> _fetchSavedTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTodosString = prefs.getString('saved_todos') ?? '[]';
    final List<dynamic> savedTodosJson = jsonDecode(savedTodosString);

    setState(() {
      savedTodos = savedTodosJson.map((json) => Todo.fromJson(json)).toList();
    });
  }

  // Save todos (including the updated checkbox state) to SharedPreferences
  Future<void> _saveTodosToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> todosJson = savedTodos.map((todo) => todo.toJson()).toList();
    await prefs.setString('saved_todos', jsonEncode(todosJson));
  }

  // Add new todo to saved list and prevent duplication
  Future<void> _addNewTodoToSaved(Todo newTodo) async {
    setState(() {
      if (!savedTodos.any((todo) => todo.id == newTodo.id)) {
        savedTodos.insert(0, newTodo); // Prepend the new todo to the list
        _showLocalUpdateDialog(context, newTodo, 'added');
      }
    });
    _saveTodosToSharedPreferences(); // Save updated list
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Todo todo, bool isLocalTodo) async {
    bool isConfirmed = false;

    // Step 1: Show confirmation dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Todo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this todo?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                isConfirmed = true;
                Navigator.of(context).pop(); // Close the dialog first
              },
            ),
          ],
        );
      },
    );

    // Step 2: If confirmed, proceed to delete
    if (isConfirmed) {
      if (isLocalTodo) {
        _deleteTodoFromSaved(todo); // Delete from local saved todos
        _showLocalDeleteDialog(context, todo); // Show local delete confirmation
      } else {
        // For API delete, listen for the response
        context.read<TodoBloc>().add(DeleteTodo(todo.id));

        // Step 3: Listen for the API response and update the same dialog
        await showDialog<void>(
          context: context,
          barrierDismissible: false, // Prevent closing by tapping outside the dialog
          builder: (BuildContext context) {
            return BlocListener<TodoBloc, TodoState>(
              listener: (context, state) {
                if (state is TodoDeletedSuccess) {
                  Navigator.of(context).pop(); // Close the waiting dialog
                  _showApiDeleteDialog(context, state.deletedTodo); // Show the delete response in a new dialog
                } else if (state is TodoError) {
                  Navigator.of(context).pop(); // Close the waiting dialog
                  _showErrorDialog(context, state.message); // Show error if any
                }
              },
              child: AlertDialog(
                title: Text('Wait For Success Deleting'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Row(mainAxisAlignment:MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();  // Close the dialog
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  // Delete a todo from savedTodos (local deletion)
  void _deleteTodoFromSaved(Todo todo) {
    setState(() {
      savedTodos.removeWhere((t) => t.id == todo.id);
      _saveTodosToSharedPreferences(); // Update SharedPreferences
    });
    _showLocalDeleteDialog(context, todo);
  }

  // Show Dialog for local update response
  void _showLocalUpdateDialog(BuildContext context, Todo updatedTodo, String operation) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo ${operation.capitalize()} Locally'),
          content: Text(
            'Todo ID: ${updatedTodo.id}\n'
                'Title: ${updatedTodo.todo}\n'
                'Completed: ${updatedTodo.completed ? "Yes" : "No"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show detailed delete response in a dialog for local deletion
  void _showLocalDeleteDialog(BuildContext context, Todo deletedTodo) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Deleted Locally'),
          content: Text(
            'Todo ID: ${deletedTodo.id}\n'
                'Title: ${deletedTodo.todo}\n'
                'Completed: ${deletedTodo.completed ? "Yes" : "No"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show API update response in a dialog
  void _showApiUpdateDialog(BuildContext context, Todo updatedTodo) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Updated via API'),
          content: Text(
            'Todo ID: ${updatedTodo.id}\n'
                'Title: ${updatedTodo.todo}\n'
                'Completed: ${updatedTodo.completed ? "Yes" : "No"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show API delete response in a dialog
  void _showApiDeleteDialog(BuildContext context, Todo deletedTodo) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Deleted Successfully'),
          content: Text(
            'Delete successful:\n'
                'ID: ${deletedTodo.id}\n'
                'Title: ${deletedTodo.todo}\n'
                'Completed: ${deletedTodo.completed ? "Yes" : "No"}\n'
                'User ID: ${deletedTodo.userId}\n'
                'Deleted On: ${deletedTodo.deletedOn ?? "Unknown"}\n'
                'Is Deleted: ${deletedTodo.isDeleted != null ? "Yes" : "No"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }




  // Handle scroll and pagination
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isPaginating) {
      context.read<TodoBloc>().add(LoadMoreTodos(limit: 10, skip: context.read<TodoBloc>().skip));
      setState(() {
        _isPaginating = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPaginating = false;
          });
        }
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(TodoService())..add(FetchTodos()),
      child: BackgroundWidget(
        child: BlocListener<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoUpdated) {
              _showApiUpdateDialog(context, state.todo);
            } else if (state is TodoDeletedSuccess) {
              _showApiDeleteDialog(context, state.deletedTodo);  // This will show the dialog for the API delete success
            } else if (state is TodoError) {
              _showErrorDialog(context, state.message);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * .05),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Image.asset('assets/images/home/home.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todo Tasks',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app, color: Colors.red),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dairy Tasks',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final result = await Navigator.push<Todo>(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddTodoScreen()),
                                  );
                                  if (result != null) {
                                    _addNewTodoToSaved(result);
                                  }
                                },
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: BlocBuilder<TodoBloc, TodoState>(
                              builder: (context, state) {
                                if (state is TodoLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: progressIndicatorColor,
                                    ),
                                  );
                                } else if (state is TodoLoaded) {
                                  final todos = [
                                    ...savedTodos,
                                    ...state.todos
                                  ];

                                  return NotificationListener<ScrollNotification>(
                                      onNotification: (ScrollNotification scrollInfo) {
                                        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                            !(state.isLoadingMore) &&
                                            state.todos.length < state.totalTodos) {
                                          context.read<TodoBloc>().add(LoadMoreTodos(
                                            limit: 10,
                                            skip: context.read<TodoBloc>().skip,
                                          ));
                                          return true;
                                        }
                                        return false;
                                      },
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: todos.length + (_isPaginating ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (index == todos.length) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: CircularProgressIndicator(
                                                  color: progressIndicatorColor,
                                                ),
                                              ),
                                            );
                                          }

                                          final todo = todos[index];
                                          final isLocalTodo = savedTodos.any((savedTodo) => savedTodo.id == todo.id);

                                          return ListTile(
                                            title: Text(todo.todo),
                                            leading: Checkbox(
                                              activeColor: progressIndicatorColor,
                                              value: todo.completed,
                                              onChanged: (bool? value) {
                                                if (isLocalTodo) {
                                                  final updatedTodo = todo.copyWith(completed: value ?? false);
                                                  setState(() {
                                                    final indexInLocal = savedTodos.indexWhere((t) => t.id == todo.id);
                                                    if (indexInLocal != -1) {
                                                      savedTodos[indexInLocal] = updatedTodo;
                                                      _saveTodosToSharedPreferences();
                                                      _showLocalUpdateDialog(context, updatedTodo, 'updated');
                                                    }
                                                  });
                                                } else {
                                                  final updatedTodo = todo.copyWith(completed: value ?? false);
                                                  context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
                                                }
                                              },
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: (todo.isDeleted ?? false) ? Colors.black : Colors.red,
                                              ),
                                              onPressed: () {
                                                _showDeleteConfirmation(context, todo, isLocalTodo);
                                              },
                                            ),
                                          );
                                        },
                                      )
                                  );
                                } else if (state is TodoError) {
                                  return Center(child: Text(state.message));
                                }
                                return Center(child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
