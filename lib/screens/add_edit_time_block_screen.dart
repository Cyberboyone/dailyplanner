import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/time_block.dart';

/// Signals to the caller that the user chose to delete this block, as
/// opposed to popping a [TimeBlock] (save) or null (cancel).
enum TimeBlockScreenResult { delete }

class AddEditTimeBlockScreen extends StatefulWidget {
  final DateTime initialDate;
  final TimeBlock? existing;

  const AddEditTimeBlockScreen({super.key, required this.initialDate, this.existing});

  @override
  State<AddEditTimeBlockScreen> createState() => _AddEditTimeBlockScreenState();
}

class _AddEditTimeBlockScreenState extends State<AddEditTimeBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late BlockCategory _category;
  bool _reminderEnabled = false;
  String? _timeError;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _titleController = TextEditingController(text: b?.title ?? '');
    _noteController = TextEditingController(text: b?.note ?? '');
    _date = b?.date ?? widget.initialDate;
    _startTime = b?.startTime ?? TimeOfDay.now();
    _endTime = b?.endTime ?? _addHour(_startTime);
    _category = b?.category ?? BlockCategory.work;
    _reminderEnabled = b?.reminderEnabled ?? false;
  }

  TimeOfDay _addHour(TimeOfDay t) {
    final total = (t.hour * 60 + t.minute + 60) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
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

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  int _minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_minutesOf(_endTime) <= _minutesOf(_startTime)) {
      setState(() => _timeError = 'End time must be after start time');
      return;
    }
    setState(() => _timeError = null);

    final block = TimeBlock(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      category: _category,
      reminderEnabled: _reminderEnabled,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    Navigator.of(context).pop(block);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this time block?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(TimeBlockScreenResult.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Time Block' : 'New Time Block'),
        actions: _isEditing
            ? [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete)]
            : null,
      ),
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
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStart,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start', border: OutlineInputBorder()),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickEnd,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End', border: OutlineInputBorder()),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            if (_timeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_timeError!, style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BlockCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: BlockCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remind me'),
              subtitle: Text('Notify at ${_startTime.format(context)} when this block starts'),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEditing ? 'Save Changes' : 'Add Time Block'),
            ),
          ],
        ),
      ),
    );
  }
}
