import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_entry.dart';

/// A widget that displays a list of tasks.
///
/// This widget uses the [TaskModel] to render a scrollable list of tasks,
/// supporting dismiss (delete), edit, and completion toggle interactions.
class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskModel>(
      builder: (context, model, child) {
        if (model.entityList.isEmpty) {
          return const Center(
            child: Text(
              "No tasks yet. Tap the + button to add a task.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: model.entityList.length,
          itemBuilder: (context, index) {
            final task = model.entityList[index];
            return Dismissible(
              key: Key('task-${task.id}'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                Provider.of<TaskModel>(context, listen: false).delete(task.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Task deleted"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Checkbox(
                    value: task.isComplete,
                    onChanged: (bool? value) {
                      final updatedTask = task.copyWith(isComplete: value ?? false);
                      Provider.of<TaskModel>(context, listen: false).update(updatedTask);
                    },
                  ),
                  title: Text(
                    task.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      decoration: task.isComplete ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text("Due on ${task.dueDate}"),
                  onTap: () {
                    Provider.of<TaskModel>(context, listen: false).setEntityBeingEdited(task);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TaskEntry()),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}