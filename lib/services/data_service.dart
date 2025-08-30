import 'package:flutter/material.dart';
import '../models/local/local_note.dart';
import '../models/local/local_reminder.dart';
import '../models/response/notes_response.dart';
import '../models/response/transcription_response.dart';
import '../shared/functions.dart';
import 'api_service.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';

// Priority enum for reminders
enum Priority { high, medium, low }

// Note class for UI
class Note {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final bool isReminder;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isReminder,
    this.isPinned = false,
  });
}

// Reminder class for UI
class Reminder {
  final String id;
  final String title;
  final String description;
  final String time;
  final String date;
  final String runtime;
  bool isCompleted;
  final Priority priority;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.runtime,
    required this.isCompleted,
    required this.priority,
  });
}

/// Data service that implements offline-only local database strategy
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  ApiService? _apiService;
  ConnectivityService? _connectivityService;

  void initialize(ApiService apiService, ConnectivityService connectivityService) {
    _apiService = apiService;
    _connectivityService = connectivityService;
  }

  /// Fetch notes with offline-only strategy
  Future<List<Note>> fetchNotes() async {
    try {
      // Check if we have internet connection
      final hasConnection = _connectivityService?.isConnected ?? false;
      
      if (hasConnection && _apiService != null) {
        debugPrint('Fetching notes from API (online)');
        
        try {
          // Fetch from API directly without storing locally
          final response = await _apiService!.getNotes(0);
          
          if (response != null && response is NotesResponse && response.data != null) {
            List<Note> notes = [];
            for (var item in response.data!) {
              notes.add(Note(
                id: item.sId?.toString() ?? '',
                title: item.title ?? 'N/A',
                content: item.text ?? 'N/A',
                createdAt: item.createdAt ?? '',
                isReminder: false,
                isPinned: (item.is_pin ?? 0) == 1,
              ));
            }
            
            debugPrint('Successfully fetched ${notes.length} notes from API');
            return notes;
          }
        } catch (e) {
          debugPrint('API fetch failed, showing offline notes: $e');
        }
      }
      
      // Show offline notes only (locally created, unsynced)
      debugPrint('Showing offline notes only');
      return await _fetchNotesFromLocal();
      
    } catch (e) {
      debugPrint('Error in fetchNotes: $e');
      return await _fetchNotesFromLocal();
    }
  }

  /// Fetch reminders with offline-only strategy
  Future<List<Reminder>> fetchReminders() async {
    try {
      // Check if we have internet connection
      final hasConnection = _connectivityService?.isConnected ?? false;
      
      if (hasConnection && _apiService != null) {
        debugPrint('Fetching reminders from API (online)');
        
        try {
          // Fetch from API directly without storing locally
          final response = await _apiService!.getReminders(0);
          
          if (response != null && response is TranscriptionResponse && response.data != null) {
            List<Reminder> reminders = [];
            
            for (var item in response.data!) {
              reminders.add(Reminder(
                id: item.sId?.toString() ?? '',
                title: item.title ?? 'N/A',
                description: item.text ?? 'N/A',
                time: formatTime(item.userCurrentDatetime),
                date: item.userCurrentDatetime ?? 'N/A',
                runtime: item.runTime ?? '',
                isCompleted: item.isDelivered ?? false,
                priority: _stringToPriority('medium'),
              ));
            }
            
            debugPrint('Successfully fetched ${reminders.length} reminders from API');
            return reminders;
          }
        } catch (e) {
          debugPrint('API fetch failed, showing offline reminders: $e');
        }
      }
      
      // Show offline reminders only (locally created, unsynced)
      debugPrint('Showing offline reminders only');
      return await _fetchRemindersFromLocal();
      
    } catch (e) {
      debugPrint('Error in fetchReminders: $e');
      return await _fetchRemindersFromLocal();
    }
  }

  Future<List<Note>> _fetchNotesFromLocal() async {
    try {
      final localNotes = await _dbHelper.getAllNotes();
      return localNotes.map((localNote) {
        return Note(
          id: localNote.serverId ?? localNote.id.toString(),
          title: localNote.title,
          content: localNote.content,
          createdAt: localNote.createdAt,
          isReminder: localNote.isReminder,
          isPinned: localNote.isPinned,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching from local storage: $e');
      return [];
    }
  }

  Future<List<Reminder>> _fetchRemindersFromLocal() async {
    try {
      final localReminders = await _dbHelper.getAllReminders();
      return localReminders.map((localReminder) {
        return Reminder(
          id: localReminder.serverId ?? localReminder.id.toString(),
          title: localReminder.title,
          description: localReminder.description,
          time: localReminder.time,
          date: localReminder.date,
          runtime: localReminder.runtime,
          isCompleted: localReminder.isCompleted,
          priority: _stringToPriority(localReminder.priority),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching reminders from local storage: $e');
      return [];
    }
  }

  Priority _stringToPriority(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  /// Add new note (always saved locally, synced when online)
  Future<Note?> addNote({
    required String title,
    required String content,
    bool isReminder = false,
    bool isPinned = false,
  }) async {
    try {
      final localNote = LocalNote(
        title: title,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        isReminder: isReminder,
        isPinned: isPinned,
        isSynced: false,
        pendingAction: 'create',
      );
      
      final noteId = await _dbHelper.insertNote(localNote);
      
      return Note(
        id: noteId.toString(),
        title: title,
        content: content,
        createdAt: localNote.createdAt,
        isReminder: isReminder,
        isPinned: isPinned,
      );
    } catch (e) {
      debugPrint('Error adding note: $e');
      return null;
    }
  }

  /// Add new reminder (always saved locally, synced when online)
  Future<Reminder?> addReminder({
    required String title,
    required String description,
    required String time,
    required String date,
    required String runtime,
    Priority priority = Priority.medium,
  }) async {
    try {
      final localReminder = LocalReminder(
        title: title,
        description: description,
        time: time,
        date: date,
        runtime: runtime,
        isCompleted: false,
        priority: _priorityToString(priority),
        isSynced: false,
        pendingAction: 'create',
      );
      
      final reminderId = await _dbHelper.insertReminder(localReminder);
      
      return Reminder(
        id: reminderId.toString(),
        title: title,
        description: description,
        time: time,
        date: date,
        runtime: runtime,
        isCompleted: false,
        priority: priority,
      );
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      return null;
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'high';
      case Priority.low:
        return 'low';
      default:
        return 'medium';
    }
  }
}