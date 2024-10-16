class Todo {
  final int id;
  final String todo;
  late final bool completed;
  final int userId;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  // Factory method to create a Todo instance from a JSON object
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'],
      userId: json['userId'],
    );
  }

  // Method to convert a Todo instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  // Method to create a copy of a Todo with optional new values
  Todo copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }
}



class TodoResponse {
  final List<Todo> todos;
  final int total;
  final int skip;
  final int limit;

  TodoResponse({
    required this.todos,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory TodoResponse.fromJson(Map<String, dynamic> json) {
    var list = json['todos'] as List;
    List<Todo> todoList = list.map((i) => Todo.fromJson(i)).toList();

    return TodoResponse(
      todos: todoList,
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}
