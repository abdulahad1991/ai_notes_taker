import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/data_service.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  _RemindersListScreenState createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _headerController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  List<Reminder> reminders = [

  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              SlideTransition(
                position: _headerSlideAnimation,
                child: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: _buildAnimatedHeader(),
                ),
              ),
              // Staggered Reminders List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: MasonryGridView.count(
                      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        return _StaggeredAnimatedReminderCard(
                          key: ValueKey(reminders[index].id),
                          reminder: reminders[index],
                          onDelete: () {
                            setState(() {
                              reminders.removeAt(index);
                            });
                          },
                          onOptions: () {
                            _showReminderOptions(reminders[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Reminders',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay organized, stay ahead',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                '${reminders.where((r) => !r.isCompleted).length}',
                'Active',
                Colors.orange.shade400,
                Icons.schedule,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                '${reminders.where((r) => r.isCompleted).length}',
                'Complete',
                Colors.green.shade400,
                Icons.check_circle,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                '${reminders.where((r) => r.priority == Priority.high).length}',
                'High Priority',
                Colors.red.shade400,
                Icons.priority_high,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderOptions(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit, color: Colors.blue.shade600),
                      ),
                      title: const Text(
                        'Edit Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Add edit functionality
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete, color: Colors.red.shade600),
                      ),
                      title: const Text(
                        'Delete Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          reminders.removeWhere((r) => r.id == reminder.id);
                        });
                        HapticFeedback.mediumImpact();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaggeredAnimatedReminderCard extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onOptions;

  const _StaggeredAnimatedReminderCard({
    Key? key,
    required this.reminder,
    required this.onDelete,
    required this.onOptions,
  }) : super(key: key);

  @override
  State<_StaggeredAnimatedReminderCard> createState() =>
      _StaggeredAnimatedReminderCardState();
}

class _StaggeredAnimatedReminderCardState
    extends State<_StaggeredAnimatedReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _offset = Tween<Offset>(begin: Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Card height is dynamic for stagger effect
    final dynamicHeight = 180 + (widget.reminder.title.length * 2.5).toInt();
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: SizedBox(
          child: _buildReminderCard(widget.reminder, widget.onOptions),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, VoidCallback onOptions) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: reminder.isCompleted
              ? LinearGradient(
            colors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
          )
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          border: Border.all(
            color: _getPriorityColor(reminder.priority).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // Increased size
          child: IntrinsicHeight( // This helps with consistent heights
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important: prevents expansion
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          reminder.isCompleted = !reminder.isCompleted;
                        });
                        HapticFeedback.mediumImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36, // Increased size
                        height: 36,
                        decoration: BoxDecoration(
                          color: reminder.isCompleted
                              ? Colors.green.shade500
                              : Colors.transparent,
                          border: Border.all(
                            color: reminder.isCompleted
                                ? Colors.green.shade500
                                : Colors.grey.shade400,
                            width: 3, // Restored original
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: reminder.isCompleted
                              ? [
                            BoxShadow(
                              color: Colors.green.shade200,
                              blurRadius: 8, // Reduced
                              offset: const Offset(0, 2), // Reduced
                            ),
                          ]
                              : [],
                        ),
                        child: reminder.isCompleted
                            ? const Icon(
                          Icons.check,
                          size: 24, // Increased size
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                    IconButton(
                      onPressed: onOptions,
                      icon: Icon(
                        Icons.more_vert,
                        size: 24, // Increased size
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Important
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 20, // Increased title size
                          fontWeight: FontWeight.w700,
                          color: reminder.isCompleted
                              ? Colors.grey.shade500
                              : Colors.grey.shade800,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        child: Text(
                          reminder.title,
                          maxLines: 2, // Prevent overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (reminder.description.isNotEmpty) ...[
                        const SizedBox(height: 8), // Increased spacing
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 18, // Increased size
                            color: reminder.isCompleted
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          child: Text(
                            reminder.description,
                            maxLines: 2, // Prevent overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12), // Increased spacing
                      // Use Wrap instead of Row to handle overflow
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // Increased
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(18), // Increased
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 18, // Increased size
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  reminder.time,
                                  style: TextStyle(
                                    fontSize: 16, // Increased size
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // Increased
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(18), // Increased
                            ),
                            child: Text(
                              reminder.date,
                              style: TextStyle(
                                fontSize: 12, // Reduced from 13
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _buildAnimatedPriorityChip(reminder.priority),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildAnimatedPriorityChip(Priority priority) {
    Color color = _getPriorityColor(priority);
    String text;
    switch (priority) {
      case Priority.high:
        text = 'High';
        break;
      case Priority.medium:
        text = 'Medium';
        break;
      case Priority.low:
        text = 'Low';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Models ---
/*
enum Priority { high, medium, low }

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
}*/
