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
  final int totalTodos; // Total number of todos available from the API

  const TodoLoaded(this.todos, {this.isLoadingMore = false, this.totalTodos = 0});

  @override
  List<Object> get props => [todos, isLoadingMore, totalTodos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}
