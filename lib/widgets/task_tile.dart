import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onTap,
    required this.onDelete,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: task.isDone, onChanged: (_) => onToggleDone()),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: task.time != null ? Text(task.time!.format(context)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.reminderEnabled)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.notifications_active, size: 16, color: Colors.grey),
              ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: _priorityColor(), shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
