import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String task;
  final bool completed;
  final ValueChanged<bool?> onChanged;  // Add a callback for state change

  const TaskItem({
    required this.task,
    required this.completed,
    required this.onChanged,  // Pass the callback in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: completed,
        activeColor: Colors.green,  // Set checkbox color to green when checked
        onChanged: onChanged,       // Handle checkbox state change
      ),
      title: Text(task),
    );
  }
}
