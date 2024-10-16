part of 'app_manger_bloc.dart';

@immutable
abstract class AppManagerState extends Equatable {
  const AppManagerState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppManagerState {}

class NavigateToLoginPage extends AppManagerState {}

class NavigateToOffline extends AppManagerState {}

class NavigateToHomePage extends AppManagerState {}