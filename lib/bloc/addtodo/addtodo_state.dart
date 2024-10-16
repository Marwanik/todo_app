import 'package:equatable/equatable.dart';

abstract class AddTodoState extends Equatable {
  const AddTodoState();

  @override
  List<Object> get props => [];
}

class AddTodoInitial extends AddTodoState {}

class AddTodoLoading extends AddTodoState {}

class AddTodoSuccess extends AddTodoState {}

class AddTodoFailure extends AddTodoState {
  final String error;

  const AddTodoFailure(this.error);

  @override
  List<Object> get props => [error];
}
