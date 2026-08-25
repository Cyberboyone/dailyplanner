import 'dart:convert';
import 'package:flutter/material.dart';

enum BlockCategory { work, personal, health, study, family, sleep, other }

extension BlockCategoryX on BlockCategory {
  String get label {
    switch (this) {
      case BlockCategory.work:
        return 'Work';
      case BlockCategory.personal:
        return 'Personal';
      case BlockCategory.health:
        return 'Health';
      case BlockCategory.study:
        return 'Study';
      case BlockCategory.family:
        return 'Family';
      case BlockCategory.sleep:
        return 'Sleep';
      case BlockCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case BlockCategory.work:
        return const Color(0xFF42A5F5);
      case BlockCategory.personal:
        return const Color(0xFFAB47BC);
      case BlockCategory.health:
        return const Color(0xFFEF5350);
      case BlockCategory.study:
        return const Color(0xFF26C6DA);
      case BlockCategory.family:
        return const Color(0xFF66BB6A);
      case BlockCategory.sleep:
        return const Color(0xFF7E57C2);
      case BlockCategory.other:
        return const Color(0xFF8D6E63);
    }
  }
}

class TimeBlock {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final BlockCategory category;
  final bool reminderEnabled;
  final String? note;

  TimeBlock({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.category = BlockCategory.other,
    this.reminderEnabled = false,
    this.note,
  });

  DateTime get startDateTime =>
      DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  DateTime get endDateTime =>
      DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

  double get startFraction => startTime.hour + startTime.minute / 60.0;
  double get endFraction => endTime.hour + endTime.minute / 60.0;

  TimeBlock copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    BlockCategory? category,
    bool? reminderEnabled,
    String? note,
  }) {
    return TimeBlock(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'category': category.name,
        'reminderEnabled': reminderEnabled,
        'note': note,
      };

  factory TimeBlock.fromJson(Map<String, dynamic> json) => TimeBlock(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        startTime: TimeOfDay(hour: json['startHour'] as int, minute: json['startMinute'] as int),
        endTime: TimeOfDay(hour: json['endHour'] as int, minute: json['endMinute'] as int),
        category: BlockCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => BlockCategory.other,
        ),
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
        note: json['note'] as String?,
      );

  static String encodeList(List<TimeBlock> blocks) =>
      jsonEncode(blocks.map((b) => b.toJson()).toList());

  static List<TimeBlock> decodeList(String s) => (jsonDecode(s) as List<dynamic>)
      .map((e) => TimeBlock.fromJson(e as Map<String, dynamic>))
      .toList();
}
