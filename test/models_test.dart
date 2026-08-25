import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/models/time_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task persistence', () {
    test('round-trips all task fields', () {
      final task = Task(
        id: 'task-1',
        title: 'Send proposal',
        date: DateTime(2026, 8, 25),
        time: const TimeOfDay(hour: 9, minute: 30),
        isDone: true,
        priority: TaskPriority.high,
        reminderEnabled: true,
      );

      final restored = Task.decodeList(Task.encodeList([task])).single;

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.date, task.date);
      expect(restored.time, task.time);
      expect(restored.isDone, isTrue);
      expect(restored.priority, TaskPriority.high);
      expect(restored.reminderEnabled, isTrue);
    });

    test('clears a task time explicitly', () {
      final task = Task(
        id: 'task-2',
        title: 'Unscheduled task',
        date: DateTime(2026, 8, 25),
        time: const TimeOfDay(hour: 10, minute: 0),
      );

      expect(task.copyWith(clearTime: true).time, isNull);
    });
  });

  group('TimeBlock persistence', () {
    test('round-trips a scheduled block', () {
      final block = TimeBlock(
        id: 'block-1',
        title: 'Deep work',
        date: DateTime(2026, 8, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        category: BlockCategory.work,
        reminderEnabled: true,
        note: 'Phone off',
      );

      final restored = TimeBlock.decodeList(TimeBlock.encodeList([block])).single;

      expect(restored.id, block.id);
      expect(restored.startTime, block.startTime);
      expect(restored.endTime, block.endTime);
      expect(restored.category, BlockCategory.work);
      expect(restored.reminderEnabled, isTrue);
      expect(restored.note, 'Phone off');
      expect(restored.startDateTime, DateTime(2026, 8, 25, 9));
    });
  });
}
