import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onToggleDone;
  final ValueChanged<Task> onTap;
  final ValueChanged<Task> onDelete;
  final VoidCallback onAdd;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onToggleDone,
    required this.onTap,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            const Text('No tasks for this day'),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Task')),
          ],
        ),
      );
    }

    final pending = tasks.where((t) => !t.isDone).toList();
    final done = tasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 90, top: 8),
      children: [
        ...pending.map(
          (t) => TaskTile(
            task: t,
            onToggleDone: () => onToggleDone(t),
            onTap: () => onTap(t),
            onDelete: () => onDelete(t),
          ),
        ),
        if (done.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Completed (${done.length})',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
          ...done.map(
            (t) => TaskTile(
              task: t,
              onToggleDone: () => onToggleDone(t),
              onTap: () => onTap(t),
              onDelete: () => onDelete(t),
            ),
          ),
        ],
      ],
    );
  }
}
