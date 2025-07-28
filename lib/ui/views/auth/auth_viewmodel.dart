import 'package:ai_notes_taker/models/response/login_response.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/api_service.dart';
import '../../../services/app_auth_service.dart';

class AuthViewModel extends ReactiveViewModel {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final api = locator<ApiService>();
  final authService = locator<AppAuthService>();

  // State
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String token = "";

  final formKey = GlobalKey<FormState>();

  void init() {
    initFirebase();
    if(authService.loginData!=null){
      NavigationService().navigateTo(Routes.voiceNewView);
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

  Future<void> submitForm(BuildContext context) async {
    /*// if (!formKey.currentState!.validate()) return;

    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    isLoading = false;
    notifyListeners();*/

    emailController.text = "saad@gmail.com";
    passwordController.text = "saad123";
    if (isLogin) {
      try {
        var response = await runBusyFuture(
          api.login(
              email: emailController.text.toString(),
              password: passwordController.text.toString(),
              fcm_token: token),
          throwException: true,
        );
        if (response != null) {
          final data = response as LoginResponse;
          authService.setLoginData(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isLogin
                  ? 'Login successful!'
                  : 'Account created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
              password: passwordController.text.toString()),
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
