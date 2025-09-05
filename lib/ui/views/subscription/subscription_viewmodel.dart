import 'package:ai_notes_taker/models/response/subscription_form_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/api_service.dart';
import '../../common/ui_helpers.dart';

class SubscriptionViewmodel extends ReactiveViewModel {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  final api = locator<ApiService>();
  BuildContext context;

  SubscriptionViewmodel(this.context);

  SubscriptionFormResponse? _formResponse;
  SubscriptionFormResponse? get formResponse => _formResponse;

  String _selectedLanguage = 'EN';
  String get selectedLanguage => _selectedLanguage;

  int? _selectedPlanIndex;
  int? get selectedPlanIndex => _selectedPlanIndex;

  void init() {
    fetchFormData();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void selectPlan(int index) {
    _selectedPlanIndex = index;
    notifyListeners();
  }

  List<EN>? getPlans() {
    if (_formResponse?.data == null || _formResponse!.data!.isEmpty) {
      return null;
    }
    
    final region = _formResponse!.data!.first.region;
    if (region == null) return null;
    
    switch (_selectedLanguage) {
      case 'DE':
        return region.dE;
      case 'EN':
      default:
        return region.eN;
    }
  }

  String? getTitle() {
    return 'Choose Your Plan';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchFormData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      try {
        var response = await runBusyFuture(
          api.getPaymentForm(),
          throwException: true,
        );
        if (response != null) {
          final data = response as SubscriptionFormResponse;
          _formResponse = data;
        }
      } on FormatException catch (e) {
        showErrorDialog(e.message, context);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load subscription data. Please try again.';
      notifyListeners();
    }
  }

  Future<void> selectSubscription() async {
    if (_selectedPlanIndex == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final plans = getPlans();
      if (plans != null && _selectedPlanIndex! < plans.length) {
        final selectedPlan = plans[_selectedPlanIndex!];
        // TODO: Implement subscription selection API call
        // await api.selectSubscription(selectedPlan.title);
        
        // For now, just simulate success
        await Future.delayed(Duration(seconds: 1));
        
        // Navigate to next screen or show success message
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to select subscription. Please try again.';
      notifyListeners();
    }
  }
}
