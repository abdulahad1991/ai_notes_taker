import 'dart:async';
import 'package:ai_notes_taker/ui/views/voice/create_notes_view.dart';
import 'package:ai_notes_taker/ui/views/voice/text_input_view.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart' hide Priority;
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:stacked/stacked.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:alarm/alarm.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../services/api_service.dart';
import '../../../../services/app_auth_service.dart';
import '../../../../services/sound_service.dart';
import '../../../../services/database_helper.dart';
import '../../../../services/sync_service.dart';
import '../../../../services/connectivity_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/offline_service.dart';
import '../../../../shared/functions.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeListingViewmodel extends ReactiveViewModel {
  BuildContext context;

  bool isFabOpen = false;
  List<Note> notes = [];
  List<Reminder> reminders = [];
  int selectedTabIndex = 0;
  int notesPage = 0;
  int reminderPage = 0;
  
  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  HomeListingViewmodel(this.context);

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();
  final soundService = SoundService();
  final dbHelper = locator<DatabaseHelper>();
  final syncService = locator<SyncService>();
  final connectivityService = locator<ConnectivityService>();
  final dataService = locator<DataService>();
  final offlineService = locator<OfflineService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void init() async {
    setBusy(true);
    tz.initializeTimeZones();
    await _initializeNotifications();
    await _initializeAlarm();

    // Initialize sync and connectivity services with error handling
    try {
      syncService.initialize(api);
    } catch (e) {
      print('Error initializing sync service: $e');
    }

    try {
      connectivityService.initialize();
    } catch (e) {
      print('Error initializing connectivity service: $e');
    }

    // Initialize data service
    try {
      dataService.initialize(api, connectivityService);
    } catch (e) {
      print('Error initializing data service: $e');
    }

    // Cancel existing subscriptions before creating new ones
    _syncStatusSubscription?.cancel();
    _connectivitySubscription?.cancel();

    // Listen to sync status with error handling
   /* try {
      _syncStatusSubscription = syncService.syncStatusStream.listen((status) {
        if (status == SyncStatus.completed) {
          // After sync, refresh data - offline items should be gone
          fetchData();
        }
      });
    } catch (e) {
      print('Error setting up sync status listener: $e');
    }*/

    // Listen to connectivity changes with error handling
    /*try {
      _connectivitySubscription = connectivityService.connectionStream.listen((isConnected) {
        if (isConnected) {
          syncService.forceSyncNow();
        }
      });
    } catch (e) {
      print('Error setting up connectivity listener: $e');
    }*/

    // Load data using offline-only database strategy
    await fetchData();
    setBusy(false);

    // Start background sync for any pending local changes
    try {
      syncService.forceSyncNow();
    } catch (e) {
      print('Error starting sync: $e');
    }

    FirebaseMessaging.instance.getToken().then((value) {
      callUpdateUserProfile(value!);
    });
    try {
      _setupAlarmListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _initializeAlarm() async {
    await Alarm.init();
  }

  void _setupAlarmListeners() {
    Alarm.ringStream.stream.listen((alarmSettings) {
      print(
          'Alarm ringing for reminder: ${alarmSettings.notificationSettings.title}');
      _handleAlarmRinging(alarmSettings);
    });
  }

  void _handleAlarmRinging(AlarmSettings alarmSettings) {
    try {
      final reminder = reminders.firstWhere(
        (r) =>
            int.parse(r.id.hashCode.toString().substring(0, 8)) ==
            alarmSettings.id,
      );
      _showAlarmDialog(reminder);
    } catch (e) {
      print('Reminder not found for alarm ID: ${alarmSettings.id}');
    }
  }

  void _showAlarmDialog(Reminder reminder) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Reminder: ${reminder.title}'),
        content: Text(reminder.description),
        actions: [
          TextButton(
            onPressed: () {
              Alarm.stop(
                  int.parse(reminder.id.hashCode.toString().substring(0, 8)));
              Navigator.of(context).pop();
              _markReminderCompleted(reminder);
            },
            child: Text('Mark Complete'),
          ),
          TextButton(
            onPressed: () {
              Alarm.stop(
                  int.parse(reminder.id.hashCode.toString().substring(0, 8)));
              Navigator.of(context).pop();
              _snoozeReminder(reminder);
            },
            child: Text('Snooze'),
          ),
        ],
      ),
    );
  }

  void _markReminderCompleted(Reminder reminder) {
    reminder.isCompleted = true;
    notifyListeners();
  }

  void _snoozeReminder(Reminder reminder) {
    final snoozeTime = DateTime.now().add(Duration(minutes: 10));
    final snoozeReminder = Reminder(
      id: '${reminder.id}_snooze',
      title: reminder.title,
      description: reminder.description,
      time:
          "${snoozeTime.hour.toString().padLeft(2, '0')}:${snoozeTime.minute.toString().padLeft(2, '0')}",
      date: snoozeTime.toIso8601String(),
      isCompleted: false,
      priority: reminder.priority,
      runtime: reminder.runtime,
    );
    scheduleAlarmForReminder(snoozeReminder);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> callUpdateUserProfile(String token) async {
    await runBusyFuture(api.updateUser(fcm_token: token),
        throwException: true, busyObject: "update_user");
  }

  // Priority conversion methods moved to DataService

  Future<void> fetchData() async {
    try {
      final fetchedNotes = await dataService.fetchNotes();
      final fetchedReminders = await dataService.fetchReminders();

      notes.clear();
      notes.addAll(fetchedNotes);

      reminders.clear();
      reminders.addAll(fetchedReminders);

      // Schedule alarms for active reminders
      for (var reminder in reminders) {
        try {
          if (!reminder.isCompleted && reminder.runtime.isNotEmpty) {
            scheduleAlarmForReminder(reminder);
          }
        } catch (e) {
          print('Error scheduling alarm for reminder ${reminder.id}: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> deleteNote(Note note) async {
    // Remove from UI immediately for realtime feel
    final noteIndex = notes.indexWhere((n) => n.id == note.id);
    final deletedNote = note; // Keep reference for potential rollback
    notes.removeWhere((n) => n.id == note.id);
    notifyListeners();

    try {
      if (connectivityService.isConnected) {
        // Online: Call API to delete note
        await api.delete(context_id: note.id, context: 'note');
        print('Deleted note from server');
      } else {
        // Offline: Try to delete from local database
        // Convert note.id to int if it's a local note
        try {
          final localId = int.tryParse(note.id);
          if (localId != null) {
            await offlineService.deleteNote(localId);
            print('Deleted note from offline storage');
          } else {
            // It's a server note ID, can't delete while offline
            throw Exception('Cannot delete server note while offline');
          }
        } catch (e) {
          throw Exception('Failed to delete offline note: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note "${note.title}" deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error deleting note: $e');
      
      // Revert UI changes on failure - restore note at original position
      if (noteIndex != -1) {
        notes.insert(noteIndex, deletedNote);
      } else {
        notes.add(deletedNote);
      }
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete note: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    // Remove from UI immediately for realtime feel
    final reminderIndex = reminders.indexWhere((r) => r.id == reminder.id);
    final deletedReminder = reminder; // Keep reference for potential rollback
    reminders.removeWhere((r) => r.id == reminder.id);
    notifyListeners();

    try {
      if (connectivityService.isConnected) {
        // Online: Call API to delete reminder
        await api.delete(context_id: reminder.id, context: 'reminder');
        print('Deleted reminder from server');
      } else {
        // Offline: Try to delete from local database
        // Convert reminder.id to int if it's a local reminder
        try {
          final localId = int.tryParse(reminder.id);
          if (localId != null) {
            await offlineService.deleteReminder(localId);
            print('Deleted reminder from offline storage');
          } else {
            // It's a server reminder ID, can't delete while offline
            throw Exception('Cannot delete server reminder while offline');
          }
        } catch (e) {
          throw Exception('Failed to delete offline reminder: $e');
        }
      }

      // Cancel alarm regardless of source
      cancelAlarmForReminder(reminder.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder "${reminder.title}" deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error deleting reminder: $e');
      
      // Revert UI changes on failure - restore reminder at original position
      if (reminderIndex != -1) {
        reminders.insert(reminderIndex, deletedReminder);
      } else {
        reminders.add(deletedReminder);
      }
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> scheduleAlarmForReminder(Reminder reminder) async {
    if (reminder.runtime.isEmpty) return;

    try {
      final DateTime scheduledLocalTime = parseUtc(reminder.runtime).toLocal();

      final List<String> timeParts =
          scheduledLocalTime.toString().split(" ").last.split(":");
      final DateTime scheduledTime = DateTime(
        scheduledLocalTime.year,
        scheduledLocalTime.month,
        scheduledLocalTime.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      if (scheduledTime.isBefore(DateTime.now())) return;

      final alarmSettings = AlarmSettings(
        id: int.parse(reminder.id.hashCode.toString().substring(0, 8)),
        dateTime: scheduledTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volume: 0.8,
        fadeDuration: 3.0,
        notificationSettings: NotificationSettings(
          title: reminder.title,
          body: reminder.description,
          stopButton: 'Stop',
          icon: 'notification_icon',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      print('Alarm scheduled for ${scheduledTime.toString()}');
    } catch (e) {
      print('Error scheduling alarm for reminder: $e');
    }
  }

  Future<void> cancelAlarmForReminder(String reminderId) async {
    try {
      await Alarm.stop(
          int.parse(reminderId.hashCode.toString().substring(0, 8)));
      print('Alarm canceled for reminder: $reminderId');
    } catch (e) {
      print('Error canceling alarm for reminder: $e');
    }
  }

  Future<void> updateReminderAlarm(Reminder reminder) async {
    await cancelAlarmForReminder(reminder.id);
    await scheduleAlarmForReminder(reminder);
  }

  void textClick() {
    toggleFab();
    if (selectedTabIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TextInputView(
                  isReminder: true,
                  isEdit: false,
                )),
      ).then((result) {
        fetchData();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateNotesView(
                  isEdit: false,
                )),
      ).then((result) {
        fetchData();
      });
    }
  }

  void voiceClick() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VoiceView(isReminder: selectedTabIndex == 1)),
    ).then((result) {
      fetchData();
    });
  }

  void toggleFab() {
    isFabOpen = !isFabOpen;
    notifyListeners();
    /*isFabOpen = !isFabOpen;
    if (isFabOpen) {
      fabController.forward();
    } else {
      fabController.reverse();
    }*/
  }

  void editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateNotesView(
                isEdit: true,
                note: note,
              )),
    ).then((result) {
      fetchData();
    });
  }

  Future<void> togglePinNote(Note note) async {
    final noteIndex = notes.indexWhere((n) => n.id == note.id);
    if (noteIndex != -1) {
      final bool willBePinned = !note.isPinned;

      // Update UI immediately for realtime feel
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        isReminder: note.isReminder,
        isPinned: willBePinned,
      );
      notes[noteIndex] = updatedNote;
      notifyListeners();

      // Play sound effect immediately
      if (willBePinned) {
        await soundService.playSoundEffect(SoundEffect.pin);
      } else {
        await soundService.playSoundEffect(SoundEffect.unpin);
      }

      try {
        if (connectivityService.isConnected) {
          // Online: Call API to update pin status
          await api.pinNote(
            id: note.id,
            is_pin: willBePinned ? 1 : 0,
          );
        } else {
          // Offline: Update local database
          final localId = int.tryParse(note.id);
          if (localId != null) {
            await offlineService.pinNote(localId, willBePinned);
            print('Updated pin status in offline storage');
          } else {
            // It's a server note ID, can't update while offline
            throw Exception('Cannot pin/unpin server note while offline');
          }
        }

        // Show confirmation message on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(willBePinned ? 'Note pinned' : 'Note unpinned'),
            backgroundColor: willBePinned ? Colors.orange : Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      } catch (e) {
        print('Error toggling pin: $e');
        
        // Revert UI changes on failure
        final revertedNote = Note(
          id: note.id,
          title: note.title,
          content: note.content,
          createdAt: note.createdAt,
          isReminder: note.isReminder,
          isPinned: !willBePinned,
        );
        notes[noteIndex] = revertedNote;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${willBePinned ? 'pin' : 'unpin'} note: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void editReminder(Reminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TextInputView(
                isReminder: selectedTabIndex == 1,
                isEdit: true,
                reminder: reminder,
              )),
    ).then((result) {
      fetchData();
    });
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  List<dynamic> getFilteredItems() {
    if (selectedTabIndex == 0) {
      // Sort notes with pinned items first
      List<Note> sortedNotes = List.from(notes);
      sortedNotes.sort((a, b) {
        // First sort by isPinned (pinned items first)
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        // If both have same pin status, maintain original order
        return 0;
      });
      return sortedNotes;
    } else {
      return reminders;
    }
  }

  // Add new note using DataService
  Future<void> addNote({
    required String title,
    required String content,
    bool isReminder = false,
    bool isPinned = false,
  }) async {
    try {
      final note = await dataService.addNote(
        title: title,
        content: content,
        isReminder: isReminder,
        isPinned: isPinned,
      );

      if (note != null) {
        // Add to UI immediately
        notes.insert(0, note);
        notifyListeners();

        // Trigger sync if connected
        try {
          if (connectivityService.isConnected) {
            syncService.forceSyncNow();
          }
        } catch (e) {
          print('Error triggering sync: $e');
        }
      }
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  // Add new reminder using DataService
  Future<void> addReminder({
    required String title,
    required String description,
    required String time,
    required String date,
    required String runtime,
    Priority priority = Priority.medium,
  }) async {
    try {
      final reminder = await dataService.addReminder(
        title: title,
        description: description,
        time: time,
        date: date,
        runtime: runtime,
        priority: priority,
      );

      if (reminder != null) {
        // Add to UI immediately
        reminders.insert(0, reminder);

        // Schedule alarm if runtime is provided
        if (runtime.isNotEmpty) {
          scheduleAlarmForReminder(reminder);
        }

        notifyListeners();

        // Trigger sync if connected
        try {
          if (connectivityService.isConnected) {
            syncService.forceSyncNow();
          }
        } catch (e) {
          print('Error triggering sync: $e');
        }
      }
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  // Update existing note
  Future<void> updateNote(Note note,
      {String? title, String? content, bool? isPinned}) async {
    final noteIndex = notes.indexWhere((n) => n.id == note.id);
    if (noteIndex == -1) return;

    // Store original note for potential rollback
    final originalNote = note;
    
    // Update UI immediately for realtime feel
    final updatedNote = Note(
      id: note.id,
      title: title ?? note.title,
      content: content ?? note.content,
      createdAt: note.createdAt,
      isReminder: note.isReminder,
      isPinned: isPinned ?? note.isPinned,
    );
    notes[noteIndex] = updatedNote;
    notifyListeners();

    try {
      // Call API to update note
      await api.editNoteText(
        id: note.id,
        title: title ?? note.title,
        text: content ?? note.content,
      );
      print('Updated note on server');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error updating note: $e');
      
      // Revert UI changes on API failure
      notes[noteIndex] = originalNote;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update note'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Get sync status for UI indication
  bool isDataSyncing() {
    return syncService.isSyncing;
  }

  // Force sync manually
  Future<void> forceSyncData() async {
    await syncService.forceSyncNow();
  }

  // Get connectivity status
  bool hasInternetConnection() {
    try {
      return connectivityService.isConnected;
    } catch (e) {
      print('Error checking connectivity: $e');
      return true; // Assume connected if check fails
    }
  }

  Future<void> logout() async {
    await authService.resetAuthData();
    NavigationService().navigateTo(Routes.authScreen);
  }

  @override
  void dispose() {
    _syncStatusSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

// Note, Reminder, and Priority classes moved to DataService
