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

  Future<void> syncAllData() async {
    await syncData();
  }

  // Server to local sync is no longer needed in offline-only strategy
  // Server data is fetched directly when online via DataService


  Future<void> _syncLocalToServer() async {
    // Sync unsynced notes
    final unsyncedNotes = await _dbHelper.getUnsyncedNotes();
    for (final note in unsyncedNotes) {
      final syncResult = await _syncNoteToServer(note);
      if (syncResult.success) {
        if (syncResult.serverId != null && note.pendingAction == 'create') {
          // Mark as synced and store server ID for newly created items
          await _dbHelper.markNoteSynced(note.id!, syncResult.serverId);
          debugPrint('Note ${note.id} created and marked as synced with server ID: ${syncResult.serverId}');
        } else {
          // For updates/deletes, mark as synced or delete based on action
          if (note.pendingAction == 'delete') {
            await _dbHelper.permanentlyDeleteNote(note.id!);
            debugPrint('Note ${note.id} deleted on server and removed from local DB');
          } else {
            await _dbHelper.markNoteSynced(note.id!, note.serverId);
            debugPrint('Note ${note.id} updated and marked as synced');
          }
        }
      }
    }

    // Sync unsynced reminders
    final unsyncedReminders = await _dbHelper.getUnsyncedReminders();
    for (final reminder in unsyncedReminders) {
      final syncResult = await _syncReminderToServer(reminder);
      if (syncResult.success) {
        if (syncResult.serverId != null && reminder.pendingAction == 'create') {
          // Mark as synced and store server ID for newly created items
          await _dbHelper.markReminderSynced(reminder.id!, syncResult.serverId);
          debugPrint('Reminder ${reminder.id} created and marked as synced with server ID: ${syncResult.serverId}');
        } else {
          // For updates/deletes, mark as synced or delete based on action
          if (reminder.pendingAction == 'delete') {
            await _dbHelper.permanentlyDeleteReminder(reminder.id!);
            debugPrint('Reminder ${reminder.id} deleted on server and removed from local DB');
          } else {
            await _dbHelper.markReminderSynced(reminder.id!, reminder.serverId);
            debugPrint('Reminder ${reminder.id} updated and marked as synced');
          }
        }
      }
    }
  }

  Future<SyncResult> _syncNoteToServer(LocalNote note) async {
    try {
      switch (note.pendingAction) {
        case 'create':
          final response = await _apiService!.createNoteText(
            title: note.title,
            text: note.content,
          );
          final serverId = response.data?.id?.toString();
          debugPrint('Note ${note.id} created on server with ID: $serverId');
          return SyncResult(success: true, serverId: serverId);
          
        case 'update':
          if (note.serverId != null) {
            await _apiService!.editNoteText(
              id: note.serverId!,
              title: note.title,
              text: note.content,
              is_pin: note.isPinned == true ? 1 : 0,
            );
            debugPrint('Note ${note.id} updated on server');
            return SyncResult(success: true);
          }
          break;
          
        case 'delete':
          if (note.serverId != null) {
            await _apiService!.delete(context_id: note.serverId!, context: 'note');
            debugPrint('Note ${note.id} deleted on server');
            return SyncResult(success: true);
          }
          break;
          
        default:
          if (note.serverId != null) {
            debugPrint('Note ${note.id} already synced');
            return SyncResult(success: true);
          }
      }
      return SyncResult(success: false);
    } catch (e) {
      debugPrint('Error syncing note ${note.id}: $e');
      return SyncResult(success: false);
    }
  }

  Future<SyncResult> _syncReminderToServer(LocalReminder reminder) async {
    try {
      switch (reminder.pendingAction) {
        case 'create':
          final response = await _apiService!.createReminderText(
            title: reminder.title,
            reminder_time: reminder.runtime,
            description: reminder.description,
          );
          final serverId = response.data?.id?.toString();
          debugPrint('Reminder ${reminder.id} created on server with ID: $serverId');
          return SyncResult(success: true, serverId: serverId);
          
        case 'update':
          if (reminder.serverId != null) {
            await _apiService!.editReminderText(
              id: reminder.serverId!,
              title: reminder.title,
              text: reminder.description,
              dateTime: reminder.runtime,
            );
            debugPrint('Reminder ${reminder.id} updated on server');
            return SyncResult(success: true);
          }
          break;
          
        case 'delete':
          if (reminder.serverId != null) {
            await _apiService!.delete(context_id: reminder.serverId!, context: 'reminder');
            debugPrint('Reminder ${reminder.id} deleted on server');
            return SyncResult(success: true);
          }
          break;
          
        default:
          if (reminder.serverId != null) {
            debugPrint('Reminder ${reminder.id} already synced');
            return SyncResult(success: true);
          }
      }
      return SyncResult(success: false);
    } catch (e) {
      debugPrint('Error syncing reminder ${reminder.id}: $e');
      return SyncResult(success: false);
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

class SyncResult {
  final bool success;
  final String? serverId;
  
  SyncResult({required this.success, this.serverId});
}