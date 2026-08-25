import '../models/task.dart';
import '../models/time_block.dart';
import 'notification_service.dart';

/// Keeps reminder scheduling logic out of the UI. Each task/time block's
/// notification id is derived deterministically from its uuid so we can
/// always find and cancel the right one without storing extra state.
class ReminderScheduler {
  final _notifications = NotificationService();

  int _idFor(String entityId) => entityId.hashCode & 0x7FFFFFFF;

  Future<void> syncTaskReminder(Task task) async {
    final id = _idFor(task.id);
    await _notifications.cancel(id);
    if (!task.reminderEnabled || task.dateTime == null || task.isDone) return;
    await _notifications.scheduleNotification(
      id: id,
      title: 'Task reminder',
      body: task.title,
      dateTime: task.dateTime!,
    );
  }

  Future<void> cancelTaskReminder(Task task) => _notifications.cancel(_idFor(task.id));

  Future<void> syncBlockReminder(TimeBlock block) async {
    final id = _idFor(block.id);
    await _notifications.cancel(id);
    if (!block.reminderEnabled) return;
    await _notifications.scheduleNotification(
      id: id,
      title: 'Starting now',
      body: '${block.title} • ${block.category.label}',
      dateTime: block.startDateTime,
    );
  }

  Future<void> cancelBlockReminder(TimeBlock block) => _notifications.cancel(_idFor(block.id));
}
