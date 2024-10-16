import 'package:equatable/equatable.dart';
import 'package:todoapp/model/todoModel.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTodos extends TodoEvent {}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}
class LoadMoreTodos extends TodoEvent {
  final int limit;
  final int skip;

  LoadMoreTodos({required this.limit, required this.skip});

  @override
  List<Object> get props => [limit, skip];
}
