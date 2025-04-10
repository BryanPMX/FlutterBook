// The University of Texas at El Paso
// Bryan Perez

import 'dart:io' show stdout;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Notes
import 'notes/notes_entry.dart';
import 'notes/notes_list.dart';
import 'notes/notes_model.dart';
import 'notes/note.dart';
import 'notes/notes_db_worker.dart';

// Tasks
import 'tasks/task.dart';
import 'tasks/task_entry.dart';
import 'tasks/task_list.dart';
import 'tasks/task_model.dart';
import 'tasks/task_db_worker.dart';

/// The main screen of the FlutterBook app.
///
/// Provides a tabbed interface for Appointments, Contacts, Notes, and Tasks.
class FlutterBook extends StatefulWidget {
  const FlutterBook({super.key});

  @override
  FlutterBookState createState() => FlutterBookState();
}

class FlutterBookState extends State<FlutterBook> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    stdout.writeln("## FlutterBookState.initState()");
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    stdout.writeln("## FlutterBookState.dispose()");
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    stdout.writeln("## FlutterBook.build()");
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlutterBook"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.date_range), text: "Appointments"),
            Tab(icon: Icon(Icons.contacts), text: "Contacts"),
            Tab(icon: Icon(Icons.note), text: "Notes"),
            Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text("Appointments")),
          Center(child: Text("Contacts")),
          NotesScreen(),
          TasksScreen(),
        ],
      ),
    );
  }
}

/// The screen for the Notes tab, displaying either a list view or an entry view.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesModel>(context, listen: false).loadData("notes", NotesDBWorker.db);
    });
  }

  @override
  Widget build(BuildContext context) {
    stdout.writeln("## NotesScreen.build()");
    return Scaffold(
      body: Consumer<NotesModel>(
        builder: (context, model, child) {
          return IndexedStack(
            index: model.stackIndex,
            children: const [
              NotesList(),
              NotesEntry(),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<NotesModel>(
        builder: (context, model, child) {
          return model.stackIndex == 0
              ? FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              try {
                final newNote = Note(
                  id: null,
                  title: "New Note",
                  content: "Enter content...",
                  color: "red",
                );
                model.setEntityBeingEdited(newNote);
                model.setColor("red");
                model.setStackIndex(1);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    content: Text("Failed to create new note: $e"),
                  ),
                );
              }
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

/// The screen for the Tasks tab, displaying either a list view or an entry view.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskModel>(context, listen: false).loadData("tasks", TasksDBWorker.db);
    });
  }

  @override
  Widget build(BuildContext context) {
    stdout.writeln("## TasksScreen.build()");
    return Scaffold(
      body: Consumer<TaskModel>(
        builder: (context, model, child) {
          return IndexedStack(
            index: model.stackIndex,
            children: const [
              TaskList(),
              TaskEntry(),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TaskModel>(
        builder: (context, model, child) {
          return model.stackIndex == 0
              ? FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              try {
                final newTask = Task(
                  id: null,
                  description: "New Task",
                  dueDate: "MM/DD/YYYY",
                  isComplete: false,
                );
                model.setEntityBeingEdited(newTask);
                model.setStackIndex(1);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    content: Text("Failed to create new task: $e"),
                  ),
                );
              }
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
