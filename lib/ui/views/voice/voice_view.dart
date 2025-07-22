import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Main Screen with Google Keep-like layout
/*
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _isFabOpen = false;

  List<Note> notes = [];
  List<Reminder> reminders = [];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
    });
    if (_isFabOpen) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  void _addNote() {
    _toggleFab();
    // Navigate to note creation screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteCreationScreen()),
    ).then((note) {
      if (note != null) {
        setState(() {
          notes.add(note);
        });
      }
    });
  }

  void _addReminder() {
    _toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceView()),
    ).then((reminder) {
      if (reminder != null) {
        setState(() {
          reminders.add(reminder);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = notes.isEmpty && reminders.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isEmpty
          ? _buildEmptyState()
          : _buildNotesGrid(),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Notes you add appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    List<dynamic> allItems = [...notes, ...reminders];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];
          if (item is Note) {
            return _buildNoteCard(item);
          } else if (item is Reminder) {
            return _buildReminderCard(item);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Edit note
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Edit reminder
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reminder.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (reminder.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  reminder.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reminder.date} at ${reminder.time}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isFabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleFab,
              child: Container(
                color: Colors.black26,
              ),
            ),
          ),
        // Speed dial options
        if (_isFabOpen) ...[
          Positioned(
            bottom: 140,
            right: 0,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: 'reminder',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _addReminder,
                child: Icon(
                  Icons.mic,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 105,
            right: 56,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 0,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: 'note',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _addNote,
                child: Icon(
                  Icons.edit,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 45,
            right: 56,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Note',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
        // Main FAB
        FloatingActionButton(
          onPressed: _toggleFab,
          backgroundColor: Colors.white,
          child: AnimatedRotation(
            turns: _isFabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
*/

// Voice Recording Screen (Updated)
class VoiceView extends StatefulWidget {
  const VoiceView({Key? key}) : super(key: key);

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

  List<Reminder> reminders = [
    Reminder(
      id: 1,
      title: 'Call mom',
      description: 'Weekly check-in call',
      time: '3:00 PM',
      date: 'Today',
      isCompleted: false,
      priority: Priority.high,
    ),
    Reminder(
      id: 2,
      title: 'Buy groceries',
      description: 'Milk, bread, eggs, fruits',
      time: '6:00 PM',
      date: 'Today',
      isCompleted: false,
      priority: Priority.medium,
    ),
    Reminder(
      id: 3,
      title: 'Team meeting',
      description: 'Monthly team sync',
      time: '10:00 AM',
      date: 'Tomorrow',
      isCompleted: false,
      priority: Priority.high,
    ),
  ];

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
    if (showRemindersList) {
      return _buildRemindersListScreen();
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
                  : 'Tap to record',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),

            // Recording Button
            GestureDetector(
              onTap: isProcessing
                  ? null
                  : (isRecording ? stopRecording : startRecording),
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
                            : Colors.blue.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording
                                ? Colors.red
                                : isProcessing
                                ? Colors.orange
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
  }

  Widget _buildRemindersListScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 1,
          mainAxisSpacing: 12,
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            return _buildSimpleReminderCard(reminders[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSimpleReminderCard(Reminder reminder) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPriorityColor(reminder.priority).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      reminder.isCompleted = !reminder.isCompleted;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: reminder.isCompleted
                          ? Colors.green.shade500
                          : Colors.transparent,
                      border: Border.all(
                        color: reminder.isCompleted
                            ? Colors.green.shade500
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: reminder.isCompleted
                        ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: reminder.isCompleted
                          ? Colors.grey.shade500
                          : Colors.black87,
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            if (reminder.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  reminder.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reminder.date} at ${reminder.time}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(reminder.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reminder.priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(reminder.priority),
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
              if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
                final note = Note(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: _titleController.text,
                  content: _contentController.text,
                  createdAt: DateTime.now(),
                );
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

class Note {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

class Reminder {
  final int id;
  final String title;
  final String description;
  final String time;
  final String date;
  bool isCompleted;
  final Priority priority;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.isCompleted,
    required this.priority,
  });
}