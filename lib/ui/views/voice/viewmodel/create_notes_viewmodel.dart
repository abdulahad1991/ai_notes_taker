import 'package:ai_notes_taker/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../models/response/create_note_text_response.dart';
import '../../../../services/api_service.dart';
import '../../../../services/data_service.dart';

class CreateNotesViewmodel extends ReactiveViewModel {
  BuildContext context;
  final bool isEdit;
  Note? note;

  CreateNotesViewmodel(
      this.context,  this.isEdit,  this.note);

  final api = locator<ApiService>();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // State variables
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isTitleFocused = false;
  bool isDescriptionFocused = false;

  void init() {
    titleController.addListener(_onFormChanged);
    descriptionController.addListener(_onFormChanged);
    if (isEdit) {
      titleController.text = note!.title;
      descriptionController.text = note!.content;
    }
  }

  void _onFormChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Focus management
  void setTitleFocus(bool focused) {
    isTitleFocused = focused;
    notifyListeners();
  }

  void setDescriptionFocus(bool focused) {
    isDescriptionFocused = focused;
    notifyListeners();
  }

  // Date and time selection
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF667eea),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFF667eea),
                  ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      notifyListeners();
    }
  }

  // Validation
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? validateContent(String? value) {
    if ((value == null || value.trim().isEmpty)) {
      return 'Please enter some content for the note';
    }
    return null;
  }


  bool get canSave {
    // If in edit mode, allow save if any field has content
    if (isEdit) {
      return titleController.text.trim().isNotEmpty ||
             descriptionController.text.trim().isNotEmpty;
    }
    
    // Original validation for new items
    // Check if title is not empty
    final titleNotEmpty = titleController.text.trim().isNotEmpty;

    // Check if content is not empty (only for notes, not reminders)
    final contentValid =
        descriptionController.text.trim().isNotEmpty;

    return titleNotEmpty && contentValid;
  }

  // Getters for UI
  String get dateText {
    if (selectedDate == null) return 'Select date';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  String get timeText {
    if (selectedTime == null) return 'Select time';
    
    // Convert 24-hour format to 12-hour format with AM/PM
    int hour = selectedTime!.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} $period';
  }

  String get appBarTitle {
    String title = "";
    if(!isEdit){
      title = "New Note";
    }else {
      title = "Edit Note";
    }
    return title;
  }

  String get titleHint {
    return 'Note title';
  }

  String get contentHint {
    return 'Write your note here...';
  }

  void saveInput() {
    if (isEdit || formKey.currentState!.validate()) {
      if (isEdit) {
        editNote();
      } else {
        createNote();
      }
    }
  }

  void onBackPressed() {
    Navigator.pop(context);
  }

  Future<void> createReminder(String scheduleDateTime) async {
    try {
      var response = await runBusyFuture(
          api.createReminderText(
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              reminder_time: scheduleDateTime.toString()),
          throwException: true);
      if (response != null) {
        final data = response as CreateNoteTextResponse;
        Navigator.pop(context);
      }
    } on FormatException catch (e) {
      showErrorDialog(e.message, context);
    }
  }

  Future<void> createNote() async {
    try {
      var response = await runBusyFuture(
          api.createNoteText(
              title: titleController.text.trim(),
              text: descriptionController.text.trim()),
          throwException: true);
      if (response != null) {
        Navigator.pop(context);
      }
    } on FormatException catch (e) {
      showErrorDialog(e.message, context);
    }
  }

  Future<void> editNote() async {
    try {
      var response = await runBusyFuture(
          api.editNoteText(
              id: note!.id.toString(),
              title: titleController.text.trim(),
              text: descriptionController.text.trim()),
          throwException: true);
      if (response != null) {
        Navigator.pop(context);
      }
    } on FormatException catch (e) {
      showErrorDialog(e.message, context);
    }
  }
}
