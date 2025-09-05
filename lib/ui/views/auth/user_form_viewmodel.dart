import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/response/signup_form_response.dart';
import '../../../services/api_service.dart';
import '../../common/ui_helpers.dart';

class UserFormViewModel extends ReactiveViewModel {
  final api = locator<ApiService>();
  final navigationService = locator<NavigationService>();
  final formKey = GlobalKey<FormState>();
  
  SignupFormResponse? _formResponse;
  SignupFormResponse? get formResponse => _formResponse;
  
  Map<String, String> _formAnswers = {};
  Map<String, String> get formAnswers => _formAnswers;
  
  String _currentLanguage = 'EN';
  String get currentLanguage => _currentLanguage;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BuildContext context;
  UserFormViewModel(this.context);

  void init() async {
    await fetchFormData();
  }
  
  Future<void> fetchFormData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      try {
        var response = await runBusyFuture(
          api.getSignUpForm(),

          throwException: true,
        );
        if (response != null) {
          final data = response as SignupFormResponse;
          _formResponse = data;
        }
      } on FormatException catch (e) {
        showErrorDialog(e.message,
            context);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load form data. Please try again.';
      notifyListeners();
    }
  }
  
  void updateAnswer(String questionId, String value) {
    _formAnswers[questionId] = value;
    notifyListeners();
  }
  
  void changeLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
  
  EN? getCurrentLanguageData() {
    if (_formResponse?.data?.isNotEmpty == true) {
      final region = _formResponse!.data!.first.region;
      return _currentLanguage == 'EN' ? region?.eN : region?.dE;
    }
    return null;
  }
  
  List<Question>? getQuestions() {
    return getCurrentLanguageData()?.question;
  }
  
  String? getTitle() {
    return getCurrentLanguageData()?.title;
  }
  
  bool isFormValid() {
    final questions = getQuestions();
    if (questions == null) return false;
    
    for (final question in questions) {
      if (question.id != null && !_formAnswers.containsKey(question.id!)) {
        return false;
      }
    }
    return true;
  }
  
  Future<void> submitForm() async {
    if (!isFormValid()) {
      _errorMessage = 'Please answer all questions';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Submit each form answer to API using updateInfoForm
      for (final entry in _formAnswers.entries) {
        try {
          await api.updateInfoForm(
            key: entry.key,
            value: entry.value,
          );
          debugPrint('Successfully updated ${entry.key}: ${entry.value}');
        } catch (e) {
          debugPrint('Error updating ${entry.key}: $e');
          throw e; // Rethrow to trigger error handling
        }
      }
      
      _isLoading = false;
      notifyListeners();
      
      // Navigate to voice view after successful submission
      navigationService.navigateTo(Routes.voiceNewView);
      debugPrint('Form submitted successfully: $_formAnswers');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit form. Please try again.';
      notifyListeners();
      debugPrint('Form submission error: $e');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}