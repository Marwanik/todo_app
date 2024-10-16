import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/todo/todo_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/todo/todo_state.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/taskitemWidget.dart';
import 'package:todoapp/service/todoService.dart';
import 'package:todoapp/view/addTodo/addtodoScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final Color progressIndicatorColor = const Color(0xF055847A); // Custom color
  bool _isPaginating = false; // For tracking pagination loading

  @override
  void initState() {
    super.initState();
    // Listen to scroll changes
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(TodoService())..add(FetchTodos()),
      child: BackgroundWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .1),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/home/home.png',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Row(
                children: [
                  Text(
                    'Todo Tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddTodoScreen()),
                                );
                              },
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // BlocBuilder to listen for changes in TodoBloc state
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
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    if (scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent &&
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
                                    itemCount: state.todos.length + (_isPaginating ? 1 : 0), // Add extra item if paginating
                                    itemBuilder: (context, index) {
                                      if (index == state.todos.length) {
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
                                      final todo = state.todos[index];
                                      return TaskItem(
                                        task: todo.todo,
                                        completed: todo.completed,
                                        onChanged: (bool? value) {
                                          // Dispatch UpdateTodo event to the Bloc
                                          context.read<TodoBloc>().add(
                                            UpdateTodo(
                                              todo.copyWith(
                                                completed: value ?? false,
                                              ),
                                            ),
                                          );
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
