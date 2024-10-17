import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/model/todoModel.dart';
import 'package:todoapp/service/todoService.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;
  int skip = 0; // Add skip property for pagination

  TodoBloc(this.todoService) : super(TodoLoading()) {
    on<FetchTodos>(_onFetchTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  // Fetch todos from API
  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    try {
      final todosResponse = await todoService.fetchTodos(limit: 10, skip: skip);
      skip += 10; // Increment skip for pagination
      emit(TodoLoaded(
        todos: todosResponse.todos,
        isLoadingMore: false,
        totalTodos: todosResponse.total,
      ));
    } catch (error) {
      emit(TodoError(error.toString()));
    }
  }

  // Load more todos for pagination
  Future<void> _onLoadMoreTodos(LoadMoreTodos event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoaded && !currentState.isLoadingMore) {
      try {
        emit(TodoLoaded(
          todos: currentState.todos,
          isLoadingMore: true,
          totalTodos: currentState.totalTodos,
        ));
        final todosResponse = await todoService.fetchTodos(limit: event.limit, skip: skip);
        skip += event.limit; // Increment skip for pagination
        emit(TodoLoaded(
          todos: [...currentState.todos, ...todosResponse.todos],
          isLoadingMore: false,
          totalTodos: todosResponse.total,
        ));
      } catch (error) {
        emit(TodoError(error.toString()));
      }
    }
  }

  // Handle update of a todo item
  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = await todoService.updateTodoCompletion(event.todo.id, event.todo.completed);
      emit(TodoUpdated(updatedTodo)); // Emit TodoUpdated state to show success

      // After emitting update success, refetch todos to reflect the latest state
      skip = 0; // Reset pagination
      add(FetchTodos()); // Fetch updated todos
    } catch (error) {
      print("Error updating Todo: $error");
      emit(TodoError(error.toString()));
    }
  }

  // Handle deletion of a todo item
  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      final deletedTodo = await todoService.deleteTodoById(event.todoId);
      emit(TodoDeletedSuccess(deletedTodo)); // Emit success for deletion

      // After deletion, refetch todos to reflect the updated state
      skip = 0; // Reset pagination
      add(FetchTodos()); // Fetch updated todos
    } catch (error) {
      print("Error deleting Todo: $error");
      emit(TodoError(error.toString()));
    }
  }
}
