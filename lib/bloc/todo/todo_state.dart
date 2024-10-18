import 'package:equatable/equatable.dart';
import 'package:todoapp/model/todoModel.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final bool isLoadingMore;
  final int totalTodos;

  const TodoLoaded({required this.todos, required this.isLoadingMore, required this.totalTodos});

  @override
  List<Object> get props => [todos, isLoadingMore, totalTodos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}

class TodoUpdated extends TodoState {
  final Todo todo;

  const TodoUpdated(this.todo);

  @override
  List<Object> get props => [todo];
}
class TodoDeleted extends TodoState {
  final Todo deletedTodo;

  const TodoDeleted(this.deletedTodo);

  @override
  List<Object> get props => [deletedTodo];
}
class TodoDeletedSuccess extends TodoState {
  final Todo deletedTodo;

  const TodoDeletedSuccess(this.deletedTodo);

  @override
  List<Object> get props => [deletedTodo];
}
