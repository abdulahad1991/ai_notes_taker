import 'package:ai_notes_taker/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stacked/stacked.dart';

import '../../../services/data_service.dart';
import '../../../shared/functions.dart';
import 'viewmodel/home_listing_viewmodel.dart';
import 'viewmodel/search_viewmodel.dart';

class SearchView extends StatefulWidget {
  final HomeListingViewmodel model;

  const SearchView({
    super.key,
    required this.model,
  });

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Get responsive column count based on screen width
  int _getColumnCount(double width) {
    if (width < 500) {
      return 2;
    } else if (width < 800) {
      return 2;
    } else if (width < 1200) {
      return 3;
    } else {
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(screenWidth);

    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(),
      onViewModelReady: (model) {
        // Initialize with current notes
        model.initializeSearch(widget.model.getFilteredItems());
        
        // Listen to search input changes
        _searchController.addListener(() {
          final query = _searchController.text.trim();
          model.performSearch(query, widget.model.getFilteredItems());
        });
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey[800],
            ),
          ),
          title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center, // <-- centers text vertically
            decoration: InputDecoration(
              hintText: 'Search notes and reminders...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),

              // Keep icons centered too
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search, color: Colors.grey[500], size: 20),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),

              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                onPressed: () {
                  _searchController.clear();
                  model.clearSearch(widget.model.getFilteredItems());
                  // setState() if needed to refresh suffixIcon visibility
                },
              )
                  : null,
              suffixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),

              border: InputBorder.none,

              // KEY: remove vertical padding so the container height controls layout
              isDense: true,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.0, // optional: keep line height tight
            ),
          ),
        ),
        actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search stats
            if (model.hasSearched)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${model.searchResults.length} result${model.searchResults.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            
            // Search results
            Expanded(
              child: model.isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : model.searchResults.isEmpty
                      ? _buildEmptyState(model)
                      : _buildSearchResults(columnCount, model),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(SearchViewModel model) {
    final screenWidth = MediaQuery.of(context).size.width;
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
                model.hasSearched ? Icons.search_off : Icons.search,
                size: iconSize * 0.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              model.hasSearched ? 'No results found' : 'Search your notes',
              style: TextStyle(
                fontSize: titleSize,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              model.hasSearched 
                  ? 'Try different keywords or check your spelling'
                  : 'Enter keywords to find your notes and reminders',
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

  Widget _buildSearchResults(int columnCount, SearchViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: columnCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: model.searchResults.length,
        itemBuilder: (context, index) {
          final item = model.searchResults[index];
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
            Navigator.pop(context);
            widget.model.editNote(note);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 13 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin,
                        size: isSmallScreen ? 14 : 16,
                        color: AppColors.red,
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

  Widget _buildReminderCard(Reminder reminder) {
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
            Navigator.pop(context);
            widget.model.editReminder(reminder);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 13 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                        reminder.title.isNotEmpty ? reminder.title : reminder.description,
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
                ),
                SizedBox(height: isSmallScreen ? 6 : 10),
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
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool status) {
    if (status) {
      return const Color(0xFF10B981); // Green
    } else {
      return const Color(0xFFF59E0B); // Amber
    }
  }
}