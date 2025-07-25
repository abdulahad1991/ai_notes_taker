import 'package:ai_notes_taker/ui/views/voice/voice_new_viewmodel.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stacked/stacked.dart';

class VoiceNewView extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<VoiceNewView>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VoiceNewViewmodel>.reactive(
        viewModelBuilder: () => VoiceNewViewmodel(context)..init(),
        builder: (context, model, child) {
          bool isEmpty = model.notes.isEmpty && model.reminders.isEmpty;
          if (model.isFabOpen) {
            _fabController.forward();
          } else {
            _fabController.reverse();
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: isEmpty ? _buildEmptyState() : _buildNotesGrid(model),
            floatingActionButton: _buildSpeedDial(model),
          );
        });
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

  Widget _buildNotesGrid(VoiceNewViewmodel model) {
    List<dynamic> allItems = [...model.notes, ...model.reminders];

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

  Widget _buildSpeedDial(VoiceNewViewmodel model) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        // Overlay
        if (model.isFabOpen)
          Positioned(
            right: 0,
            bottom: 140,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: 'reminder',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: model.addReminder,
                child: Icon(Icons.mic, color: Colors.red.shade600),
              ),
            ),
          ),
        if (model.isFabOpen)
          Positioned(
            right: 50,
            bottom: 150,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        if (model.isFabOpen)
          Positioned(
            right: 0,
            bottom: 80,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: 'note',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: model.addNote,
                child: Icon(Icons.edit, color: Colors.blue.shade600),
              ),
            ),
          ),
        if (model.isFabOpen)
          Positioned(
            right: 50,
            bottom: 90,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        // Main FAB (always on top)
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
            onPressed: model.toggleFab,
            backgroundColor: Colors.white,
            child: AnimatedRotation(
              turns: model.isFabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                model.isFabOpen ? Icons.close : Icons.add,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
