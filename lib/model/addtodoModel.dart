class AddTodoModel {
  final String todo;
  final bool completed;
  final int userId;

  AddTodoModel({
    required this.todo,
    required this.completed,
    required this.userId,
  });

  // Add fromJson method to convert from JSON
  factory AddTodoModel.fromJson(Map<String, dynamic> json) {
    return AddTodoModel(
      todo: json['todo'],
      completed: json['completed'],
      userId: json['userId'],
    );
  }

  // Add toJson method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  // Add copyWith method to create modified copies
  AddTodoModel copyWith({
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return AddTodoModel(
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }
}
