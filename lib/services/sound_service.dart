import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  FlutterSoundPlayer? _player;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing sound service: $e');
      _isInitialized = false;
    }
  }

  Future<void> dispose() async {
    if (_player != null && _isInitialized) {
      await _player!.closePlayer();
      _player = null;
      _isInitialized = false;
    }
  }

  // Play system sounds for pin/unpin actions
  Future<void> playPinSound() async {
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    } catch (e) {
      print('Error playing pin sound: $e');
    }
  }

  Future<void> playUnpinSound() async {
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.selectionClick();
    } catch (e) {
      print('Error playing unpin sound: $e');
    }
  }

  // Future method to play custom sounds from assets
  Future<void> playCustomSound(String assetPath) async {
    if (!_isInitialized || _player == null) {
      print('Sound service not initialized');
      return;
    }

    try {
      await _player!.startPlayer(
        fromURI: assetPath,
        codec: Codec.mp3,
      );
    } catch (e) {
      print('Error playing custom sound: $e');
    }
  }

  // Method to play different sound effects
  Future<void> playSoundEffect(SoundEffect effect) async {
    switch (effect) {
      case SoundEffect.pin:
        await playPinSound();
        break;
      case SoundEffect.unpin:
        await playUnpinSound();
        break;
      case SoundEffect.delete:
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
        break;
      case SoundEffect.success:
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
        break;
    }
  }
}

enum SoundEffect {
  pin,
  unpin,
  delete,
  success,
}