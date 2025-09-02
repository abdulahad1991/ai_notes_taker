
import 'package:ai_notes_taker/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stacked/stacked.dart';

import '../../../services/data_service.dart';
import '../../../shared/functions.dart';
import 'viewmodel/home_listing_viewmodel.dart';
import 'search_view.dart';

class VoiceNewView extends StatefulWidget {
  const VoiceNewView({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<VoiceNewView>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  // Tab controller and Page controller for swipe functionality
  late TabController _tabController;
  late PageController _pageController;

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
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _fabController.dispose();
    _tabController.dispose();
    _pageController.dispose();
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

  // Handle tab selection and sync with page view
  void _onTabSelected(int index, HomeListingViewmodel model) {
    model.setSelectedTabIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Handle page view changes and sync with tab controller
  void _onPageChanged(int index, HomeListingViewmodel model) {
    model.setSelectedTabIndex(index);
    if (_tabController.index != index) {
      _tabController.animateTo(index);
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
              actions: [
                IconButton(
                  onPressed: () => _openSearchView(model),
                  icon: Icon(
                    Icons.search,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => model.logout(),
                  icon: Icon(
                    Icons.logout,
                    color: Colors.grey[800],
                  ),
                ),
              ],
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
                      onTap: (index) => _onTabSelected(index, model),
                      indicator: BoxDecoration(
                        color: AppColors.primary,
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
            body: RefreshIndicator(
              onRefresh: () async {
                await model.fetchData();
              },
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: Container(
                color: const Color(0xFFF8F9FA),
                child: model.isBusy
                    ? _buildLoadingState()
                    : PageView(
                        controller: _pageController,
                        onPageChanged: (index) => _onPageChanged(index, model),
                        children: [
                          // Notes page (index 0)
                          _buildPageContent(
                            model.notes,
                            columnCount,
                            responsivePadding,
                            gridSpacing,
                            model,
                            screenWidth,
                            0, // Notes tab
                          ),
                          // Reminders page (index 1)
                          _buildPageContent(
                            model.reminders,
                            columnCount,
                            responsivePadding,
                            gridSpacing,
                            model,
                            screenWidth,
                            1, // Reminders tab
                          ),
                        ],
                      ),
              ),
            ),
            floatingActionButton: _buildSpeedDial(model),
          );
        });
  }


  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildPageContent(
    List<dynamic> items,
    int columnCount,
    EdgeInsets padding,
    double spacing,
    HomeListingViewmodel model,
    double screenWidth,
    int tabIndex,
  ) {
    final isEmpty = items.isEmpty;
    
    if (isEmpty) {
      return _buildEmptyState(screenWidth, model, tabIndex);
    }
    
    return _buildNotesGrid(items, columnCount, padding, spacing, model);
  }

  Widget _buildEmptyState(double screenWidth, HomeListingViewmodel model, [int? tabIndex]) {
    final currentTab = tabIndex ?? model.selectedTabIndex;
    String emptyMessage = currentTab == 0
        ? 'No notes yet'
        : 'No reminder notes yet';
    String emptySubMessage = currentTab == 0
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Icon(
                currentTab == 0 ? Icons.lightbulb_outline : Icons.notifications_outlined,
                size: iconSize * 0.5,
                color: AppColors.primary,
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
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            model.editNote(note);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 13 : 16),
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
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
                            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 17),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
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
                          onTap: () => model.togglePinNote(note),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              size: isSmallScreen ? 16 : 18,
                              color: note.isPinned ? AppColors.red : Colors.grey[600],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          // onTap: () => model.togglePinNote(note),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.share,
                              size: isSmallScreen ? 15 : 17,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (note.title.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 6 : 10),
                  Text(
                    note.content,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : (isMediumScreen ? 13 : 15),
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: isSmallScreen ? 2 : 3,
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
            padding: EdgeInsets.all(isSmallScreen ? 13 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 17),
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
                        /*InkWell(
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
                        ),*/
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          // onTap: () => model.togglePinNote(note),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            child: Icon(
                              Icons.share,
                              size: isSmallScreen ? 15 : 17,
                              color: AppColors.grey,
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
                              size: isSmallScreen ? 15 : 17,
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
                            formatScheduledTime(reminder.runtime),
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

  void _openSearchView(HomeListingViewmodel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchView(model: model),
      ),
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
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