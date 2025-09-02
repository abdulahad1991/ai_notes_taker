import 'package:stacked/stacked.dart';

class SearchViewModel extends ReactiveViewModel {
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  List<dynamic> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;

  void initializeSearch(List<dynamic> initialItems) {
    _searchResults = List.from(initialItems);
    _hasSearched = false;
    notifyListeners();
  }

  Future<void> performSearch(String query, List<dynamic> allItems) async {
    if (query.isEmpty) {
      _searchResults = List.from(allItems);
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Filter locally for now
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
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearSearch(List<dynamic> allItems) {
    _searchResults = List.from(allItems);
    _hasSearched = false;
    notifyListeners();
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