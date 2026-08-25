import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final DateTime initialDate;
  final Task? existing;

  const AddEditTaskScreen({super.key, required this.initialDate, this.existing});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _date;
  TimeOfDay? _time;
  late TaskPriority _priority;
  bool _reminderEnabled = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _titleController = TextEditingController(text: t?.title ?? '');
    _date = t?.date ?? widget.initialDate;
    _time = t?.time;
    _priority = t?.priority ?? TaskPriority.medium;
    _reminderEnabled = t?.reminderEnabled ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      date: _date,
      time: _time,
      isDone: widget.existing?.isDone ?? false,
      priority: _priority,
      reminderEnabled: _reminderEnabled && _time != null,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              autofocus: !_isEditing,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                child: Text(DateFormat.yMMMd().format(_date)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due time (optional)',
                  border: const OutlineInputBorder(),
                  suffixIcon: _time != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _time = null;
                            _reminderEnabled = false;
                          }),
                        )
                      : null,
                ),
                child: Text(_time != null ? _time!.format(context) : 'No time set'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
              items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remind me'),
              subtitle: Text(
                _time == null ? 'Set a due time to enable reminders' : 'Notify at ${_time!.format(context)}',
              ),
              value: _reminderEnabled && _time != null,
              onChanged: _time == null ? null : (v) => setState(() => _reminderEnabled = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
