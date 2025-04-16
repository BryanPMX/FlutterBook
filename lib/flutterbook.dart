// The University of Texas at El Paso
// Bryan Perez

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

// Contacts
import 'contacts/contact.dart';
import 'contacts/contacts_entry.dart';
import 'contacts/contacts_list.dart';
import 'contacts/contacts_model.dart';
import 'contacts/contacts_db_worker.dart';

// Voice Notes
import 'voice notes/voice_note.dart';
import 'voice notes/voice_notes_entry.dart';
import 'voice notes/voice_notes_list.dart';
import 'voice notes/voice_notes_model.dart';
import 'voice notes/voice_notes_db_worker.dart';

/// The main screen of the FlutterBook app.
/// Provides a tabbed interface for Appointments, Contacts, Notes, Tasks, and Voice Notes.
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
    _tabController = TabController(length: 5, vsync: this); // Now 5 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Tab(icon: Icon(Icons.mic), text: "Voice Notes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text("Appointments")),
          ContactsScreen(),
          NotesScreen(),
          TasksScreen(),
          VoiceNotesScreen(),
        ],
      ),
    );
  }
}

// ============================ Contacts Tab ============================

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactsModel>(context, listen: false).loadData("contacts", ContactsDBWorker.db);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ContactsModel>(
        builder: (context, model, child) {
          return IndexedStack(
            index: model.stackIndex,
            children: const [
              ContactsList(),
              ContactsEntry(),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ContactsModel>(
        builder: (context, model, child) {
          return model.stackIndex == 0
              ? FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              final newContact = Contact(id: null, name: "New Contact", email: "", phone: "", notes: "");
              model.setEntityBeingEdited(newContact);
              model.setStackIndex(1);
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================ Notes Tab ============================

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
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
              final newNote = Note(id: null, title: "New Note", content: "Enter content...", color: "red");
              model.setEntityBeingEdited(newNote);
              model.setColor("red");
              model.setStackIndex(1);
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================ Tasks Tab ============================

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
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
              final newTask = Task(id: null, description: "New Task", dueDate: "MM/DD/YYYY", isComplete: false);
              model.setEntityBeingEdited(newTask);
              model.setStackIndex(1);
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================ Voice Notes Tab ============================

/// The screen for managing voice notes in the FlutterBook app.
///
/// Displays a list of recorded voice notes or the entry form based on model state.
// ============================ Voice Notes Tab ============================

/// The screen for managing voice notes in the FlutterBook app.
class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VoiceNotesModel>(context, listen: false)
          .loadData("voiceNotes", VoiceNotesDBWorker.db);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VoiceNotesModel>(
        builder: (context, model, child) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              VoiceNotesList(),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<VoiceNotesModel>(
        builder: (context, model, child) {
          return model.stackIndex == 0
              ? FloatingActionButton(
            child: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {
                model.clearEntityBeingEdited();
                model.setEntityBeingEdited(
                  VoiceNote(
                    id: null,
                    title: '',
                    filePath: '',
                    duration: '',
                    createdAt: DateTime.now(),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceNotesEntry()),
                );
              }
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

