import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart' hide Reminder;
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
        for (var item in data.data!) {
          notes.add(Note(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              content: item.reminder?.message ?? "N/A",
              createdAt: ""));
          print("object");
        }
        for (var item in data.data!) {
          notes.add(Note(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              content: item.reminder?.message ?? "N/A",
              createdAt: ""));
          print("object");
        }
        for (var item in data.data!) {
          notes.add(Note(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              content: item.reminder?.message ?? "N/A",
              createdAt: ""));
          print("object");
        }
        for (var item in data.data!) {
          notes.add(Note(
              id: item.iId!.oid.toString(),
              title: item.reminder?.title ?? "N/A",
              content: item.reminder?.message ?? "N/A",
              createdAt: ""));
          print("object");
        }
        notifyListeners();
      }
    } on FormatException catch (e) {
      print(e);
    }
  }

  void addNote() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceView(isReminder: false)),
    ).then((note) {
      if (note != null) {
        notes.add(note);
      }
    });
  }

  void addReminder() {
    toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceView(isReminder: true)),
    ).then((reminder) {
      if (reminder != null) {
        reminders.add(reminder);
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
