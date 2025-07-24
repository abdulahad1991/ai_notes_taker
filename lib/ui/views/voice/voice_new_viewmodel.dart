import 'package:ai_notes_taker/models/response/transcription_response.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart' hide Reminder;
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

  void init(){

    fetchAll();
  }
  Future<void> fetchAll() async {
    try {
      var response = await runBusyFuture(
        api.getAll(),
        throwException: true,
      );
      if (response != null) {
        final data = response as TranscriptionResponse;
      }
    } on FormatException catch (e) {
      print(e);
    }
  }


  void addNote() {
    toggleFab();
    // Navigate to note creation screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteCreationScreen()),
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
      MaterialPageRoute(builder: (context) => VoiceView()),
    ).then((reminder) {
      if (reminder != null) {
        reminders.add(reminder);
      }
    });
  }

  void toggleFab() {
    isFabOpen = !isFabOpen;
    if (isFabOpen) {
      fabController.forward();
    } else {
      fabController.reverse();
    }
  }
}
