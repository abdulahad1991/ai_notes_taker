import 'dart:async';
import 'dart:io';
import 'dart:typed_data' hide Uint8List;

import 'package:ai_notes_taker/models/response/transcribe_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/api_service.dart';
import '../../../services/app_auth_service.dart';
import '../../../shared/functions.dart';
import '../../common/ui_helpers.dart';

class VoiceViewmodel extends ReactiveViewModel {
  BuildContext context;
  bool isReminder;

  VoiceViewmodel(this.context, this.isReminder);

  late FlutterTts flutterTts;
  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool isPlayerInited = false;

  bool isRecording = false;
  bool isProcessing = false;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _recordedPath;

  final StreamController<Uint8List> _recordingDataController =
      StreamController<Uint8List>();
  List<Uint8List> _recordingData = [];

  Future<void> initPlayer() async {
    await _player.openPlayer();
    isPlayerInited = true;
  }

  Future<void> init() async {
    initPlayer();
    flutterTts = FlutterTts();
    bool permissionGranted = false;

    // For Android, use Permission.contacts
    final status = await Permission.microphone.request();
    final storage = await Permission.storage.request();
    final audio = await Permission.audio.request();
    if (status.isPermanentlyDenied) {
      // await openAppSettings();
    }
    if (!status.isGranted) {
      showErrorDialog('Microphone permission is required', context);
      return;
    } else {
      permissionGranted = true;
    }

    if (permissionGranted) {
      try {
        // Initialize recorder
        await _recorder.openRecorder();

        // Set up recording stream listener
        _recordingDataController.stream.listen((data) {
          _recordingData.add(data);
          print("Received audio chunk: ${data.length} bytes");
        });

        print("Recorder initialized successfully");
      } catch (e) {
        print("Error initializing recorder: $e");
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _player.closePlayer();
    _recorder.closeRecorder();
    _recordingDataController.close();
    super.dispose();
  }

  Future<void> playRecordedFile() async {
    if (!isPlayerInited) {
      await initPlayer();
    }

    if (_recordedPath == null) {
      print("No recorded file path");
      return;
    }

    final file = File(_recordedPath!);

    if (!file.existsSync()) {
      print("Audio file doesn't exist at: $_recordedPath");
      return;
    }

    try {
      final fileSize = await file.length();
      print("Playing audio file: $_recordedPath");
      print("File size: $fileSize bytes");

      if (fileSize == 0) {
        print("File is empty - recording may have failed");
        return;
      }

      await _player.startPlayer(
          fromURI: _recordedPath!,
          whenFinished: () {
            print("Playback finished");
          });
    } catch (e) {
      print("Playback error: $e");
    }
  }

  Future<void> stopPlayback() async {
    await _player.stopPlayer();
  }

  Future<String> getTempFilePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Create recordings subdirectory
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!recordingsDir.existsSync()) {
        await recordingsDir.create(recursive: true);
      }

      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      final fullPath = '${recordingsDir.path}/$fileName';

      print("Generated file path: $fullPath");
      return fullPath;
    } catch (e) {
      print("Error getting file path: $e");
      rethrow;
    }
  }

  Future<void> startRecording() async {
    try {
      isRecording = true;
      isProcessing = false;
      rebuildUi();
      HapticFeedback.mediumImpact();

      // Clear previous recording data
      _recordingData.clear();

      print("Starting recording to memory stream");

      // Start recording to stream (memory)
      await _recorder.startRecorder(
        toStream: _recordingDataController.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 16000,
      );

      print("Recording started successfully");
    } catch (e) {
      print("Error starting recording: $e");
      isRecording = false;
      rebuildUi();
    }
  }

  Future<File> stopAndGetAudioBytes() async {
    try {
      print("Stopping recorder...");

      // Stop recording
      await _recorder.stopRecorder();

      // Wait a moment for any remaining data
      await Future.delayed(Duration(milliseconds: 200));

      if (_recordingData.isEmpty) {
        throw Exception("No audio data recorded");
      }

      // Combine all recorded data chunks
      final totalLength =
          _recordingData.fold<int>(0, (sum, data) => sum + data.length);
      final combinedData = Uint8List(totalLength);

      int offset = 0;
      for (final data in _recordingData) {
        combinedData.setRange(offset, offset + data.length, data);
        offset += data.length;
      }

      print("Combined audio data: ${combinedData.length} bytes");

      // Create WAV file with proper header
      final wavData = _createWavFile(combinedData);

      // Save to file
      _recordedPath = await getTempFilePath();
      final file = File(_recordedPath!);
      await file.writeAsBytes(wavData);

      print(
          "Recording saved to file: $_recordedPath, size: ${wavData.length} bytes");

      // Verify file was created
      if (!file.existsSync()) {
        throw Exception("Failed to create audio file");
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception("Created audio file is empty");
      }

      return file;
    } catch (e) {
      print("Error stopping recording: $e");
      rethrow;
    }
  }

  Uint8List _createWavFile(Uint8List audioData) {
    final sampleRate = 16000;
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = audioData.length;
    final fileSize = 36 + dataSize;

    final wavHeader = ByteData(44);

    // RIFF header
    wavHeader.setUint8(0, 0x52); // R
    wavHeader.setUint8(1, 0x49); // I
    wavHeader.setUint8(2, 0x46); // F
    wavHeader.setUint8(3, 0x46); // F
    wavHeader.setUint32(4, fileSize, Endian.little);
    wavHeader.setUint8(8, 0x57); // W
    wavHeader.setUint8(9, 0x41); // A
    wavHeader.setUint8(10, 0x56); // V
    wavHeader.setUint8(11, 0x45); // E

    // fmt chunk
    wavHeader.setUint8(12, 0x66); // f
    wavHeader.setUint8(13, 0x6D); // m
    wavHeader.setUint8(14, 0x74); // t
    wavHeader.setUint8(15, 0x20); // (space)
    wavHeader.setUint32(16, 16, Endian.little); // chunk size
    wavHeader.setUint16(20, 1, Endian.little); // audio format (PCM)
    wavHeader.setUint16(22, numChannels, Endian.little);
    wavHeader.setUint32(24, sampleRate, Endian.little);
    wavHeader.setUint32(28, byteRate, Endian.little);
    wavHeader.setUint16(32, blockAlign, Endian.little);
    wavHeader.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    wavHeader.setUint8(36, 0x64); // d
    wavHeader.setUint8(37, 0x61); // a
    wavHeader.setUint8(38, 0x74); // t
    wavHeader.setUint8(39, 0x61); // a
    wavHeader.setUint32(40, dataSize, Endian.little);

    // Combine header and audio data
    final result = Uint8List(44 + dataSize);
    result.setRange(0, 44, wavHeader.buffer.asUint8List());
    result.setRange(44, 44 + dataSize, audioData);

    return result;
  }

  Future<void> stopRecordingAndProcess({File? file}) async {
    try {
      isRecording = false;
      isProcessing = false;
      rebuildUi();
      HapticFeedback.lightImpact();

      File audioFile;
      if (file != null) {
        audioFile = file;
      } else {
        audioFile = await stopAndGetAudioBytes();
      }

      // Test playback (optional)
      // await playRecordedFile();

      await sendVoiceAndProcessResponse(file: audioFile);
    } catch (e) {
      print("Error in stopRecordingAndProcess: $e");
      isProcessing = false;
      rebuildUi();
    }
  }

  Future<void> sendVoiceAndProcessResponse({required File file}) async {
    try {
      var response = await runBusyFuture(
        api.transcribe(
            file: file,
            is_reminder: isReminder == true ? 1 : 0,
            user_current_datetime: DateTime.now().toUtc().toIso8601String(),
            offset: getTimezoneOffsetFormatted()),
        busyObject: "transcribe",
        throwException: true,
      );
      if (response != null) {
        isProcessing = false;
        final data = response as TranscribeResponse;

        Navigator.of(context).pop(true);
        // playText(data.transcription!);
      }
    } on FormatException catch (e) {
      print(e);
    }
  }

  Future<void> playText(String message) async {
    /*String lang = "ur";
    String text = "";
    if (LocaleSettings.currentLocale == AppLocale.ur) {
      lang = "ur";
      text = message.ur!;
    } else {
      lang = "en";
      text = message.en!;
    }*/
    showServerResponsePopup(message, "en");
    await flutterTts.setLanguage("en");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(message);
  }

  void showServerResponsePopup(String message, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text(lang == "ur" ? "پیغام" : "Message"),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              flutterTts.stop();
              Navigator.of(context).pop(); // Close dialog// Navigate back with refresh signal
            },
            child: Text(lang == "ur" ? "بند کریں" : "Close"),
          ),
        ],
      ),
    );
  }
}
