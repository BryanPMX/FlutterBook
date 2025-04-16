// The University of Texas at El Paso
// Bryan Perez

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flutterbook.dart';

// Models
import 'notes/notes_model.dart';
import 'tasks/task_model.dart';
import 'contacts/contacts_model.dart';
import 'voice notes/voice_notes_model.dart'; // ✅ New voice notes model

/// The entry point of the FlutterBook application.
///
/// This function initializes the app and sets up the root widget.
void main() {
  runApp(const FlutterBookApp());
}

/// The root widget of the FlutterBook application.
///
/// This stateless widget sets up the app's theme, provides the state management
/// models, and defines the home screen.
class FlutterBookApp extends StatelessWidget {
  const FlutterBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotesModel()),
        ChangeNotifierProvider(create: (context) => TaskModel()),
        ChangeNotifierProvider(create: (context) => ContactsModel()),
        ChangeNotifierProvider(create: (context) => VoiceNotesModel()), // ✅ Voice notes provider
      ],
      child: MaterialApp(
        title: 'FlutterBook',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        home: const FlutterBook(),
      ),
    );
  }
}

