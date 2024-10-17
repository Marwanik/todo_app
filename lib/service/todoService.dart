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

      // Print the full response for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      // Check if the response was successful
      if (response.statusCode == 200) {
        return Todo.fromJson(response.data); // Directly decode from Dio response
      } else {
        print('Unexpected status code: ${response.statusCode}');
        print('Response Data: ${response.data}');
        throw Exception('Failed to update Todo: Unexpected status code');
      }
    } on DioException catch (e) {
      // Print detailed error information
      print('DioException caught: ${e.response?.statusCode}');
      print('Error response data: ${e.response?.data}');
      print('Error message: ${e.message}');

      throw Exception('Error updating todo: ${e.response?.statusCode ?? 'Unknown error'}');
    } catch (e) {
      // Print any other errors
      print('General exception caught: $e');
      throw Exception('Error updating todo: $e');
    }
  }


  Future<Todo> deleteTodoById(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/todos/$id');
      if (response.statusCode == 200) {
        print('Delete successful: ${response.data}');
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to delete Todo');
      }
    } on DioException catch (e) {
      print('Error deleting todo: ${e.response?.statusCode ?? 'Unknown error'}');
      throw Exception('Error deleting todo: ${e.response?.statusCode ?? 'Unknown error'}');
    }
  }

}
