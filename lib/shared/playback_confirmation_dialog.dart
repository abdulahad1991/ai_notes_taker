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
      title: Text("Review your recording"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            iconSize: 48,
            onPressed: isPlaying ? _stop : _play,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: widget.onConfirm,
          child: Text("Submit"),
        ),
      ],
    );
  }
}
