import 'package:ai_notes_taker/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../services/data_service.dart';
import '../../../shared/functions.dart';
import 'viewmodel/home_listing_viewmodel.dart';

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
  List<dynamic> searchResults = [];
  bool isSearching = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    // Initialize with current notes
    searchResults = widget.model.getFilteredItems();
    
    // Listen to search input changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = widget.model.getFilteredItems();
        hasSearched = false;
      });
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isSearching = true;
      hasSearched = true;
    });

    try {
      // TODO: Call search API when implemented
      await _searchAPI(query);
      
      // For now, filter locally
      final allItems = widget.model.getFilteredItems();
      final filteredResults = allItems.where((item) {
        if (item is Note) {
          return item.title.toLowerCase().contains(query.toLowerCase()) ||
                 item.content.toLowerCase().contains(query.toLowerCase());
        } else if (item is Reminder) {
          return item.title.toLowerCase().contains(query.toLowerCase()) ||
                 item.description.toLowerCase().contains(query.toLowerCase());
        }
        return false;
      }).toList();

      setState(() {
        searchResults = filteredResults;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Search API function (placeholder for future implementation)
  Future<void> _searchAPI(String query) async {
    // TODO: Implement API call
    // Example API call structure:
    // final response = await widget.model.api.searchNotes(query: query);
    // return SearchResponse.fromJson(response.data);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
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

    return Scaffold(
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search notes and reminders...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchResults = widget.model.getFilteredItems();
                          hasSearched = false;
                        });
                      },
                      icon: Icon(Icons.clear, color: Colors.grey[500]),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
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
          if (hasSearched)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${searchResults.length} result${searchResults.length != 1 ? 's' : ''} found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          
          // Search results
          Expanded(
            child: isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                    ),
                  )
                : searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(columnCount),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Icon(
                hasSearched ? Icons.search_off : Icons.search,
                size: iconSize * 0.5,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearched ? 'No results found' : 'Search your notes',
              style: TextStyle(
                fontSize: titleSize,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearched 
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

  Widget _buildSearchResults(int columnCount) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: columnCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final item = searchResults[index];
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
            color: const Color(0xFF667eea).withOpacity(0.1),
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
                          color: const Color(0xFF667eea),
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