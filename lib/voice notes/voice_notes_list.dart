import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'voice_notes_model.dart';

/// Displays a list of recorded voice notes with waveform and real-time duration indicator.
class VoiceNotesList extends StatefulWidget {
  const VoiceNotesList({super.key});

  @override
  State<VoiceNotesList> createState() => _VoiceNotesListState();
}

class _VoiceNotesListState extends State<VoiceNotesList> {
  final Map<int, PlayerController> _controllers = {};
  final Map<int, Duration> _elapsedDurations = {};
  final Map<int, bool> _isPlaying = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _playOrStop(int id, String path) async {
    final controller = _controllers[id]!;

    if (_isPlaying[id] == true) {
      await controller.stopPlayer();
      setState(() {
        _isPlaying[id] = false;
        _elapsedDurations[id] = Duration.zero;
      });
    } else {
      // Always re-prepare the player before starting playback again
      await controller.stopPlayer(); // ensure no residual state
      await controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
      );
      controller.updateFrequency = UpdateFrequency.high;

      await controller.startPlayer();
      setState(() {
        _elapsedDurations[id] = Duration.zero;
        _isPlaying[id] = true;
      });

      _startTimer(id);

      controller.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped) {
          setState(() => _isPlaying[id] = false);
        }
      });
    }
  }

  void _startTimer(int id) {
    Future.doWhile(() async {
      if (!mounted || _isPlaying[id] != true) return false;
      final current = _elapsedDurations[id] ?? Duration.zero;
      setState(() {
        _elapsedDurations[id] = current + const Duration(seconds: 1);
      });
      await Future.delayed(const Duration(seconds: 1));
      return _controllers[id]!.playerState.isPlaying;
    });
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(1, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

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
            final note = model.entityList[index];
            _controllers[note.id!] ??= PlayerController();
            _isPlaying[note.id!] ??= false;
            _elapsedDurations[note.id!] ??= Duration.zero;

            final total = note.duration;
            final elapsed = _elapsedDurations[note.id!]!;
            final isNowPlaying = _isPlaying[note.id!]!;

            return Dismissible(
              key: Key('voice-note-${note.id}'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.deepOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                model.delete(note.id!);
                _controllers[note.id!]?.dispose();
                _controllers.remove(note.id!);
                _isPlaying.remove(note.id!);
                _elapsedDurations.remove(note.id!);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 4),
                      Text(note.createdAt.toLocal().toString().split(' ')[0],
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(_formatDuration(elapsed),
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AudioFileWaveforms(
                              playerController: _controllers[note.id!]!,
                              enableSeekGesture: true,
                              size: const Size(double.infinity, 46),
                              waveformType: WaveformType.long,
                              playerWaveStyle: const PlayerWaveStyle(
                                fixedWaveColor: Colors.teal,
                                liveWaveColor: Colors.tealAccent,
                                spacing: 3,
                                waveThickness: 2.5,
                                showSeekLine: true,
                                seekLineThickness: 1.5,
                                seekLineColor: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(total, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isNowPlaying ? Icons.stop : Icons.play_arrow,
                            size: 18,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isNowPlaying ? Colors.redAccent : Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          label: Text(isNowPlaying ? "Stop" : "Play"),
                          onPressed: () => _playOrStop(note.id!, note.filePath),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
