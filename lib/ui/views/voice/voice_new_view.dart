
import 'package:ai_notes_taker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stacked/stacked.dart';

import '../../../shared/functions.dart';
import 'viewmodel/home_listing_viewmodel.dart';

class VoiceNewView extends StatefulWidget {
  const VoiceNewView({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<VoiceNewView>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  // Tab controller
  late TabController _tabController;

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

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _fabController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Get responsive column count based on screen width - keeping staggered layout
  int _getColumnCount(double width) {
    if (width < 500) {
      return 2; // Two columns for small phones - maintains staggered look
    } else if (width < 800) {
      return 2; // Two columns for regular phones and small tablets
    } else if (width < 1200) {
      return 3; // Three columns for large tablets
    } else {
      return 4; // Four columns for desktop
    }
  }

  // Get responsive padding and spacing based on screen width
  EdgeInsets _getResponsivePadding(double width) {
    if (width < 500) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (width < 800) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  // Get responsive spacing for grid
  double _getGridSpacing(double width) {
    if (width < 500) {
      return 8; // Smaller spacing for small phones
    } else if (width < 800) {
      return 12; // Standard spacing
    } else {
      return 16; // Larger spacing for tablets/desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(screenWidth);
    final responsivePadding = _getResponsivePadding(screenWidth);
    final gridSpacing = _getGridSpacing(screenWidth);

    return ViewModelBuilder<HomeListingViewmodel>.reactive(
        viewModelBuilder: () => HomeListingViewmodel(context)..init(),
        builder: (context, model, child) {
          List<dynamic> filteredItems = model.getFilteredItems();
          bool isEmpty = filteredItems.isEmpty;

          if (_tabController.index != model.selectedTabIndex) {
            _tabController.animateTo(model.selectedTabIndex);
          }

          if (model.isFabOpen) {
            _fabController.forward();
          } else {
            _fabController.reverse();
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFF8F9FA),
              elevation: 0,
              title: Text(
                "Voice Pad",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth < 600 ? 20 : 24,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 600 ? 16.0 : 24.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    height: 44,
                    constraints: BoxConstraints(
                      maxWidth: screenWidth < 600 ? double.infinity : 400,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) => model.setSelectedTabIndex(index),
                      indicator: BoxDecoration(
                        color: const Color(0xFF667eea),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs:  [
                        Tab(text: 'Notes'),
                        Tab(text: 'Reminder'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              color: const Color(0xFFF8F9FA),
              child: isEmpty
                  ? _buildEmptyState(screenWidth, model)
                  : _buildNotesGrid(filteredItems,
                  columnCount, responsivePadding, gridSpacing,model),
            ),
            floatingActionButton: _buildSpeedDial(model),
          );
        });
  }


  Widget _buildEmptyState(double screenWidth, HomeListingViewmodel model) {
    String emptyMessage = model.selectedTabIndex == 0
        ? 'No notes yet'
        : 'No reminder notes yet';
    String emptySubMessage = model.selectedTabIndex == 0
        ? 'Tap the + button to create your first note'
        : 'Tap the + button to create your first reminder';

    // Responsive sizing for empty state
    double iconSize = screenWidth < 600 ? 80 : 120;
    double titleSize = screenWidth < 600 ? 16 : 18;
    double subtitleSize = screenWidth < 600 ? 12 : 14;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Icon(
                model.selectedTabIndex == 0 ? Icons.lightbulb_outline : Icons.notifications_outlined,
                size: iconSize * 0.5,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: titleSize,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptySubMessage,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<dynamic> items,
      int columnCount,
      EdgeInsets padding,
      double spacing,
      HomeListingViewmodel model) {
    return Padding(
      padding: padding,
      child: MasonryGridView.count(
        crossAxisCount: columnCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is Note) {
            return _buildNoteCard(item, model);
          } else if (item is Reminder) {
            return _buildReminderCard(item, model);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note, HomeListingViewmodel model) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    final isMediumScreen = screenWidth < 800;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF667eea).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // _editNote(note);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and action buttons
                Row(
                  children: [
                    if (note.title.isNotEmpty) ...[
                      Container(
                        width: 3,
                        height: isSmallScreen ? 14 : 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : (isMediumScreen ? 14 : 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Text(
                          note.content,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : (isMediumScreen ? 14 : 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => model.editNote(note),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.edit_outlined,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showDeleteConfirmation(note, model),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.delete_outline,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Content
                if (note.title.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 6 : 10),
                  Text(
                    note.content,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 14),
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: isSmallScreen ? 4 : 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder,
      HomeListingViewmodel model) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    final isMediumScreen = screenWidth < 800;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: _getStatusColor(reminder.isCompleted).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            model.editReminder(reminder);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and action buttons
                Row(
                  children: [
                    if (reminder.title.isNotEmpty) ...[
                      Container(
                        width: 3,
                        height: isSmallScreen ? 14 : 18,
                        decoration: BoxDecoration(
                          color: _getStatusColor(reminder.isCompleted),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),
                      Expanded(
                        child: Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : (isMediumScreen ? 14 : 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Text(
                          reminder.description,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : (isMediumScreen ? 14 : 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => model.editReminder(reminder),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.edit_outlined,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showDeleteConfirmation(reminder, model),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.delete_outline,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Status and scheduled time row
                SizedBox(height: isSmallScreen ? 6 : 10),
                Wrap(
                  spacing: isSmallScreen ? 6 : 8,
                  runSpacing: 4,
                  children: [
                    // Status indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reminder.isCompleted).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(reminder.isCompleted).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isSmallScreen ? 3 : 4,
                            height: isSmallScreen ? 3 : 4,
                            decoration: BoxDecoration(
                              color: _getStatusColor(reminder.isCompleted),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Text(
                            _getStatusText(reminder.isCompleted),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(reminder.isCompleted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scheduled time
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: isSmallScreen ? 10 : 12,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: isSmallScreen ? 2 : 3),
                          Text(
                            _formatScheduledTime(reminder.runtime),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Description
                /*if (reminder.title.isNotEmpty && reminder.description.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 6 : 10),
                  Text(
                    reminder.description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 14),
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: isSmallScreen ? 3 : 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for reminder status
  Color _getStatusColor(bool status) {
    if (status) {
      return const Color(0xFF10B981); // Green
    } else {
      return const Color(0xFFF59E0B); // Amber
    }
  }

  String _getStatusText(bool status) {
    if (status) {
      return 'Delivered';
    } else {
      return 'Pending';
    }
  }

  String _formatScheduledTime(String scheduledTimeString) {
    try {
      final scheduledTime = parseUtc(scheduledTimeString).toLocal();
      /*final now = DateTime.now();
      final difference = scheduledTime.difference(now);

      if (difference.inDays > 0) {
        if (difference.inDays == 1) {
          return 'Tomorrow ${_formatTime(scheduledTime)}';
        } else if (difference.inDays < 7) {
          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return '${weekdays[scheduledTime.weekday - 1]} ${_formatTime(scheduledTime)}';
        } else {
          return '${scheduledTime.day}/${scheduledTime.month} ${_formatTime(scheduledTime)}';
        }
      } else if (difference.inHours > 0) {
        return 'Today ${_formatTime(scheduledTime)}';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes}m';
      } else if (difference.inMinutes > -60) {
        return 'Late ${difference.inMinutes.abs()}m';
      } else {

      }*/
      return '${_formatTime(scheduledTime)}';
    } catch (e) {
      return scheduledTimeString;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }

  void _showDeleteConfirmation(dynamic item, HomeListingViewmodel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete ${item is Note ? 'Note' : 'Reminder'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this ${item is Note ? 'note' : 'reminder'}?',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (item is Note) {
                  model.deleteNote(item);
                } else if (item is Reminder) {
                  model.deleteReminder(item);
                }
              },
              child:  Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedDial(HomeListingViewmodel model) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        // Voice Note FAB
        if (model.isFabOpen)
          Positioned(
            right: 0,
            bottom: isCompact ? 120 : 140,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  mini: isCompact,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: model.voiceClick,
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: isCompact ? 20 : 24,
                  ),
                ),
              ),
            ),
          ),

        // Voice Note Label
        if (model.isFabOpen)
          Positioned(
            right: isCompact ? 45 : 50,
            bottom: isCompact ? 130 : 150,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Voice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        // Text Note FAB
        if (model.isFabOpen)
          Positioned(
            right: 0,
            bottom: isCompact ? 70 : 80,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  mini: isCompact,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: model.textClick,
                  child: Icon(
                    Icons.text_fields,
                    color: Colors.white,
                    size: isCompact ? 20 : 24,
                  ),
                ),
              ),
            ),
          ),

        if (model.isFabOpen)
          Positioned(
            right: isCompact ? 45 : 50,
            bottom: isCompact ? 80 : 90,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        // Main FAB
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: model.toggleFab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              mini: isCompact,
              child: AnimatedRotation(
                turns: model.isFabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  model.isFabOpen ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: isCompact ? 24 : 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}