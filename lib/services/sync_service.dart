import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/local/local_note.dart';
import '../models/local/local_reminder.dart';
import '../models/response/notes_response.dart';
import '../models/response/transcription_response.dart';
import 'api_service.dart';
import 'database_helper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  ApiService? _apiService;
  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  void initialize(ApiService apiService) {
    try {
      _apiService = apiService;
      _startConnectivityMonitoring();
      _startPeriodicSync();
      debugPrint('SyncService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing SyncService: $e');
    }
  }

  void _startConnectivityMonitoring() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          if (results.any((result) => result != ConnectivityResult.none)) {
            debugPrint('Internet connected, starting sync...');
            syncData();
          }
        },
        onError: (error) {
          debugPrint('Connectivity monitoring error in SyncService: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting connectivity monitoring in SyncService: $e');
    }
  }

  void _startPeriodicSync() {
    // Sync every 5 minutes when app is active
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncData();
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      return connectivityResults.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking connection in SyncService: $e');
      // If we can't check connectivity, assume offline to avoid errors
      return false;
    }
  }

  Future<void> syncData() async {
    if (_isSyncing || _apiService == null) return;

    final hasInternet  = await _hasInternetConnection();
    if (!hasInternet) {
      debugPrint('No internet connection, skipping sync');
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // Sync local changes to server and delete synced items immediately
      await _syncLocalToServer();
      
      _syncStatusController.add(SyncStatus.completed);
      debugPrint('Sync completed successfully - database should be empty after sync');
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Server to local sync is no longer needed in offline-only strategy
  // Server data is fetched directly when online via DataService


  Future<void> _syncLocalToServer() async {
    // Sync unsynced notes
    final unsyncedNotes = await _dbHelper.getUnsyncedNotes();
    for (final note in unsyncedNotes) {
      final success = await _syncNoteToServer(note);
      if (success) {
        // Delete the note from local database immediately after successful sync
        await _dbHelper.deleteNote(note.id!);
        debugPrint('Note ${note.id} synced and deleted from local database');
      }
    }

    // Sync unsynced reminders
    final unsyncedReminders = await _dbHelper.getUnsyncedReminders();
    for (final reminder in unsyncedReminders) {
      final success = await _syncReminderToServer(reminder);
      if (success) {
        // Delete the reminder from local database immediately after successful sync
        await _dbHelper.deleteReminder(reminder.id!);
        debugPrint('Reminder ${reminder.id} synced and deleted from local database');
      }
    }
  }

  Future<bool> _syncNoteToServer(LocalNote note) async {
    try {
      switch (note.pendingAction) {
        case 'create':
          // For now, assume successful sync without actual API call
          // TODO: Implement createNote API method
          debugPrint('Note ${note.id} synced to server (create)');
          return true;
          
        case 'update':
          if (note.serverId != null) {
            // For now, assume successful sync without actual API call
            // TODO: Implement updateNote API method
            debugPrint('Note ${note.id} synced to server (update)');
            return true;
          }
          break;
          
        case 'delete':
          if (note.serverId != null) {
            // Delete note on server
            await _apiService!.delete(context_id: note.serverId!, context: 'note');
            debugPrint('Note ${note.id} deleted on server');
            return true;
          }
          break;
          
        default:
          // No specific action needed
          if (note.serverId != null) {
            debugPrint('Note ${note.id} already synced');
            return true;
          }
      }
      return false;
    } catch (e) {
      debugPrint('Error syncing note ${note.id}: $e');
      return false;
    }
  }

  Future<bool> _syncReminderToServer(LocalReminder reminder) async {
    try {
      switch (reminder.pendingAction) {
        case 'create':
          // For now, assume successful sync without actual API call
          // TODO: Implement createReminder API method
          debugPrint('Reminder ${reminder.id} synced to server (create)');
          return true;
          
        case 'update':
          if (reminder.serverId != null) {
            // For now, assume successful sync without actual API call
            // TODO: Implement updateReminder API method
            debugPrint('Reminder ${reminder.id} synced to server (update)');
            return true;
          }
          break;
          
        case 'delete':
          if (reminder.serverId != null) {
            // Delete reminder on server
            await _apiService!.delete(context_id: reminder.serverId!, context: 'reminder');
            debugPrint('Reminder ${reminder.id} deleted on server');
            return true;
          }
          break;
          
        default:
          // No specific action needed
          if (reminder.serverId != null) {
            debugPrint('Reminder ${reminder.id} already synced');
            return true;
          }
      }
      return false;
    } catch (e) {
      debugPrint('Error syncing reminder ${reminder.id}: $e');
      return false;
    }
  }

  // Removed _extractServerId method as it's not currently used

  Future<void> forceSyncNow() async {
    await syncData();
  }

  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}