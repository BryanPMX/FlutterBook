import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task.dart';
import 'task_model.dart';

/// A widget for creating or editing a task in the FlutterBook app.
class TaskEntry extends StatefulWidget {
  const TaskEntry({super.key});

  @override
  _TaskEntryState createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final task = Provider.of<TaskModel>(context, listen: false).entityBeingEdited;
    if (task != null) {
      _descriptionController.text = task.description;
      _dueDateController.text = task.dueDate;
      print("📝 [TaskEntry] Loaded task for editing: $task");
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.description),
              title: TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Please enter a description'
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(hintText: 'Due Date'),
                validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Please enter a due date'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: _saveTask,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final existing = taskModel.entityBeingEdited;

    final Task task = Task(
      id: existing?.id,
      description: _descriptionController.text.trim(),
      dueDate: _dueDateController.text.trim(),
      isComplete: existing?.isComplete ?? false,
    );

    if (existing?.id == null) {
      print("📥 [TaskEntry] Creating new task: $task");
      await taskModel.create(task);
    } else {
      print("🔄 [TaskEntry] Updating task: $task");
      await taskModel.update(task);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}


