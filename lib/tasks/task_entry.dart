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
  bool _isComplete = false;
  int? _currentLoadedTaskId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  /// Loads task data into the text controllers and checkbox.
  void _loadInitialData() {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final task = taskModel.entityBeingEdited;
    if (task != null) {
      _descriptionController.text = task.description;
      _dueDateController.text = task.dueDate;
      _isComplete = task.isComplete;
      _currentLoadedTaskId = task.id;
    } else {
      _descriptionController.clear();
      _dueDateController.clear();
      _isComplete = false;
      _currentLoadedTaskId = null;
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
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        final task = taskModel.entityBeingEdited;
        if (task != null && task.id != _currentLoadedTaskId) {
          _descriptionController.text = task.description;
          _dueDateController.text = task.dueDate;
          _isComplete = task.isComplete;
          _currentLoadedTaskId = task.id;
        }

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
                CheckboxListTile(
                  value: _isComplete,
                  title: const Text("Mark as complete"),
                  onChanged: (val) {
                    setState(() {
                      _isComplete = val ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () => _saveTask(taskModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saves or updates the task in the database and resets the form.
  Future<void> _saveTask(TaskModel model) async {
    if (!_formKey.currentState!.validate()) return;

    final existing = model.entityBeingEdited;

    final Task updatedTask = Task(
      id: existing?.id,
      description: _descriptionController.text.trim(),
      dueDate: _dueDateController.text.trim(),
      isComplete: _isComplete,
    );

    if (existing?.id == null) {
      await model.create(updatedTask);
    } else {
      await model.update(updatedTask);
    }

    if (!mounted) return;

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Task saved"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}


