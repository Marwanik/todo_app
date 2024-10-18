class Todo {
  final int id;
  final String todo;
  final bool completed;
  final int userId;
  final bool? isDeleted;
  final String? deletedOn;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
    this.isDeleted,
    required this.deletedOn,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'],
      userId: json['userId'],
      isDeleted: json['isDeleted'],
      deletedOn: json['deletedOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
      'isDeleted': isDeleted,
      'deletedOn': deletedOn,
    };
  }



  Todo copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
    bool? isDeleted,
    String? deletedOn,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedOn: deletedOn ?? this.deletedOn,
    );
  }


  @override
  String toString() {
    return 'Todo { id: $id, todo: $todo, completed: $completed, userId: $userId, isDeleted: $isDeleted, deletedOn: $deletedOn }';
  }
}



class TodoResponse {
  final List<Todo> todos;
  final int total;
  final int?skip;
  final int? limit;

  TodoResponse({
    required this.todos,
    required this.total,
     this.skip,
     this.limit,
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
