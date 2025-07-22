import 'dart:io';

import 'package:ai_notes_taker/ui/views/voice/reminders_list.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../shared/app_colors.dart';

class VoiceView extends StatefulWidget {
  const VoiceView({Key? key}) : super(key: key);

  @override
  _VoiceRecordingScreenState createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: Duration(milliseconds: 2000),
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VoiceViewmodel>.reactive(
      viewModelBuilder: () => VoiceViewmodel(context)..init(),
      builder: (context, model, child) {
        // Reflect ViewModel states in your UI
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
          _pulseController.stop();
          _waveController.stop();
          await model.stopRecordingAndProcess(file: file);
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white,
                  AppColors.secondary,
                  AppColors.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isRecording
                                ? 'Listening...'
                                : isProcessing
                                    ? 'Processing...'
                                    : 'Tap to talk',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 40),

                          // Recording Button with Animation
                          GestureDetector(
                            onTap: isProcessing
                                ? null
                                : (isRecording
                                    ? () async {
                                        File file =
                                            await model.stopAndGetAudioBytes();
                                        stopRecording(file);
                                      }
                                    : startRecording),
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      isRecording ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isRecording
                                            ? [
                                                Colors.red.shade400,
                                                Colors.red.shade600
                                              ]
                                            : isProcessing
                                                ? [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600
                                                  ]
                                                : [
                                                    Colors.blue.shade400,
                                                    Colors.blue.shade600
                                                  ],
                                      ),
                                      borderRadius: BorderRadius.circular(60),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isRecording
                                                  ? Colors.red
                                                  : Colors.blue)
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
                            SizedBox(height: 30),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ],

                          SizedBox(height: 40),
                          Text(
                            isRecording
                                ? 'Recording in progress...'
                                : isProcessing
                                    ? 'Converting speech to text...'
                                    : 'Press and hold to talk',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Tips
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
