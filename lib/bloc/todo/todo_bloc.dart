import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/todo/todo_state.dart';
import 'package:todoapp/model/todoModel.dart';
import 'package:todoapp/service/todoService.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;

  int skip = 0; // Keep track of the offset for pagination
  final int limit = 10; // Number of todos to load per request

  TodoBloc(this.todoService) : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<UpdateTodo>(_onUpdateTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    try {
      emit(TodoLoading());
      final todoResponse = await todoService.fetchTodos(limit: limit, skip: 0);
      skip = todoResponse.todos.length; // Update the skip count
      emit(TodoLoaded(todoResponse.todos, totalTodos: todoResponse.total)); // Pass total count
    } catch (e) {
      emit(TodoError('Failed to fetch todos'));
    }
  }

  Future<void> _onLoadMoreTodos(LoadMoreTodos event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;

      // Stop loading if all todos are loaded
      if (currentState.todos.length >= currentState.totalTodos) {
        return;
      }

      try {
        emit(TodoLoaded(currentState.todos, isLoadingMore: true, totalTodos: currentState.totalTodos)); // Set loading more to true
        final todoResponse = await todoService.fetchTodos(limit: event.limit, skip: event.skip);

        if (todoResponse.todos.isEmpty) {
          return; // No more todos to load
        }

        skip += todoResponse.todos.length; // Increment the skip value
        final allTodos = List<Todo>.from(currentState.todos)..addAll(todoResponse.todos);

        emit(TodoLoaded(allTodos, totalTodos: currentState.totalTodos)); // Emit the updated list
      } catch (e) {
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
