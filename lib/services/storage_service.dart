import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/time_block.dart';

/// Handles all local persistence. No backend, no login — everything lives
/// on-device via SharedPreferences as JSON blobs.
class StorageService {
  static const _tasksKey = 'planner_tasks_v1';
  static const _blocksKey = 'planner_blocks_v1';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Task.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, Task.encodeList(tasks));
  }

  Future<List<TimeBlock>> loadBlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_blocksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return TimeBlock.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBlocks(List<TimeBlock> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blocksKey, TimeBlock.encodeList(blocks));
  }
}
