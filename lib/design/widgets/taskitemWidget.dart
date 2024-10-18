import 'package:flutter/material.dart';
import 'package:todoapp/design/color/color.dart';

class TaskItem extends StatelessWidget {
  final String task;
  final bool completed;
  final ValueChanged<bool?> onChanged;

  const TaskItem({super.key,
    required this.task,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: completed,
        activeColor: MainColor,
        onChanged: onChanged,
      ),
      title: Text(task),
    );
  }
}
