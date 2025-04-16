// The University of Texas at El Paso
// Bryan Perez

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flutterbook.dart';
import 'notes/notes_model.dart';
import 'tasks/task_model.dart';
import 'contacts/contacts_model.dart'; // ✅ Added ContactsModel import

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
        // Provide the NotesModel to the widget tree
        ChangeNotifierProvider(create: (context) => NotesModel()),
        // Provide the TasksModel to the widget tree
        ChangeNotifierProvider(create: (context) => TaskModel()),
        // Provide the ContactsModel to the widget tree
        ChangeNotifierProvider(create: (context) => ContactsModel()),
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
