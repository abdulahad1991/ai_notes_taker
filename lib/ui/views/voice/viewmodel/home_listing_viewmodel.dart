import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:stacked/stacked.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:alarm/alarm.dart';

import '../../../../app/app.locator.dart';
import '../../../../services/api_service.dart';
import '../../../../services/app_auth_service.dart';

class HomeListingViewmodel extends ReactiveViewModel {
  BuildContext context;

  bool isFabOpen = false;
  List<Note> notes = [];
  List<Reminder> reminders = [];
  int selectedTabIndex = 0;

  HomeListingViewmodel(this.context);

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void init() async {
    tz.initializeTimeZones();
    await _initializeNotifications();
    await _initializeAlarm();
    _setupAlarmListeners();
    fetchAll();
    FirebaseMessaging.instance.getToken().then((value) {
      callUpdateUserProfile(value!);
    });
  }

  Future<void> _initializeAlarm() async {
    await Alarm.init();
  }

  void _setupAlarmListeners() {
    Alarm.ringStream.stream.listen((alarmSettings) {
      print(
          'Alarm ringing for reminder: ${alarmSettings.notificationSettings?.title}');
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
    await runBusyFuture(
      api.updateUser(fcm_token: token),
      throwException: true,
    );
  }

  Future<void> fetchAll() async {
    try {
      var response = await runBusyFuture(
        api.getAll(),
        throwException: true,
      );
      if (response != null) {
        final data = response as TranscriptionResponse;
        notes.clear();
        reminders.clear();

        for (var item in data.data!) {
          if (item.isReminder == true) {
            final reminder = Reminder(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              description: item.reminder?.message ?? "N/A",
              time: _formatTime(item.reminder?.date?.date.toString()),
              date: item.reminder!.date!.date.toString(),
              isCompleted: item.reminder?.isDelivered ?? false,
              priority: Priority.medium,
            );
            reminders.add(reminder);
            scheduleAlarmForReminder(reminder);
            if (!reminder.isCompleted) {
              scheduleAlarmForReminder(reminder);
            }
          } else {
            notes.add(Note(
                id: item.iId!.oid.toString(),
                title: item.transcription ?? "N/A",
                content: item.transcription ?? "N/A",
                createdAt: item.createdAt?.date ?? "",
                isReminder: false));
          }
        }

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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (itemDate == today) {
      return "Today";
    } else if (itemDate == today.add(Duration(days: 1))) {
      return "Tomorrow";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }

  Future<void> scheduleAlarmForReminder(Reminder reminder) async {
    if (reminder.date.isEmpty || reminder.time.isEmpty) return;

    try {
      final DateTime scheduleDate = DateTime.parse(reminder.date);
      final List<String> timeParts = reminder.time.split(':');
      final DateTime scheduledTime = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
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
          builder: (context) => VoiceView(isReminder: selectedTabIndex == 1)),
    ).then((result) {
      if (result == true) {
        // Refresh data when returning from voice recording
        fetchAll();
      } else if (result != null) {
        notes.add(result);
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
      if (result == true) {
        // Refresh data when returning from voice recording
        fetchAll();
      } else if (result != null) {
        notes.add(result);
      }
    });
  }

  void addNote() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceView(isReminder: false)),
    ).then((result) {
      if (result == true) {
        // Refresh data when returning from voice recording
        fetchAll();
      } else if (result != null) {
        notes.add(result);
      }
    });
  }

  void addReminder() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceView(isReminder: true)),
    ).then((result) {
      if (result == true) {
        // Refresh data when returning from voice recording
        fetchAll();
      } else if (result != null) {
        reminders.add(result);
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
}

class Note {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final bool isReminder;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isReminder,
  });
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final String time;
  final String date;
  bool isCompleted;
  final Priority priority;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.isCompleted,
    required this.priority,
  });
}
