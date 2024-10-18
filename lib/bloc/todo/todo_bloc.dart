import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/service/todoService.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;
  int skip = 0;

  TodoBloc(this.todoService) : super(TodoLoading()) {
    on<FetchTodos>(_onFetchTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    try {
      final todosResponse = await todoService.fetchTodos(limit: 10, skip: skip);
      skip += 10;
      emit(TodoLoaded(
        todos: todosResponse.todos,
        isLoadingMore: false,
        totalTodos: todosResponse.total,
      ));
    } catch (error) {
      emit(TodoError(error.toString()));
    }
  }

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
        skip += event.limit;
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

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = await todoService.updateTodoCompletion(event.todo.id, event.todo.completed);
      emit(TodoUpdated(updatedTodo));

      skip = 0;
      add(FetchTodos());
    } catch (error) {
      emit(TodoError(error.toString()));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      final deletedTodo = await todoService.deleteTodoById(event.todoId);
      emit(TodoDeletedSuccess(deletedTodo));

      skip = 0;
      add(FetchTodos());
    } catch (error) {
      emit(TodoError(error.toString()));
    }
  }
}
