part of 'app_manger_bloc.dart';

@immutable
abstract class AppManagerEvent extends Equatable {
  const AppManagerEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthorized extends AppManagerEvent {}

class HeLoggedIn extends AppManagerEvent {}

class HeLoggedOut extends AppManagerEvent {}

class HeFailedToLoggedIn extends AppManagerEvent {}

class RestoreToLogIn extends AppManagerEvent {}

class LogOut extends AppManagerEvent {}

class ExcuteLastRequest extends AppManagerEvent {}