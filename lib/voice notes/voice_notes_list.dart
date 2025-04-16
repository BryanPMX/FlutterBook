import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_notes_model.dart';
import 'voice_notes_entry.dart';
import 'voice_note.dart';
import '../utils/audio_util.dart';

/// Displays a list of recorded voice notes with playback and delete functionality.
class VoiceNotesList extends StatelessWidget {
  const VoiceNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceNotesModel>(
      builder: (context, model, child) {
        if (model.entityList.isEmpty) {
          return const Center(
            child: Text(
              "No voice notes yet. Tap + to add one.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: model.entityList.length,
          itemBuilder: (context, index) {
            final VoiceNote note = model.entityList[index];

            return Dismissible(
              key: Key('voice-note-${note.id ?? index}'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                if (note.id != null) {
                  model.delete(note.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Voice note deleted")),
                  );
                }
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: const Icon(Icons.mic, color: Colors.blueAccent),
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Recorded on ${note.createdAt.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Play voice note',
                    onPressed: () async {
                      await AudioUtil.play(note.filePath);
                    },
                  ),
                  onTap: () {
                    model.setEntityBeingEdited(note);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoiceNotesEntry(),
                      ),
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

