import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/time_block.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_scheduler.dart';
import '../widgets/date_strip.dart';
import '../widgets/task_list_view.dart';
import '../widgets/timeline_view.dart';
import 'add_edit_task_screen.dart';
import 'add_edit_time_block_screen.dart' show AddEditTimeBlockScreen, TimeBlockScreenResult;

class DayScreen extends StatefulWidget {
  const DayScreen({super.key});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  final _storage = StorageService();
  final _reminders = ReminderScheduler();

  List<Task> _tasks = [];
  List<TimeBlock> _blocks = [];
  DateTime _selectedDate = _today();
  bool _loading = true;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _load();
    // Ask up front so reminders work the first time someone enables one,
    // rather than silently failing because permission was never granted.
    NotificationService().requestPermissions();
  }

  Future<void> _load() async {
    final tasks = await _storage.loadTasks();
    final blocks = await _storage.loadBlocks();
    setState(() {
      _tasks = tasks;
      _blocks = blocks;
      _loading = false;
    });
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<Task> get _tasksForDay {
    final list = _tasks.where((t) => _sameDay(t.date, _selectedDate)).toList();
    list.sort((a, b) {
      if (a.time == null && b.time == null) return a.title.compareTo(b.title);
      if (a.time == null) return 1;
      if (b.time == null) return -1;
      return (a.time!.hour * 60 + a.time!.minute).compareTo(b.time!.hour * 60 + b.time!.minute);
    });
    return list;
  }

  List<TimeBlock> get _blocksForDay {
    final list = _blocks.where((b) => _sameDay(b.date, _selectedDate)).toList();
    list.sort(
      (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(b.startTime.hour * 60 + b.startTime.minute),
    );
    return list;
  }

  Future<void> _persistTasks() => _storage.saveTasks(_tasks);
  Future<void> _persistBlocks() => _storage.saveBlocks(_blocks);

  Future<void> _addOrEditTask({Task? existing}) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(initialDate: _selectedDate, existing: existing)),
    );
    if (result == null) return;

    setState(() {
      if (existing != null) {
        _tasks[_tasks.indexWhere((t) => t.id == existing.id)] = result;
      } else {
        _tasks.add(result);
      }
    });
    await _persistTasks();
    await _reminders.syncTaskReminder(result);
  }

  Future<void> _toggleTaskDone(Task task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    setState(() => _tasks[_tasks.indexWhere((t) => t.id == task.id)] = updated);
    await _persistTasks();
    // Completed tasks don't need to keep ringing.
    await _reminders.syncTaskReminder(updated);
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    await _persistTasks();
    await _reminders.cancelTaskReminder(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${task.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              setState(() => _tasks.add(task));
              await _persistTasks();
              await _reminders.syncTaskReminder(task);
            },
          ),
        ),
      );
    }
  }

  Future<void> _addOrEditBlock({TimeBlock? existing}) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(builder: (_) => AddEditTimeBlockScreen(initialDate: _selectedDate, existing: existing)),
    );
    if (result == null) return;

    if (result == TimeBlockScreenResult.delete) {
      if (existing != null) await _deleteBlock(existing);
      return;
    }

    if (result is TimeBlock) {
      setState(() {
        if (existing != null) {
          _blocks[_blocks.indexWhere((b) => b.id == existing.id)] = result;
        } else {
          _blocks.add(result);
        }
      });
      await _persistBlocks();
      await _reminders.syncBlockReminder(result);
    }
  }

  Future<void> _deleteBlock(TimeBlock block) async {
    setState(() => _blocks.removeWhere((b) => b.id == block.id));
    await _persistBlocks();
    await _reminders.cancelBlockReminder(block);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('New Task'),
              onTap: () {
                Navigator.pop(context);
                _addOrEditTask();
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('New Time Block'),
              onTap: () {
                Navigator.pop(context);
                _addOrEditBlock();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateFromCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormat.MMMEd().format(_selectedDate)),
          actions: [
            IconButton(icon: const Icon(Icons.today), onPressed: () => setState(() => _selectedDate = _today())),
            IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDateFromCalendar),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Tasks'), Tab(text: 'Timeline')]),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DateStrip(selectedDate: _selectedDate, onSelect: (d) => setState(() => _selectedDate = d)),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: [
                        TaskListView(
                          tasks: _tasksForDay,
                          onToggleDone: _toggleTaskDone,
                          onTap: (t) => _addOrEditTask(existing: t),
                          onDelete: _deleteTask,
                          onAdd: () => _addOrEditTask(),
                        ),
                        TimelineView(
                          date: _selectedDate,
                          blocks: _blocksForDay,
                          onTap: (b) => _addOrEditBlock(existing: b),
                          onAdd: () => _addOrEditBlock(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(onPressed: _showAddSheet, child: const Icon(Icons.add)),
      ),
    );
  }
}
