import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PlaybackConfirmationDialog extends StatefulWidget {
  final File audioFile;
  final Function(String?) onConfirm;
  final VoidCallback onCancel;
  final bool isReminder;

  const PlaybackConfirmationDialog({
    required this.audioFile,
    required this.onConfirm,
    required this.onCancel,
    this.isReminder = true,
    Key? key,
  }) : super(key: key);

  @override
  State<PlaybackConfirmationDialog> createState() =>
      _PlaybackConfirmationDialogState();
}

class _PlaybackConfirmationDialogState extends State<PlaybackConfirmationDialog> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final TextEditingController _titleController = TextEditingController();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    _titleController.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      title: Row(
        children: [
          Icon(
            Icons.headphones,
            color: Colors.blue.shade600,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Review your recording",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenWidth * 0.8 : 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                      iconSize: isSmallScreen ? 24 : 32,
                      onPressed: isPlaying ? _stop : _play,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            if (!widget.isReminder) ...[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter note title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade600),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  hintStyle: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                maxLines: 1,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],
            Text(
              "Listen to your recording to ensure it captured correctly before submitting.",
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20, 
              vertical: isSmallScreen ? 10 : 12
            ),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(_titleController.text.trim().isEmpty ? null : _titleController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 24, 
              vertical: isSmallScreen ? 10 : 12
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            "Submit",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
