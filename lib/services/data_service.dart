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

  /// Fetch notes with offline-first strategy - save server data to local DB
  Future<List<Note>> fetchNotes() async {
    try {
      // Check if we have internet connection
      final hasConnection = _connectivityService?.isConnected ?? false;
      
      if (hasConnection && _apiService != null) {
        debugPrint('Fetching notes from API and saving to local DB');
        
        try {
          // Fetch from API and save to local database
          final response = await _apiService!.getNotes(0);
          
          if (response != null && response is NotesResponse && response.data != null) {
            // Save server data to local database
            for (var item in response.data!) {
              await saveServerNoteToLocal(item);
            }
            
            debugPrint('Successfully saved ${response.data!.length} notes from server to local DB');
          }
        } catch (e) {
          debugPrint('API fetch failed, showing offline notes: $e');
        }
      }
      
      // Always return data from local database for consistent behavior
      debugPrint('Loading notes from local database');
      return await _fetchNotesFromLocal();
      
    } catch (e) {
      debugPrint('Error in fetchNotes: $e');
      return await _fetchNotesFromLocal();
    }
  }

  /// Fetch reminders with offline-first strategy - save server data to local DB
  Future<List<Reminder>> fetchReminders() async {
    try {
      // Check if we have internet connection
      final hasConnection = _connectivityService?.isConnected ?? false;
      
      if (hasConnection && _apiService != null) {
        debugPrint('Fetching reminders from API and saving to local DB');
        
        try {
          // Fetch from API and save to local database
          final response = await _apiService!.getReminders(0);
          
          if (response != null && response is TranscriptionResponse && response.data != null) {
            // Save server data to local database
            for (var item in response.data!) {
              await saveServerReminderToLocal(item);
            }
            
            debugPrint('Successfully saved ${response.data!.length} reminders from server to local DB');
          }
        } catch (e) {
          debugPrint('API fetch failed, showing offline reminders: $e');
        }
      }
      
      // Always return data from local database for consistent behavior
      debugPrint('Loading reminders from local database');
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

  /// Edit existing note (mark as pending update for sync)
  Future<Note?> editNote({
    required String id,
    required String title,
    required String content,
    bool? isPinned,
  }) async {
    try {
      // Try to parse as local ID first
      final localId = id;
      LocalNote? existingNote;
      
      if (localId != null) {
        existingNote = await _dbHelper.getNoteById(localId);
      } else {
        // It's a server ID
        existingNote = await _dbHelper.getNoteByServerId(id);
      }
      
      if (existingNote != null) {
        final updatedNote = existingNote.copyWith(
          title: title,
          content: content,
          isPinned: isPinned ?? existingNote.isPinned,
          isSynced: false,
          pendingAction: 'update',
        );
        
        await _dbHelper.updateNote(updatedNote);
        
        return Note(
          id: existingNote.serverId ?? existingNote.id.toString(),
          title: title,
          content: content,
          createdAt: existingNote.createdAt,
          isReminder: existingNote.isReminder,
          isPinned: isPinned ?? existingNote.isPinned,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error editing note: $e');
      return null;
    }
  }

  /// Edit existing reminder (mark as pending update for sync)
  Future<Reminder?> editReminder({
    required String id,
    required String title,
    required String description,
    required String time,
    required String date,
    required String runtime,
    Priority priority = Priority.medium,
    bool? isCompleted,
  }) async {
    try {
      // Try to parse as local ID first
      final localId = int.tryParse(id);
      LocalReminder? existingReminder;
      
      if (localId != null) {
        existingReminder = await _dbHelper.getReminderById(localId);
      } else {
        // It's a server ID
        existingReminder = await _dbHelper.getReminderByServerId(id);
      }
      
      if (existingReminder != null) {
        final updatedReminder = existingReminder.copyWith(
          title: title,
          description: description,
          time: time,
          date: date,
          runtime: runtime,
          priority: _priorityToString(priority),
          isCompleted: isCompleted ?? existingReminder.isCompleted,
          isSynced: false,
          pendingAction: 'update',
        );
        
        await _dbHelper.updateReminder(updatedReminder);
        
        return Reminder(
          id: existingReminder.serverId ?? existingReminder.id.toString(),
          title: title,
          description: description,
          time: time,
          date: date,
          runtime: runtime,
          isCompleted: isCompleted ?? existingReminder.isCompleted,
          priority: priority,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error editing reminder: $e');
      return null;
    }
  }

  /// Delete note (mark as pending delete for sync)
  Future<bool> deleteNote(String id) async {
    try {
      // Try to parse as local ID first
      final localId = int.tryParse(id);
      
      if (localId != null) {
        await _dbHelper.deleteNote(localId);
        debugPrint('Note marked for deletion: $localId');
        return true;
      } else {
        // It's a server ID - find local record and mark for deletion
        final existingNote = await _dbHelper.getNoteByServerId(id);
        if (existingNote?.id != null) {
          await _dbHelper.deleteNote(existingNote!.id!);
          debugPrint('Server note marked for deletion: $id');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }

  /// Delete reminder (mark as pending delete for sync)
  Future<bool> deleteReminder(String id) async {
    try {
      // Try to parse as local ID first
      final localId = int.tryParse(id);
      
      if (localId != null) {
        await _dbHelper.deleteReminder(localId);
        debugPrint('Reminder marked for deletion: $localId');
        return true;
      } else {
        // It's a server ID - find local record and mark for deletion
        final existingReminder = await _dbHelper.getReminderByServerId(id);
        if (existingReminder?.id != null) {
          await _dbHelper.deleteReminder(existingReminder!.id!);
          debugPrint('Server reminder marked for deletion: $id');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      return false;
    }
  }

  /// Pin/Unpin note (mark as pending update for sync)
  Future<bool> pinNote(String id, bool isPinned) async {
    try {
      // Try to parse as local ID first
      final localId = id;
      LocalNote? existingNote;
      
      if (localId!=null) {
        existingNote = await _dbHelper.getNoteById(localId);
      } else {
        // It's a server ID
        existingNote = await _dbHelper.getNoteByServerId(id);
      }
      
      if (existingNote != null) {
        final updatedNote = existingNote.copyWith(
          isPinned: isPinned,
          isSynced: false,
          pendingAction: 'update',
        );
        
        await _dbHelper.updateNote(updatedNote);
        debugPrint('Note pin status updated: $id -> $isPinned');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error pinning note: $e');
      return false;
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

  /// Save server note to local database to avoid duplicates
  Future<void> saveServerNoteToLocal(dynamic serverNote) async {
    try {
      final serverId = serverNote.sId?.toString();
      if (serverId == null) return;
      
      // Check if note already exists locally
      final existingNote = await _dbHelper.getNoteByServerId(serverId);
      if (existingNote != null) {
        // Update existing note only if it's not modified locally (isSynced = true)
        if (existingNote.isSynced && existingNote.pendingAction == null) {
          final updatedNote = existingNote.copyWith(
            title: serverNote.title ?? existingNote.title,
            content: serverNote.text ?? existingNote.content,
            isPinned: serverNote.is_pin == true,
            isSynced: true,
            pendingAction: null,
          );
          await _dbHelper.updateNote(updatedNote);
          debugPrint('Updated existing synced note: $serverId');
        } else {
          debugPrint('Skipping update for locally modified note: $serverId');
        }
      } else {
        // Create new local note from server data
        final localNote = LocalNote(
          serverId: serverId,
          title: serverNote.title ?? 'N/A',
          content: serverNote.text ?? 'N/A',
          createdAt: serverNote.createdAt ?? DateTime.now().toIso8601String(),
          isReminder: false,
          isPinned: serverNote.is_pin == true,
          isSynced: true,
          pendingAction: null,
        );
        await _dbHelper.insertNote(localNote);
        debugPrint('Saved new note from server: $serverId');
      }
    } catch (e) {
      debugPrint('Error saving server note to local: $e');
    }
  }

  /// Save server reminder to local database to avoid duplicates  
  Future<void> saveServerReminderToLocal(dynamic serverReminder) async {
    try {
      final serverId = serverReminder.sId?.toString();
      if (serverId == null) return;
      
      // Check if reminder already exists locally
      final existingReminder = await _dbHelper.getReminderByServerId(serverId);
      if (existingReminder != null) {
        // Update existing reminder only if it's not modified locally (isSynced = true)
        if (existingReminder.isSynced && existingReminder.pendingAction == null) {
          final updatedReminder = existingReminder.copyWith(
            title: serverReminder.title ?? existingReminder.title,
            description: serverReminder.text ?? existingReminder.description,
            time: formatTime(serverReminder.userCurrentDatetime) ?? existingReminder.time,
            date: serverReminder.userCurrentDatetime ?? existingReminder.date,
            runtime: serverReminder.runTime ?? existingReminder.runtime,
            isCompleted: serverReminder.isDelivered ?? existingReminder.isCompleted,
            isSynced: true,
            pendingAction: null,
          );
          await _dbHelper.updateReminder(updatedReminder);
          debugPrint('Updated existing synced reminder: $serverId');
        } else {
          debugPrint('Skipping update for locally modified reminder: $serverId');
        }
      } else {
        // Create new local reminder from server data
        final localReminder = LocalReminder(
          serverId: serverId,
          title: serverReminder.title ?? 'N/A',
          description: serverReminder.text ?? 'N/A',
          time: formatTime(serverReminder.userCurrentDatetime) ?? '',
          date: serverReminder.userCurrentDatetime ?? 'N/A',
          runtime: serverReminder.runTime ?? '',
          isCompleted: serverReminder.isDelivered ?? false,
          priority: 'medium',
          isSynced: true,
          pendingAction: null,
        );
        await _dbHelper.insertReminder(localReminder);
        debugPrint('Saved new reminder from server: $serverId');
      }
    } catch (e) {
      debugPrint('Error saving server reminder to local: $e');
    }
  }
}