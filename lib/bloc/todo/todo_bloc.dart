import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/todo/todo_state.dart';
import 'package:todoapp/model/todoModel.dart';
import 'package:todoapp/service/todoService.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;

  int skip = 0;
  final int limit = 10;

  TodoBloc(this.todoService) : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<UpdateTodo>(_onUpdateTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    try {
      emit(TodoLoading());
      final todoResponse = await todoService.fetchTodos(limit: limit, skip: 0);
      skip = todoResponse.todos.length; // Update skip with fetched todos count
      emit(TodoLoaded(todoResponse.todos, totalTodos: todoResponse.total)); // Pass total count
    } catch (e) {
      emit(TodoError('Failed to fetch todos'));
    }
  }

  Future<void> _onLoadMoreTodos(LoadMoreTodos event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;

      // Debug print
      print('Loading more todos... current length: ${currentState.todos.length}');

      if (currentState.todos.length >= currentState.totalTodos) {
        print('No more todos to load.');
        return;
      }

      try {
        emit(TodoLoaded(currentState.todos, isLoadingMore: true, totalTodos: currentState.totalTodos));
        final todoResponse = await todoService.fetchTodos(limit: event.limit, skip: event.skip);

        if (todoResponse.todos.isEmpty) {
          print('No new todos received from the service.');
          return;
        }

        // Debug print
        print('New todos received: ${todoResponse.todos.length}');

        skip += todoResponse.todos.length;
        final allTodos = List<Todo>.from(currentState.todos)..addAll(todoResponse.todos);

        emit(TodoLoaded(allTodos, totalTodos: currentState.totalTodos));
      } catch (e) {
        print('Error loading more todos: $e');
        emit(TodoError('Failed to load more todos'));
      }
    }
  }


  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final List<Todo> updatedTodos = (state as TodoLoaded).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();

      emit(TodoLoaded(updatedTodos, totalTodos: (state as TodoLoaded).totalTodos));
    }
  }
}
