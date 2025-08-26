import 'package:ai_notes_taker/models/response/login_response.dart';
import 'package:stacked/stacked.dart';

import '../../app/app.locator.dart';
import 'app_shared_pref_service.dart';

class AppAuthService with ListenableServiceMixin {
  final String _authDataKey = "AUTH_PREF";
  final String _loginDataKey = "LOGIN_PREF";
  final String _userTokenKey = "TOKEN_PREF";
  final String _emailKey = "email_KEY";
  final String _passwordKey = "password_KEY";

  final ReactiveValue<LoginResponse?> _loginData = ReactiveValue(null);

  LoginResponse? get loginData => _loginData.value;

  set loginData(response) {
    setLoginData(response);
  }

  final ReactiveValue<String?> _userToken = ReactiveValue(null);

  String? get userToken => _userToken.value;

  set userToken(response) {
    setUserToken(response);
  }

  final ReactiveValue<String?> _email = ReactiveValue(null);

  String? get email => _email.value;

  set email(response) {
    setEmail(response);
  }

  final ReactiveValue<String?> _password = ReactiveValue(null);

  String? get password => _password.value;

  set password(response) {
    setPassword(response);
  }

  final ReactiveValue<bool?> _isGuestMode = ReactiveValue(true);

  bool? get isGuestMode => _isGuestMode.value;

  AppAuthService() {
    listenToReactiveValues([
      _loginData,
      _userToken,
    ]);
    init();
  }

  init() async {

    var existingLoginData =
        await locator<AppSharedPrefService>().getMapData(_loginDataKey);
    if (existingLoginData != null) {
      _loginData.value = LoginResponse.fromJson(existingLoginData);
    }
    var existingUserToken =
        await locator<AppSharedPrefService>().getString(_userTokenKey);
    if (existingUserToken != null) {
      _userToken.value = existingUserToken;
    }
  }

  Future<void> setUserToken(String response) async {
    _userToken.value = response;
    await locator<AppSharedPrefService>().setString(_userTokenKey, response);
  }

  Future<void> setEmail(String response) async {
    _email.value = response;
    await locator<AppSharedPrefService>().setString(_emailKey, response);
  }

  Future<void> setPassword(String response) async {
    _password.value = response;
    await locator<AppSharedPrefService>().setString(_passwordKey, response);
  }

  Future<void> setLoginData(LoginResponse response) async {
    _loginData.value = response;
    final jsonData = response.toJson();
    print("Saving login data: $jsonData"); // Debug print
    await locator<AppSharedPrefService>().setMapData(_loginDataKey, jsonData);
  }

  resetAuthData() async {
    // Store email and password temporarily
    String? tempEmail = _email.value;
    String? tempPassword = _password.value;

    _loginData.value = null;
    await locator<AppSharedPrefService>().removeData(_authDataKey);
    await locator<AppSharedPrefService>().removeData(_loginDataKey);

    // Restore email and password
    _email.value = tempEmail;
    _password.value = tempPassword;
  }
}
