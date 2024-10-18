import 'package:dio/dio.dart';
import 'package:todoapp/model/todoModel.dart';

class TodoService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://dummyjson.com';


  Future<TodoResponse> fetchTodos({int limit = 10, int skip = 10}) async {
    try {
      final response = await _dio.get('$baseUrl/todos', queryParameters: {
        'limit': limit,
        'skip': skip,
      });

      if (response.statusCode == 200) {
        return TodoResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load todos');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching todos: ${e.response?.statusCode ?? 'Unknown error'}');
    }
  }


  Future<Todo> updateTodoCompletion(int id, bool completed) async {
    try {
      final response = await _dio.put(
        '$baseUrl/todos/$id', // Ensure the correct URL is used
        data: {'completed': completed}, // Using Dio's data parameter for request body
        options: Options(
          headers: {'Content-Type': 'application/json'}, // Setting headers
        ),
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to update Todo: Unexpected status code');
      }
    } on DioException catch (e) {


      throw Exception('Error updating todo: ${e.response?.statusCode ?? 'Unknown error'}');
    } catch (e) {

      throw Exception('Error updating todo: $e');
    }
  }


  Future<Todo> deleteTodoById(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/todos/$id');
      if (response.statusCode == 200) {
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to delete Todo');
      }
    } on DioException catch (e) {
      throw Exception('Error deleting todo: ${e.response?.statusCode ?? 'Unknown error'}');
    }
  }

}
