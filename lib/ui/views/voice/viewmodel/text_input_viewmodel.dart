import 'package:ai_notes_taker/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../models/response/create_note_text_response.dart';
import '../../../../services/api_service.dart';
import '../../../../shared/functions.dart';
import 'home_listing_viewmodel.dart';

class TextInputViewmodel extends ReactiveViewModel {
  BuildContext context;
  final bool isReminder;
  final bool isEdit;
  Reminder? reminder;
  Note? note;

  TextInputViewmodel(
      this.context, this.isReminder, this.isEdit, this.reminder, this.note);

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
      if (reminder != null) {
        titleController.text = reminder!.title;
        descriptionController.text = reminder!.description;
        
        // Parse and set date and time from reminder data
        if (reminder!.date.isNotEmpty && reminder!.date != "N/A") {
          try {
            final DateTime dateTime = DateTime.parse(reminder!.date);
            selectedDate = dateTime;
          } catch (e) {
            print('Error parsing reminder date: $e');
          }
        }
        
        if (reminder!.time.isNotEmpty && reminder!.time != "N/A") {
          try {
            final List<String> timeParts = reminder!.time.split(':');
            if (timeParts.length >= 2) {
              final int hour = int.parse(timeParts[0]);
              final int minute = int.parse(timeParts[1]);
              selectedTime = TimeOfDay(hour: hour, minute: minute);
            }
          } catch (e) {
            print('Error parsing reminder time: $e');
          }
        }
      } else {
        titleController.text = note!.title;
        descriptionController.text = note!.content;
      }
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
    if (!isReminder && (value == null || value.trim().isEmpty)) {
      return 'Please enter some content for the note';
    }
    return null;
  }

  bool get isReminderValid {
    return !isReminder || (selectedDate != null && selectedTime != null);
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
        isReminder || descriptionController.text.trim().isNotEmpty;

    // Check if reminder date/time is selected (only for reminders)
    final reminderDateTimeValid =
        !isReminder || (selectedDate != null && selectedTime != null);

    return titleNotEmpty && contentValid && reminderDateTimeValid;
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

  bool get showDateTimeWarning {
    return isReminder && (selectedDate == null || selectedTime == null);
  }

  String get tipText {
    return isReminder
        ? 'Set a specific date and time to get notified about your reminder'
        : 'Write detailed notes to help you remember important information';
  }

  IconData get tipIcon {
    return isReminder ? Icons.lightbulb_outline : Icons.edit_outlined;
  }

  String get appBarTitle {
    String title = "";
    if(isReminder){
      if(!isEdit){
        title = "New Reminder";
      }else {
        title = "Edit Reminder";
      }
    }else {
      if(!isEdit){
        title = "New Note";
      }else {
        title = "Edit Note";
      }
    }
    return title;
  }

  String get titleHint {
    return isReminder ? 'Reminder title' : 'Note title';
  }

  String get contentHint {
    return isReminder
        ? 'Reminder description (optional)'
        : 'Write your note here...';
  }

  void saveInput() {
    if (isEdit || formKey.currentState!.validate()) {
      if (isReminder) {
        if (selectedDate != null && selectedTime != null) {
          final DateTime scheduleDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          ).toUtc();


          // final String isoLocal = scheduleDateTime.toIso8601String();
          final String isoLocal = scheduleDateTime.toIso8601String();

          if (isEdit) {
            editReminder("${isoLocal}");
          } else {
            createReminder("${isoLocal}");
          }
        }
      } else {
        if (isEdit) {
          editNote();
        } else {
          createNote();
        }
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

  Future<void> editReminder(String scheduleDateTime) async {
    try {
      var response = await runBusyFuture(
          api.editReminderText(
              id: reminder!.id.toString(),
              title: titleController.text.trim(),
              text: descriptionController.text.trim(),
              dateTime: scheduleDateTime.toString()),
          throwException: true);
      if (response != null) {
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
