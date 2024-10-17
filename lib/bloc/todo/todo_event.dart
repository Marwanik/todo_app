import 'package:equatable/equatable.dart';
import 'package:todoapp/model/todoModel.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class FetchTodos extends TodoEvent {}

class LoadMoreTodos extends TodoEvent {
  final int limit;
  final int skip;

  const LoadMoreTodos({required this.limit, required this.skip});
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final int todoId;

  const DeleteTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
}
