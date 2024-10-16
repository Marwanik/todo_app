import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/service/addTodoService.dart';
import 'package:todoapp/bloc/addtodo/addtodo_event.dart';
import 'package:todoapp/bloc/addtodo/addtodo_state.dart';

class AddTodoBloc extends Bloc<AddTodoEvent, AddTodoState> {
  final AddTodoService addTodoService;

  AddTodoBloc(this.addTodoService) : super(AddTodoInitial()) {
    on<AddNewTodo>(_onAddNewTodo);
  }

  Future<void> _onAddNewTodo(AddNewTodo event, Emitter<AddTodoState> emit) async {
    try {
      emit(AddTodoLoading());
      await addTodoService.addTodo(event.newTodo);
      emit(AddTodoSuccess());
    } catch (e) {
      emit(AddTodoFailure(e.toString()));
    }
  }
}
