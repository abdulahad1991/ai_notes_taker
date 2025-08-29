import 'package:ai_notes_taker/models/response/notes_response.dart';
import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/text_input_view.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:stacked/stacked.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:alarm/alarm.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../services/api_service.dart';
import '../../../../services/app_auth_service.dart';
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

  HomeListingViewmodel(this.context);

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void init() async {
    setBusy(true);
    tz.initializeTimeZones();
    await _initializeNotifications();
    await _initializeAlarm();

    // Add a small delay to ensure everything is properly initialized
    Future.delayed(Duration(milliseconds: 500), () async {
      await fetchNotes();
      setBusy(false);
    });

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

  Future<void> fetchReminders() async {
    try {
      var response = await runBusyFuture(
        api.getReminders(reminderPage),
        throwException: true,
      );
      if (response != null) {
        final data = response as TranscriptionResponse;
        reminders.clear();

        if (data.data != null) {
          for (var item in data.data!) {
            final reminder = Reminder(
              id: item.sId!.toString(),
              title: item.title ?? "N/A",
              description: item.text ?? "N/A",
              time: _formatTime(item.userCurrentDatetime),
              date: item.userCurrentDatetime ?? "N/A",
              isCompleted: item.isDelivered ?? false,
              priority: Priority.medium,
              runtime: item.runTime ?? "",
            );
            reminders.add(reminder);
            try {
              if (!reminder.isCompleted) {
                scheduleAlarmForReminder(reminder);
              }
            } catch (e) {
              print(e);
            }
          }
        }
        notifyListeners();
      }
    } on FormatException catch (e) {
      print('FormatException in fetchReminders: $e');
    } catch (e) {
      print('General exception in fetchReminders: $e');
    }
  }

  Future<void> fetchNotes() async {
    try {
      var response = await runBusyFuture(
        api.getNotes(notesPage),
        throwException: true,
      );
      if (response != null) {
        final data = response as NotesResponse;
        notes.clear();

        for (var item in data.data!) {
          notes.add(Note(
              id: item.sId.toString(),
              title: item.title ?? "N/A",
              content: item.text ?? "N/A",
              createdAt: item.createdAt ?? "",
              isReminder: false,
              isPinned: item.is_pin == 0));
        }

        fetchReminders();
        notifyListeners();
      }
    } on FormatException catch (e) {
      print(e);
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "N/A";
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "N/A";
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await runBusyFuture(
        api.delete(context_id: note.id, context: "note"),
        throwException: true,
      );

      init();
    } on FormatException catch (e) {
      print(e);
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await runBusyFuture(
        api.delete(context_id: reminder.id, context: "reminder"),
        throwException: true,
      );

      init();
    } on FormatException catch (e) {
      print(e);
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TextInputView(
                isReminder: selectedTabIndex == 1,
                isEdit: false,
              )),
    ).then((result) {
      if (selectedTabIndex == 1) {
        fetchReminders();
      } else {
        fetchNotes();
      }
    });
  }

  void voiceClick() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VoiceView(isReminder: selectedTabIndex == 1)),
    ).then((result) {
      if (selectedTabIndex == 1) {
        fetchReminders();
      } else {
        fetchNotes();
      }
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
          builder: (context) => TextInputView(
                isReminder: selectedTabIndex == 1,
                isEdit: true,
                note: note,
              )),
    ).then((result) {
      if (selectedTabIndex == 1) {
        fetchReminders();
      } else {
        fetchNotes();
      }
    });
  }

  Future<void> togglePinNote(Note note) async {
    final noteIndex = notes.indexWhere((n) => n.id == note.id);
    if (noteIndex != -1) {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        isReminder: note.isReminder,
        isPinned: !note.isPinned,
      );
      try {
        var response = await runBusyFuture(
            api.pinNote(id: note!.id.toString(), is_pin: note.isPinned ? 1 : 0),
            throwException: true);
      } on FormatException catch (e) {
        // showErrorDialog(e.message, context);
      }
      notes[noteIndex] = updatedNote;
      notifyListeners();
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
      if (selectedTabIndex == 1) {
        fetchReminders();
      } else {
        fetchNotes();
      }
    });
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  List<dynamic> getFilteredItems() {
    if (selectedTabIndex == 0) {
      return notes;
    } else {
      return reminders;
    }
  }

  Future<void> logout() async {
    await authService.resetAuthData();
    NavigationService().navigateTo(Routes.authScreen);
  }
}

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
