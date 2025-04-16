import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

/// A utility class for recording and playing audio in the FlutterBook app.
///
/// Uses [FlutterSoundRecorder] for recording and [AudioPlayer] for playback.
class AudioUtil {
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static bool _isRecorderInitialized = false;
  static DateTime? _startTime;

  /// Initializes the recorder and requests necessary permissions.
  ///
  /// Throws an exception if permissions are denied.
  static Future<void> init() async {
    if (_isRecorderInitialized) return;

    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final audioStatus = await Permission.audio.request(); // Android 13+

    final allGranted = micStatus.isGranted &&
        (storageStatus.isGranted || audioStatus.isGranted);

    if (!allGranted) {
      throw Exception('Microphone and storage permissions not granted.');
    }

    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  /// Starts recording to a given file path.
  ///
  /// @param path The path where the audio will be saved.
  static Future<void> startRecording(String path) async {
    await init();
    _startTime = DateTime.now();
    await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
  }

  /// Stops the recording and returns the saved file path and duration.
  ///
  /// @returns A [Map] with keys `filePath` and `duration`.
  static Future<Map<String, String?>> stopRecording() async {
    final filePath = await _recorder.stopRecorder();
    final endTime = DateTime.now();
    final duration = _startTime != null ? endTime.difference(_startTime!) : Duration.zero;

    return {
      'filePath': filePath,
      'duration': '${duration.inSeconds} sec',
    };
  }

  /// Releases the recorder resources.
  ///
  /// Call this from `dispose()` in the consuming widget.
  static Future<void> dispose() async {
    if (!_isRecorderInitialized) return;
    await _recorder.closeRecorder();
    _isRecorderInitialized = false;
  }

  /// Plays a recorded audio file from the provided path.
  ///
  /// @param filePath The full path of the audio file to play.
  static Future<void> play(String filePath) async {
    if (!File(filePath).existsSync()) {
      throw Exception("Audio file not found at $filePath");
    }

    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(filePath));
  }
}



