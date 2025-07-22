import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'voice_viewmodel.dart';

class VoiceView extends StatefulWidget {
  const VoiceView({Key? key}) : super(key: key);

  @override
  State<VoiceView> createState() => _VoiceViewState();
}

class _VoiceViewState extends State<VoiceView> with TickerProviderStateMixin {
  late VoiceViewModel _viewModel;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VoiceViewModel>.reactive(
      viewModelBuilder: () {
        final vm = VoiceViewModel();
        vm.setContext(context);
        vm.init(this);
        _viewModel = vm;
        return vm;
      },
      builder: (context, model, child) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
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
                          model.isRecording
                              ? 'Listening...'
                              : model.isProcessing
                              ? 'Processing...'
                              : 'Tap to record a reminder',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: model.isProcessing
                              ? null
                              : (model.isRecording
                              ? model.stopRecording
                              : model.startRecording),
                          child: AnimatedBuilder(
                            animation: model.pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: model.isRecording
                                    ? model.pulseAnimation.value
                                    : 1.0,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: model.isRecording
                                          ? [Colors.red.shade400, Colors.red.shade800]
                                          : model.isProcessing
                                          ? [Colors.orange.shade400, Colors.orange.shade800]
                                          : [Colors.blue.shade300, Colors.blue.shade900],
                                    ),
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (model.isRecording
                                            ? Colors.red
                                            : Colors.blue)
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    model.isRecording
                                        ? Icons.stop
                                        : model.isProcessing
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
                        if (model.isRecording) ...[
                          const SizedBox(height: 30),
                          AnimatedBuilder(
                            animation: model.waveAnimation,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Container(
                                    width: 4,
                                    height: 20 +
                                        (30 *
                                            model.waveAnimation.value *
                                            (index % 2 == 0 ? 1 : 0.5)),
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
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
                        const SizedBox(height: 40),
                        Text(
                          model.isRecording
                              ? 'Recording in progress...'
                              : model.isProcessing
                              ? 'Converting speech to text...'
                              : 'Press and hold to record',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Try saying: "Remind me to buy groceries at 6 PM"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
      ),
    );
  }
}
