import 'dart:convert';
import 'package:flutter/material.dart' show TimeOfDay;

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

class Task {
  final String id;
  final String title;
  final DateTime date; // time-of-day component is ignored; use `time` instead
  final TimeOfDay? time;
  final bool isDone;
  final TaskPriority priority;
  final bool reminderEnabled;

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.reminderEnabled = false,
  });

  /// Combined date + time, used for scheduling reminders. Null if no time set.
  DateTime? get dateTime =>
      time == null ? null : DateTime(date.year, date.month, date.day, time!.hour, time!.minute);

  Task copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    bool clearTime = false,
    bool? isDone,
    TaskPriority? priority,
    bool? reminderEnabled,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: clearTime ? null : (time ?? this.time),
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'timeHour': time?.hour,
        'timeMinute': time?.minute,
        'isDone': isDone,
        'priority': priority.name,
        'reminderEnabled': reminderEnabled,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        time: json['timeHour'] != null
            ? TimeOfDay(hour: json['timeHour'] as int, minute: json['timeMinute'] as int)
            : null,
        isDone: json['isDone'] as bool? ?? false,
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      );

  static String encodeList(List<Task> tasks) => jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String s) =>
      (jsonDecode(s) as List<dynamic>).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
}
