import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/format.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = create, non-null = edit
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TaskService();
  late final _title = TextEditingController(text: widget.task?.title);
  late final _desc = TextEditingController(text: widget.task?.description);
  late Priority _priority = widget.task?.priority ?? Priority.medium;
  late DateTime _due =
      widget.task?.dueDate ?? DateTime.now().add(const Duration(hours: 1));
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due),
    );
    if (time == null) return;
    setState(
      () => _due = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = Task(
      id: widget.task?.id ?? '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      priority: _priority,
      dueDate: _due,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    try {
      if (widget.task == null) {
        await _service.add(task);
      } else {
        await _service.update(task);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save task')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit task' : 'New task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                const Text('Priority'),
                const SizedBox(height: 8),
                SegmentedButton<Priority>(
                  segments: const [
                    ButtonSegment(value: Priority.low, label: Text('Low')),
                    ButtonSegment(
                      value: Priority.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(value: Priority.high, label: Text('High')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _pickDue,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('Due: ${formatDue(_due)}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(editing ? 'Save changes' : 'Create task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
