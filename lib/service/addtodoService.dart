import 'package:dio/dio.dart';
import 'package:todoapp/model/addTodoModel.dart';

class AddTodoService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://dummyjson.com/todos/add';

  Future<AddTodoModel> addTodo(AddTodoModel newTodo) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: newTodo.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        return AddTodoModel(
          todo: response.data['todo'],
          completed: response.data['completed'],
          userId: response.data['userId'],
        );
      } else {

        throw Exception('Failed to add task');
      }
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }
}
