import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/todo/todo_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/todo/todo_state.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/taskitemWidget.dart';
import 'package:todoapp/model/todoModel.dart';
import 'package:todoapp/service/todoService.dart';
import 'package:todoapp/view/addTodo/addtodoScreen.dart';
import 'package:todoapp/view/login/login.dart';

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
  Future<void> _addNewTodoToSharedPreferences(Todo newTodo) async {
    setState(() {
      // Check if the todo already exists before adding it
      if (!savedTodos.any((todo) => todo.id == newTodo.id)) {
        savedTodos.insert(0, newTodo); // Prepend the new todo to the list
      }
    });
    _saveTodosToSharedPreferences(); // Save updated list
  }

  // Scroll listener to trigger pagination
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isPaginating) {
      // When at the bottom of the list, trigger pagination
      context.read<TodoBloc>().add(LoadMoreTodos(limit: 10, skip: context.read<TodoBloc>().skip));
      setState(() {
        _isPaginating = true; // Start paginating
      });

      // Automatically stop the loading spinner after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPaginating = false;
          });
        }
      });
    }
  }

  // Logout functionality, clear cache and navigate to login screen
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate back to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(TodoService())..add(FetchTodos()),
      child: BackgroundWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .05),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/home/home.png',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),  // Align logout icon
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Align the title and logout icon
                children: [
                  Text(
                    'Todo Tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  IconButton(
                    icon: Icon(Icons.exit_to_app, color: Colors.red),
                    onPressed: _logout,  // Call the logout function
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.push<Todo>(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddTodoScreen()), // Navigate to AddTodoScreen
                                );
                                if (result != null) {
                                  // Now you're working with the Todo object
                                  _addNewTodoToSharedPreferences(result); // Save the new todo to SharedPreferences
                                }
                              },
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Display saved todos first, followed by fetched todos
                        Expanded(
                          child: BlocBuilder<TodoBloc, TodoState>(
                            builder: (context, state) {
                              if (state is TodoLoading) {
                                // Show loading indicator while fetching the first set of todos
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: progressIndicatorColor, // Custom color
                                  ),
                                );
                              } else if (state is TodoLoaded) {
                                // Combine saved todos (newly added) at the top, fetched todos below
                                final todos = [...savedTodos, ...state.todos]; // Local saved todos first, fetched todos below

                                return NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                        !(state.isLoadingMore) &&
                                        state.todos.length < state.totalTodos) {
                                      // When reaching the bottom of the list, load more todos
                                      context.read<TodoBloc>().add(
                                        LoadMoreTodos(
                                          limit: 10,
                                          skip: context.read<TodoBloc>().skip,
                                        ),
                                      );
                                      return true;
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: todos.length + (_isPaginating ? 1 : 0), // Add extra item if paginating
                                    itemBuilder: (context, index) {
                                      if (index == todos.length) {
                                        // Show pagination loading indicator at the bottom
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: progressIndicatorColor, // Custom color
                                            ),
                                          ),
                                        );
                                      }
                                      final todo = todos[index];
                                      return TaskItem(
                                        task: todo.todo,
                                        completed: todo.completed,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            // Instead of directly setting the 'completed' field, use copyWith to create a new instance with updated completed value
                                            final updatedTodo = todo.copyWith(completed: value ?? false);

                                            // Update the local savedTodos and save it to SharedPreferences if it's a local todo
                                            if (index < savedTodos.length) {
                                              savedTodos[index] = updatedTodo;
                                              _saveTodosToSharedPreferences();
                                            } else {
                                              // Dispatch UpdateTodo event to the Bloc if it's a fetched todo
                                              context.read<TodoBloc>().add(
                                                UpdateTodo(updatedTodo),
                                              );
                                            }
                                          });
                                        },
                                      );


                                    },
                                  ),
                                );
                              } else if (state is TodoError) {
                                return Center(
                                  child: Text(state.message),
                                );
                              }
                              return Center(child: Text('No Tasks Found'));
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
    );
  }
}
