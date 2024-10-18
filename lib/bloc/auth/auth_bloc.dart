import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:todoapp/model/authModel.dart';
import 'package:todoapp/model/errorHandling.dart';
import 'package:todoapp/service/authService.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LogIn>((event, emit) async {
      emit(Loading());
      ResultModel result = await AuthServiceImp().logIn(event.user);
      if (result is DataSuccess) {
        emit(SuccessToLogIn());
      } else {
        emit(FailedToLogIn());
      }
    });
  }
}
