import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/audio_util.dart';
import 'voice_note.dart';
import 'voice_notes_model.dart';
import 'voice_notes_db_worker.dart';
import 'package:path_provider/path_provider.dart';

/// Entry screen for creating or editing voice notes in FlutterBook.
class VoiceNotesEntry extends StatefulWidget {
  const VoiceNotesEntry({super.key});

  @override
  State<VoiceNotesEntry> createState() => _VoiceNotesEntryState();
}

class _VoiceNotesEntryState extends State<VoiceNotesEntry> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  String? _duration;
  int? _currentLoadedNoteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final model = Provider.of<VoiceNotesModel>(context, listen: false);
    final note = model.entityBeingEdited;

    if (note != null) {
      _titleController.text = note.title;
      _recordedPath = note.filePath;
      _duration = note.duration;
      _currentLoadedNoteId = note.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    AudioUtil.dispose();
    super.dispose();
  }

  Future<void> _handleRecording() async {
    if (_isRecording) {
      final result = await AudioUtil.stopRecording();
      setState(() {
        _recordedPath = result['filePath'];
        _duration = result['duration'];
        _isRecording = false;
      });
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await AudioUtil.startRecording(path);
      setState(() {
        _recordedPath = path;
        _isRecording = true;
      });
    }
  }

  Future<void> _handlePlayback() async {
    if (_isPlaying || _recordedPath == null) return;
    setState(() => _isPlaying = true);
    await AudioUtil.play(_recordedPath!);
    setState(() => _isPlaying = false);
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final model = Provider.of<VoiceNotesModel>(context, listen: false);
    final existing = model.entityBeingEdited;

    final updatedNote = VoiceNote(
      id: existing?.id,
      title: _titleController.text.trim(),
      filePath: _recordedPath ?? existing?.filePath ?? '',
      duration: _duration ?? existing?.duration ?? '',
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing?.id == null) {
      await VoiceNotesDBWorker.db.create(updatedNote);
    } else {
      await VoiceNotesDBWorker.db.update(updatedNote);
    }

    await model.loadData("voiceNotes", VoiceNotesDBWorker.db);
    model.setStackIndex(0);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice note saved"), backgroundColor: Colors.green),
    );
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
              validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.mic, color: _isRecording ? Colors.red : Colors.blue),
              title: Text(_isRecording ? "Recording..." : "Start Recording"),
              trailing: IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                color: _isRecording ? Colors.red : Colors.blue,
                onPressed: _handleRecording,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: Text(
                _duration != null ? "Play Recording ($_duration)" : "Play Recording",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: _handlePlayback,
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