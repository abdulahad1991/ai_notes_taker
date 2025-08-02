import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

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

  void init() {
    fetchAll();
    FirebaseMessaging.instance.getToken().then((value) {
      callUpdateUserProfile(value!);
    });
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
            reminders.add(Reminder(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              description: item.reminder?.message ?? "N/A",
              time: "",
              date: "",
              isCompleted: item.reminder?.isDelivered ?? false,
              priority: Priority.medium,
            ));
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

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
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
