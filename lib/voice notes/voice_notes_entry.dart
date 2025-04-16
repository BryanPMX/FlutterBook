import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../utils/audio_util.dart';
import 'voice_note.dart';
import 'voice_notes_model.dart';
import 'voice_notes_db_worker.dart';
import 'package:flutter/scheduler.dart';

class VoiceNotesEntry extends StatefulWidget {
  const VoiceNotesEntry({super.key});

  @override
  State<VoiceNotesEntry> createState() => _VoiceNotesEntryState();
}

class _VoiceNotesEntryState extends State<VoiceNotesEntry> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final RecorderController _recorderController = RecorderController();
  final PlayerController _playerController = PlayerController();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  String _duration = '';
  int? _loadedNoteId;

  int _recordingSeconds = 0;
  int _playbackSeconds = 0;
  Ticker? _recordingTicker;
  Ticker? _playbackTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final model = Provider.of<VoiceNotesModel>(context, listen: false);
    final note = model.entityBeingEdited;

    if (note == null || note.id == null) {
      // New note: clear everything
      _titleController.clear();
      _recordedPath = null;
      _duration = '';
      _loadedNoteId = null;
      _recordingSeconds = 0;
      _playbackSeconds = 0;
    } else if (note.id != _loadedNoteId) {
      // Editing existing note
      _titleController.text = note.title;
      _recordedPath = note.filePath;
      _duration = note.duration;
      _loadedNoteId = note.id;
      _recordingSeconds = 0;
      _playbackSeconds = 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recorderController.dispose();
    _playerController.stopPlayer();
    _recordingTicker?.dispose();
    _playbackTicker?.dispose();
    super.dispose();
  }

  void _startRecordingTimer() {
    _recordingSeconds = 0;
    _recordingTicker = createTicker((_) {
      setState(() {
        _recordingSeconds++;
      });
    })..start();
  }

  void _stopRecordingTimer() {
    _recordingTicker?.stop();
    _recordingTicker?.dispose();
    _recordingTicker = null;
  }

  void _startPlaybackTimer() {
    _playbackSeconds = 0;
    _playbackTicker = createTicker((_) {
      setState(() {
        _playbackSeconds++;
      });
    })..start();
  }

  void _stopPlaybackTimer() {
    _playbackTicker?.stop();
    _playbackTicker?.dispose();
    _playbackTicker = null;
  }

  Future<void> _handleRecording() async {
    if (_isRecording) {
      final result = await AudioUtil.stopRecording();
      _recorderController.reset();
      _stopRecordingTimer();
      setState(() {
        _recordedPath = result['filePath'];
        _duration = result['duration'] ?? '';
        _isRecording = false;
      });
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await AudioUtil.startRecording(path);
      _recorderController.record();
      _startRecordingTimer();
      setState(() {
        _recordedPath = path;
        _isRecording = true;
      });
    }
  }

  Future<void> _handlePlayback() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      await _playerController.stopPlayer();
      _stopPlaybackTimer();
      setState(() => _isPlaying = false);
    } else {
      await _playerController.preparePlayer(path: _recordedPath!);
      await _playerController.startPlayer();
      _startPlaybackTimer();
      setState(() => _isPlaying = true);

      _playerController.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped) {
          _stopPlaybackTimer();
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final model = Provider.of<VoiceNotesModel>(context, listen: false);
    final existing = model.entityBeingEdited;

    final updatedNote = VoiceNote(
      id: existing?.id,
      title: _titleController.text.trim(),
      filePath: _recordedPath ?? existing?.filePath ?? '',
      duration: _duration.isNotEmpty ? _duration : existing?.duration ?? '',
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing?.id == null) {
      await VoiceNotesDBWorker.db.create(updatedNote);
    } else {
      await VoiceNotesDBWorker.db.update(updatedNote);
    }

    await model.loadData("voiceNotes", VoiceNotesDBWorker.db);
    model.clearEntityBeingEdited();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice note saved"), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Note Entry")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
              validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),
            _isRecording
                ? AudioWaveforms(
              enableGesture: false,
              size: const Size(double.infinity, 60.0),
              recorderController: _recorderController,
              waveStyle: const WaveStyle(
                waveColor: Colors.blue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(_isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue),
              title: Text(_isRecording ? "Stop Recording" : "Start Recording"),
              onTap: _handleRecording,
              trailing: Text("${_recordingSeconds}s"),
            ),
            ListTile(
              leading: Icon(_isPlaying ? Icons.stop : Icons.play_arrow,
                  color: _isPlaying ? Colors.red : Colors.blue),
              title: Text(_isPlaying ? "Stop Playback" : "Play Recording"),
              onTap: _handlePlayback,
              trailing: Text("${_playbackSeconds}s"),
            ),
            AudioFileWaveforms(
              size: const Size(double.infinity, 70.0),
              playerController: _playerController,
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.green,
                liveWaveColor: Colors.lightGreen,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}



