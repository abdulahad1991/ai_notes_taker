import 'dart:async';
import 'package:flutter/material.dart';
import '../models/local/local_note.dart';
import '../models/local/local_reminder.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();
  
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    
    _connectivityService.initialize();
    _listenToConnectivityChanges();
    _isInitialized = true;
    debugPrint('OfflineService initialized');
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected) {
        _handleConnectionRestored();
      }
    });
  }

  Future<void> _handleConnectionRestored() async {
    debugPrint('Internet connection restored - starting sync');
    try {
      await _syncService.syncAllData();
      debugPrint('Sync completed successfully');
    } catch (e) {
      debugPrint('Error during sync: $e');
    }
  }

  // Notes operations
  Future<LocalNote> createTextNote({
    required String title,
    required String content,
  }) async {
    final note = LocalNote(
      title: title,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      isReminder: false,
      isPinned: false,
      isSynced: _connectivityService.isConnected ? true : false,
      pendingAction: _connectivityService.isConnected ? null : 'create',
    );

    final id = await _dbHelper.insertNote(note);
    final createdNote = note.copyWith(id: id);
    
    debugPrint('Created offline text note: ${createdNote.title}');
    return createdNote;
  }

  Future<List<LocalNote>> getAllNotes() async {
    return await _dbHelper.getAllNotes();
  }

  Future<LocalNote?> getNoteById(String id) async {
    return await _dbHelper.getNoteById(id);
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final existingNote = await _dbHelper.getNoteById(id);
    if (existingNote == null) return;

    final updatedNote = existingNote.copyWith(
      title: title,
      content: content,
      isSynced: _connectivityService.isConnected ? existingNote.isSynced : false,
      pendingAction: _connectivityService.isConnected ? existingNote.pendingAction : 'update',
    );

    await _dbHelper.updateNote(updatedNote);
    debugPrint('Updated offline note: $title');
  }

  Future<void> pinNote(String id, bool isPinned) async {
    final existingNote = await _dbHelper.getNoteById(id);
    if (existingNote == null) return;

    final updatedNote = existingNote.copyWith(
      isPinned: isPinned,
      isSynced: _connectivityService.isConnected ? existingNote.isSynced : false,
      pendingAction: _connectivityService.isConnected ? existingNote.pendingAction : 'update',
    );

    await _dbHelper.updateNote(updatedNote);
    debugPrint('${isPinned ? 'Pinned' : 'Unpinned'} offline note: ${existingNote.title}');
  }

  Future<void> deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    debugPrint('Deleted offline note with id: $id');
  }

  // Reminders operations
  Future<LocalReminder> createTextReminder({
    required String title,
    required String description,
    required String reminderTime,
    required String date,
    required String runtime,
    String priority = 'medium',
  }) async {
    final reminder = LocalReminder(
      title: title,
      description: description,
      time: reminderTime,
      date: date,
      runtime: runtime,
      isCompleted: false,
      priority: priority,
      isSynced: _connectivityService.isConnected ? true : false,
      pendingAction: _connectivityService.isConnected ? null : 'create',
    );

    final id = await _dbHelper.insertReminder(reminder);
    final createdReminder = reminder.copyWith(id: id);
    
    debugPrint('Created offline text reminder: ${createdReminder.title}');
    return createdReminder;
  }

  Future<List<LocalReminder>> getAllReminders() async {
    return await _dbHelper.getAllReminders();
  }

  Future<LocalReminder?> getReminderById(int id) async {
    return await _dbHelper.getReminderById(id);
  }

  Future<void> updateReminder({
    required int id,
    required String title,
    required String description,
    required String reminderTime,
    required String date,
    required String runtime,
    String? priority,
  }) async {
    final existingReminder = await _dbHelper.getReminderById(id);
    if (existingReminder == null) return;

    final updatedReminder = existingReminder.copyWith(
      title: title,
      description: description,
      time: reminderTime,
      date: date,
      runtime: runtime,
      priority: priority ?? existingReminder.priority,
      isSynced: _connectivityService.isConnected ? existingReminder.isSynced : false,
      pendingAction: _connectivityService.isConnected ? existingReminder.pendingAction : 'update',
    );

    await _dbHelper.updateReminder(updatedReminder);
    debugPrint('Updated offline reminder: $title');
  }

  Future<void> markReminderCompleted(int id, bool isCompleted) async {
    final existingReminder = await _dbHelper.getReminderById(id);
    if (existingReminder == null) return;

    final updatedReminder = existingReminder.copyWith(
      isCompleted: isCompleted,
      isSynced: _connectivityService.isConnected ? existingReminder.isSynced : false,
      pendingAction: _connectivityService.isConnected ? existingReminder.pendingAction : 'update',
    );

    await _dbHelper.updateReminder(updatedReminder);
    debugPrint('Marked reminder ${isCompleted ? 'completed' : 'incomplete'}: ${existingReminder.title}');
  }

  Future<void> deleteReminder(int id) async {
    await _dbHelper.deleteReminder(id);
    debugPrint('Deleted offline reminder with id: $id');
  }

  // Utility methods
  Future<bool> hasUnsyncedData() async {
    return await _dbHelper.hasUnsyncedData();
  }

  bool get isOnline => _connectivityService.isConnected;

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}