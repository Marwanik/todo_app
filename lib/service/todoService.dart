import 'package:dio/dio.dart';
import 'package:todoapp/model/todoModel.dart';

class TodoService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://dummyjson.com';

  Future<TodoResponse> fetchTodos({int limit = 10, int skip = 0}) async {
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
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }
}
