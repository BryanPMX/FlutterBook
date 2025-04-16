import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_notes_model.dart';
import 'voice_notes_entry.dart';
import 'voice_note.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

/// Displays a list of recorded voice notes with playback and delete functionality.
class VoiceNotesList extends StatefulWidget {
  const VoiceNotesList({super.key});

  @override
  State<VoiceNotesList> createState() => _VoiceNotesListState();
}

class _VoiceNotesListState extends State<VoiceNotesList> {
  final Map<int, PlayerController> _playerControllers = {};

  @override
  void dispose() {
    for (final controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _playOrStop(int id, String path) async {
    final controller = _playerControllers[id]!;

    if (controller.playerState.isPlaying) {
      await controller.stopPlayer();
    } else {
      await controller.preparePlayer(path: path);
      await controller.startPlayer();
    }

    setState(() {}); // Rebuild to refresh icon state
  }

  String _formatDuration(String durationStr) {
    if (durationStr.isEmpty) return "0:00";
    final seconds = int.tryParse(durationStr.split(" ").first) ?? 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

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
            _playerControllers[note.id!] ??= PlayerController();

            return Dismissible(
              key: Key('voice-note-${note.id}'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                model.delete(note.id!);
                _playerControllers[note.id!]?.dispose();
                _playerControllers.remove(note.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Voice note deleted")),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recorded on ${note.createdAt.toLocal().toString().split(' ')[0]}"),
                      Text("Duration: ${_formatDuration(note.duration)}"),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("0:00", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_formatDuration(note.duration),
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      AudioFileWaveforms(
                        playerController: _playerControllers[note.id!]!,
                        enableSeekGesture: true,
                        size: const Size(double.infinity, 50),
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: const PlayerWaveStyle(
                          fixedWaveColor: Colors.blueAccent,
                          liveWaveColor: Colors.blue,
                          spacing: 6,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _playerControllers[note.id!]!.playerState.isPlaying
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                    onPressed: () => _playOrStop(note.id!, note.filePath),
                  ),
                  onTap: () {
                    model.setEntityBeingEdited(note);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceNotesEntry()),
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

