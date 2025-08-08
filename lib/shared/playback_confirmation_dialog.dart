import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PlaybackConfirmationDialog extends StatefulWidget {
  final File audioFile;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PlaybackConfirmationDialog({
    required this.audioFile,
    required this.onConfirm,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  State<PlaybackConfirmationDialog> createState() =>
      _PlaybackConfirmationDialogState();
}

class _PlaybackConfirmationDialogState extends State<PlaybackConfirmationDialog> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.startPlayer(
      fromURI: widget.audioFile.path,
      whenFinished: () {
        setState(() => isPlaying = false);
      },
    );
    setState(() => isPlaying = true);
  }

  Future<void> _stop() async {
    await _player.stopPlayer();
    setState(() => isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.headphones,
            color: Colors.blue.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            "Review your recording",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isPlaying ? Colors.red.shade500 : Colors.blue.shade500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPlaying ? Colors.red : Colors.blue).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 32,
                    onPressed: isPlaying ? _stop : _play,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Listen to your recording to ensure it captured correctly before submitting.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            "Submit",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
