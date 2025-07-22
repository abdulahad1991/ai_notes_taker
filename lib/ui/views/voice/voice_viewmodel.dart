import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import '../../../app/app.locator.dart';
import '../../../services/api_service.dart';
import '../../../services/app_auth_service.dart';

class VoiceViewmodel extends ReactiveViewModel {
  BuildContext context;

  VoiceViewmodel(this.context);

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();

  bool isRecording = false;
  bool isProcessing = false;

  void init() {

  }

  @override
  void dispose() {

    super.dispose();
  }

  String? _recordedPath;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Future<void> startRecording() async {
    isRecording = true;
    isProcessing = false;
    rebuildUi();
    HapticFeedback.mediumImpact();
    await _recorder.openRecorder();
    _recordedPath = '/tmp/temp.wav'; // choose a suitable path
    await _recorder.startRecorder(
      toFile: _recordedPath,
      codec: Codec.pcm16WAV,
    );
  }

  Future<File> stopAndGetAudioBytes() async {
    await _recorder.stopRecorder();
    if (_recordedPath == null) throw Exception("No recorded file");
    final file = File(_recordedPath!);
    // return await file.readAsBytes();
    return file;
  }

  /// Call to stop recording and process voice
  Future<void> stopRecordingAndProcess({File? file}) async {
    isRecording = false;
    isProcessing = true;
    rebuildUi();
    HapticFeedback.lightImpact();

    await sendVoiceAndProcessResponse(file: file!);
  }

  Future<void> sendVoiceAndProcessResponse({required File file}) async {
    try {
      var response = await runBusyFuture(
        api.voiceIntent(file: file),
        throwException: true,
      );
      if (response != null) {
        final data = response.data as VoiceResponse;
      }
    } on FormatException catch (e) {
      print(e);
    }
  }

}
