import 'package:equatable/equatable.dart';
import 'package:todoapp/model/addTodoModel.dart';

abstract class AddTodoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddNewTodo extends AddTodoEvent {
  final AddTodoModel newTodo;

  AddNewTodo(this.newTodo);

  @override
  List<Object> get props => [newTodo];
}
