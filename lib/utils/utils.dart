// The University of Texas at El Paso
// Bryan Perez

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Utility functions and constants for the FlutterBook app.
///
/// This file provides access to common resources, such as the app's documents
/// directory, and utility functions like color parsing.
class Utils {
  /// The app's documents directory where persistent data (e.g., database) is stored.
  static Directory? _docsDir;

  /// Gets the app's documents directory.
  ///
  /// This getter ensures the directory is initialized before access.
  /// Call [init] before using this getter to ensure the directory is ready.
  static Directory get docsDir {
    if (_docsDir == null) {
      throw StateError(
          'Documents directory not initialized. Call Utils.init() first.');
    }
    return _docsDir!;
  }

  /// Initializes the utility class by setting up the documents directory.
  ///
  /// This method must be called before accessing [docsDir].
  /// @return A [Future] that completes when initialization is done.
  static Future<void> init() async {
    stdout.writeln("## Utils.init()");

    // Get the app's documents directory using path_provider
    _docsDir = await getApplicationDocumentsDirectory();
    stdout.writeln("## Utils.init(): docsDir = ${_docsDir?.path}");
  }

  /// Parses a color name into a [Color] object.
  ///
  /// @param colorName The name of the color (e.g., "red", "blue").
  /// @return The corresponding [Color] object, or null if the color is invalid.
  static Color? parseColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'grey':
        return Colors.grey;
      case 'purple':
        return Colors.purple;
      default:
        return null;
    }
  }
}