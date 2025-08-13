import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Priority;
import 'package:stacked/stacked.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../../app/app.locator.dart';
import '../../../services/api_service.dart';
import '../../../services/app_auth_service.dart';

class VoiceNewViewmodel extends ReactiveViewModel {
  BuildContext context;

  bool isFabOpen = false;
  List<Note> notes = [];
  List<Reminder> reminders = [];

  VoiceNewViewmodel(this.context);

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void init() {
    tz.initializeTimeZones();
    _initializeNotifications();
    fetchAll();
    FirebaseMessaging.instance.getToken().then((value) {
      callUpdateUserProfile(value!);
    });
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
            
            if (!reminder.isCompleted) {
              scheduleAlarmForReminder(reminder);
            }
          } else {
            notes.add(Note(
              id: item.iId!.oid.toString(),
              title: item.transcription ?? "N/A",
              content: item.transcription ?? "N/A",
              createdAt: item.createdAt?.date??"",
              isReminder: false
            ));
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
        scheduleDate.month+1,
        /*scheduleDate.day*/12,
        /*int.parse(timeParts[0]*/12,
        /*int.parse(timeParts[1])*/34,
      );

      if (scheduledTime.isBefore(DateTime.now())) return;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        channelDescription: 'Notifications for reminders',
        importance: Importance.max,
        showWhen: false,
      );
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(reminder.id.hashCode.toString().substring(0, 8)),
        reminder.title,
        reminder.description,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling alarm for reminder: $e');
    }
  }

  Future<void> cancelAlarmForReminder(String reminderId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(
        int.parse(reminderId.hashCode.toString().substring(0, 8)),
      );
    } catch (e) {
      print('Error canceling alarm for reminder: $e');
    }
  }

  Future<void> updateReminderAlarm(Reminder reminder) async {
    await cancelAlarmForReminder(reminder.id);
    await scheduleAlarmForReminder(reminder);
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
