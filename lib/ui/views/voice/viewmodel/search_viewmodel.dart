import 'dart:async';
import 'package:stacked/stacked.dart';

import '../../../../app/app.locator.dart';
import '../../../../models/response/notes_response.dart';
import '../../../../services/api_service.dart';
import '../../../../services/data_service.dart';

class SearchViewModel extends ReactiveViewModel {
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;
  
  final ApiService _apiService = locator<ApiService>();
  static const int minSearchLength = 3;
  static const Duration debounceDuration = Duration(milliseconds: 500);

  List<dynamic> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;

  void initializeSearch(List<dynamic> initialItems) {
    _searchResults = List.from(initialItems);
    _hasSearched = false;
    notifyListeners();
  }

  Future<void> performSearch(String query, List<dynamic> allItems) async {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      _searchResults = List.from(allItems);
      _hasSearched = false;
      _isSearching = false;
      notifyListeners();
      return;
    }

    // If query is less than minimum length, perform local filtering
    /*if (query.length < minSearchLength) {
      _performLocalSearch(query, allItems);
      return;
    }*/

    // Set searching state immediately
    _isSearching = true;
    _hasSearched = true;
    searchResults.clear();
    notifyListeners();

    // Start debounce timer
    _debounceTimer = Timer(debounceDuration, () {
      _performAPISearch(query, allItems);
    });
  }

  void _performLocalSearch(String query, List<dynamic> allItems) {
    _hasSearched = true;
    _isSearching = false;
    
    final filteredResults = allItems.where((item) {
      final searchLower = query.toLowerCase();
      
      if (item.runtimeType.toString().contains('Note')) {
        // Handle Note type
        final title = _getProperty(item, 'title') ?? '';
        final content = _getProperty(item, 'content') ?? '';
        return title.toLowerCase().contains(searchLower) ||
               content.toLowerCase().contains(searchLower);
      } else if (item.runtimeType.toString().contains('Reminder')) {
        // Handle Reminder type
        final title = _getProperty(item, 'title') ?? '';
        final description = _getProperty(item, 'description') ?? '';
        return title.toLowerCase().contains(searchLower) ||
               description.toLowerCase().contains(searchLower);
      }
      return false;
    }).toList();

    _searchResults = filteredResults;
    notifyListeners();
  }

  Future<void> _performAPISearch(String query, List<dynamic> allItems) async {
    try {
      // Call the search API
      final response = await _apiService.searchNotes(query: query, page: 0, limit: 40);
      
      if (response is NotesResponse && response.data != null) {
        // Convert API response to local Note objects
        final List<Note> apiNotes = response.data!.map((apiNote) {
          return Note(
            id: apiNote.sId ?? '',
            title: apiNote.title ?? '',
            content: apiNote.text ?? '',
            createdAt: apiNote.createdAt ?? '',
            isReminder: false,
            isPinned: apiNote.is_pin ?? false,
          );
        }).toList();
        
        _searchResults = apiNotes;
      } else {
        // Fallback to local search if API fails
        _performLocalSearch(query, allItems);
        return;
      }
      
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      print('API search failed: $e');
      // Fallback to local search
      _performLocalSearch(query, allItems);
    }
  }

  void clearSearch(List<dynamic> allItems) {
    _debounceTimer?.cancel();
    _searchResults = List.from(allItems);
    _hasSearched = false;
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Helper method to get property value using reflection-like approach
  dynamic _getProperty(dynamic object, String propertyName) {
    try {
      switch (propertyName) {
        case 'title':
          return object.title;
        case 'content':
          return object.content;
        case 'description':
          return object.description;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}