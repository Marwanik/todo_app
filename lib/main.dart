import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_event.dart';
import 'package:todoapp/bloc/splash/splash_bloc.dart';
import 'package:todoapp/bloc/todo/todo_bloc.dart';
import 'package:todoapp/bloc/todo/todo_event.dart';
import 'package:todoapp/bloc/addtodo/addtodo_bloc.dart';
import 'package:todoapp/core/bloc/app_manger_bloc.dart';
import 'package:todoapp/core/config/observerBloc.dart';
import 'package:todoapp/core/config/serviceLocator.dart';
import 'package:todoapp/service/todoService.dart';
import 'package:todoapp/service/addTodoService.dart';
import 'package:todoapp/view/spalsh/splashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SplashBloc(),
        ),
        BlocProvider(
          create: (context) => AppManagerBloc()..add(CheckAuthorized()),
        ),
        BlocProvider(
          create: (context) => TodoBloc(core.get<TodoService>())..add(FetchTodos()),
        ),
        BlocProvider(
          create: (context) => AddTodoBloc(core.get<AddTodoService>()),
        ),
        BlocProvider(
          create: (context) => OnboardingBloc()..add(CheckOnboardingStatus()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
