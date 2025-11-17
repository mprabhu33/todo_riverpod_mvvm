import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_,_) => Divider(height: 1),
      itemBuilder: (context, index) {
        final t = tasks[index];
        return TaskItem(task: t);
      },
    );
  }
}
