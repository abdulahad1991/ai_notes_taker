import 'dart:io';
import 'package:ai_notes_taker/ui/views/voice/viewmodel/voice_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../../../shared/playback_confirmation_dialog.dart';
import '../../../shared/processing_dialog.dart';
import 'viewmodel/home_listing_viewmodel.dart';

// Voice Recording Screen (Updated)
class VoiceView extends StatefulWidget {
  final bool isReminder;

  VoiceView({Key? key, required this.isReminder}) : super(key: key);

  @override
  _VoiceViewState createState() => _VoiceViewState();
}

class _VoiceViewState extends State<VoiceView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool isRecording = false;
  bool isProcessing = false;
  bool showRemindersList = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      showRemindersList = false;
    });
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void stopRecording() async {
    setState(() {
      isRecording = false;
      isProcessing = true;
    });
    _pulseController.stop();
    _waveController.stop();

    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessing = false;
      showRemindersList = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VoiceViewmodel>.reactive(
        viewModelBuilder: () =>
            VoiceViewmodel(context, widget.isReminder)..init(),
        builder: (context, model, child) {
          bool isRecording = model.isRecording;
          bool isProcessing = model.isProcessing;

          // Animation controls in View
          void startRecording() {
            model.startRecording();
            _pulseController.repeat(reverse: true);
            _waveController.repeat();
          }

          void stopRecording(File file) async {
            model.isProcessing = true;
            model.isRecording = false;
            _pulseController.stop();
            _waveController.stop();
            await model.stopRecordingAndProcess(file: file);
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isRecording
                        ? 'Listening...'
                        : isProcessing
                            ? 'Processing...'
                            : model.showTitleField && !widget.isReminder
                                ? 'Add a title for your note'
                                : 'Tap to record',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Title field for notes (not reminders) after recording
                  if (model.showTitleField && !widget.isReminder) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: model.titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter title (optional)',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            model.showTitleField = false;
                            model.titleController.clear();
                            model.currentRecordingFile = null;
                            model.rebuildUi();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // Process the note with title
                            model.showTitleField = false;
                            model.rebuildUi();
                            
                            // Show processing dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const ProcessingDialog(),
                            );
                            
                            // Process the recording
                            if (model.currentRecordingFile != null) {
                              stopRecording(model.currentRecordingFile!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save Note'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Recording Button
                  if (!model.showTitleField)
                    GestureDetector(
                    onTap: isProcessing
                        ? null
                        : (isRecording
                            ? () async {
                                File file = await model.stopAndGetAudioBytes();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) =>
                                      PlaybackConfirmationDialog(
                                    audioFile: file,
                                    onConfirm: () async {
                                      Navigator.of(context).pop();
                                      if (!widget.isReminder) {
                                        // Store the file and show title field for notes
                                        model.currentRecordingFile = file;
                                        model.showTitleField = true;
                                        model.rebuildUi();
                                      } else {
                                        // Show processing dialog for reminders
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const ProcessingDialog(),
                                        );
                                        stopRecording(file);
                                      }
                                    },
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              }
                            : startRecording),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isRecording ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isRecording
                                  ? Colors.red.shade500
                                  : isProcessing
                                      ? Colors.orange.shade500
                                      : Color(0xFF667eea),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isRecording
                                          ? Colors.red
                                          : isProcessing
                                              ? Colors.orange
                                              : Color(0xFF667eea))
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording
                                  ? Icons.stop
                                  : isProcessing
                                      ? Icons.hourglass_empty
                                      : Icons.mic,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (isRecording) ...[
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Container(
                              width: 4,
                              height: 20 +
                                  (30 *
                                      _waveAnimation.value *
                                      (index % 2 == 0 ? 1 : 0.5)),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 40),
                  Text(
                    isRecording
                        ? 'Recording in progress...'
                        : isProcessing
                            ? 'Converting speech to text...'
                            : 'Tap to start recording',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 60),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Try saying: "Remind me to buy groceries at 6 PM"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    // return;
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade500;
      case Priority.medium:
        return Colors.orange.shade500;
      case Priority.low:
        return Colors.green.shade500;
    }
  }
}

// Simple Note Creation Screen
class NoteCreationScreen extends StatefulWidget {
  @override
  _NoteCreationScreenState createState() => _NoteCreationScreenState();
}

class _NoteCreationScreenState extends State<NoteCreationScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty ||
                  _contentController.text.isNotEmpty) {
                final note = Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    content: _contentController.text,
                    createdAt: DateTime.now().toString(),
                    isReminder: false);
                Navigator.pop(context, note);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
enum Priority { high, medium, low }
