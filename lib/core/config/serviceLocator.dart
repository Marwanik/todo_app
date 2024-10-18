import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/service/addTodoService.dart';
import 'package:todoapp/service/todoService.dart';

GetIt core = GetIt.instance;

setup() async {
  core.registerSingleton(await SharedPreferences.getInstance());
  core.registerSingleton<TodoService>(TodoService());
  core.registerSingleton<AddTodoService>(AddTodoService());
}