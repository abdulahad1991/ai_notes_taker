import 'package:ai_notes_taker/models/response/login_response.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../i18n/strings.g.dart';
import '../../../services/api_service.dart';
import '../../../services/app_auth_service.dart';
import '../../../services/timezone_region_service.dart';

class AuthViewModel extends ReactiveViewModel {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();
  final timezoneRegionService = TimezoneRegionService.instance;

  // State
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String token = "";
  Map<String, dynamic>? userRegionData;
  AppLocale currentLocale = AppLocale.en;

  final formKey = GlobalKey<FormState>();

  void init() {
    initFirebase();
    _getUserRegion();
    if(authService.loginData!=null){
      NavigationService().navigateTo(Routes.voiceNewView);
    }
  }

  void _getUserRegion() {
    try {
      userRegionData = timezoneRegionService.getDetailedRegionInfo();
      print('User region data: $userRegionData');
      
      // Set language based on region
      _setLanguageBasedOnRegion();
    } catch (e) {
      print('Error getting user region: $e');
    }
  }

  void _setLanguageBasedOnRegion() {
    if (userRegionData != null) {
      final country = userRegionData!['country']?.toString().toLowerCase();
      final countryCode = userRegionData!['countryCode']?.toString().toLowerCase();
      final region = userRegionData!['region']?.toString().toLowerCase();
      
      print('Detected country: $country, country code: $countryCode, region: $region');
      
      // Set German if country/region indicates Germany
      if (country?.contains('germany') == true || 
          countryCode == 'de' ||
          region?.contains('germany') == true ||
          region?.contains('german') == true) {
        currentLocale = AppLocale.de;
        LocaleSettings.setLocale(AppLocale.de);
        print('🇩🇪 Language set to German based on region detection');
      } else {
        currentLocale = AppLocale.en;
        LocaleSettings.setLocale(AppLocale.en);
        print('🇺🇸 Language set to English (default)');
      }
      
      notifyListeners();
    }
  }

  void initFirebase() {
    FirebaseMessaging.instance.getToken().then((value) {
      token = value!;
      print("FCM - ${token}");
    });
  }

  void toggleAuthMode() {
    isLogin = !isLogin;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  void toggleLanguage() {
    currentLocale = currentLocale == AppLocale.en ? AppLocale.de : AppLocale.en;
    LocaleSettings.setLocale(currentLocale);
    notifyListeners();
  }

  void setLanguage(AppLocale locale) {
    currentLocale = locale;
    LocaleSettings.setLocale(locale);
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {

    /*notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    isLoading = false;
    notifyListeners();*/

    // if (!formKey.currentState!.validate()) return;
    // emailController.text = "saad@gmail.com";
    // passwordController.text = "saad123";
    if (isLogin) {
      try {
        var response = await runBusyFuture(
          api.login(
              email: emailController.text.toString(),
              password: passwordController.text.toString(),
              fcm_token: token,
              // region: userRegionData?['region'],
              // country: userRegionData?['country'],
              offset: userRegionData?['offsetString'],
              timezone: userRegionData?['timezone']),
          throwException: true,
        );
        if (response != null) {
          final data = response as LoginResponse;
          authService.setLoginData(data);
          NavigationService().navigateTo(Routes.voiceNewView);
        }
      } on FormatException catch (e) {
        print(e);
      }
    } else {
      try {
        var response = await runBusyFuture(
          api.signup(
              first_name: nameController.text.toString().split(" ").first,
              last_name: nameController.text.toString().split(" ").last,
              email: emailController.text.toString(),
              password: passwordController.text.toString(),
              offset: userRegionData?['offsetString'],
              timezone: userRegionData?['timezone']),
          throwException: true,
        );
        if (response != null) {
          isLogin = true;
          notifyListeners();
        }
      } on FormatException catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
