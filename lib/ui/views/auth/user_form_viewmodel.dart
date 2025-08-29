import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../models/response/signup_form_response.dart';
import '../../../services/api_service.dart';

class UserFormViewModel extends ReactiveViewModel {
  final api = locator<ApiService>();
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

  void init() async {
    await fetchFormData();
  }
  
  Future<void> fetchFormData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Replace with actual API call
      // For now, using the provided JSON data
      final mockResponse = {
        "success": true,
        "data": [
          {
            "_id": "68af746191061c2f78bb94d7",
            "type": "post_signup",
            "region": {
              "EN": {
                "title": "Let Us Get To Know Each Other",
                "question": [
                  {
                    "id": "profession",
                    "text": "Which industry do you work in?",
                    "answer": {
                      "type": "drop_down",
                      "options": [
                        "IT",
                        "Engineering",
                        "Sales",
                        "Marketing",
                        "Finance",
                        "Medical",
                        "Art",
                        "Law",
                        "Hospitality"
                      ]
                    }
                  },
                  {
                    "id": "professional_level",
                    "text": "What career level are you at?",
                    "answer": {
                      "type": "drop_down",
                      "options": [
                        "Student",
                        "Beginner",
                        "Manager",
                        "Chief",
                        "Owner"
                      ]
                    }
                  }
                ]
              },
              "DE": {
                "title": "Lass uns uns kennenlernen",
                "question": [
                  {
                    "id": "profession",
                    "text": "In welcher Branche arbeiten Sie?",
                    "answer": {
                      "type": "drop_down",
                      "options": [
                        "IT",
                        "Ingenieurwesen",
                        "Vertrieb",
                        "Marketing",
                        "Finanzen",
                        "Medizin",
                        "Kunst",
                        "Recht",
                        "Gastfreundschaft"
                      ]
                    }
                  },
                  {
                    "id": "professional_level",
                    "text": "Auf welchem Karrierelevel befinden Sie sich?",
                    "answer": {
                      "type": "drop_down",
                      "options": [
                        "Student",
                        "Anfänger",
                        "Manager",
                        "Chef",
                        "Eigentümer"
                      ]
                    }
                  }
                ]
              }
            },
            "is_active": true,
            "is_deleted": false
          }
        ]
      };
      
      _formResponse = SignupFormResponse.fromJson(mockResponse);
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
      
      // Submit form data to API
      // Replace with actual API call
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      _isLoading = false;
      notifyListeners();
      
      // Navigate to next screen or show success message
      debugPrint('Form submitted successfully: $_formAnswers');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit form. Please try again.';
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}