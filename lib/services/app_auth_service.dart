import 'package:merchant_karandaaz/models/response/login_response.dart';
import 'package:merchant_karandaaz/models/response/partner_type_response.dart';
import 'package:merchant_karandaaz/models/response/qr_token_response.dart';
import 'package:merchant_karandaaz/models/response/token_response.dart';
import 'package:stacked/stacked.dart';

import '../../app/app.locator.dart';
import '../../models/all_data_model.dart';
import 'app_shared_pref_service.dart';

class AppAuthService with ListenableServiceMixin {
  final String _authDataKey = "AUTH_PREF";
  final String _loginDataKey = "LOGIN_PREF";
  final String _userTokenKey = "TOKEN_PREF";
  final String _qrTokenKey = "QR_PREF";
  final String _partnerTypeKey = "PARTNER_TYPE_PREF";
  final String _merchantImageKey = "MERCHANT_IMAGE_PREF";
  final String _emailKey = "email_KEY";
  final String _passwordKey = "password_KEY";
  final String _isBiometricEnableKey = "_isBiometricEnableKey";
  final String _isGuestModeKey = "_isGuestMode";

  final ReactiveValue<TokenResponse?> _tokenData = ReactiveValue(null);

  TokenResponse? get tokenData => _tokenData.value;

  set tokenData(response) {
    setTokenData(response);
  }

  final ReactiveValue<PartnerType?> _partnerTypeData = ReactiveValue(null);

  PartnerType? get partnerTypeData => _partnerTypeData.value;

  set partnerTypeData(response) {
    setPartnerTypeData(response);
  }

  final ReactiveValue<String?> _qrToken = ReactiveValue(null);

  String? get qrTokenData => _qrToken.value;

  set qrTokenData(response) {
    setQrToken(response);
  }

  final ReactiveValue<LoginV2?> _loginData = ReactiveValue(null);

  LoginV2? get loginData => _loginData.value;

  set loginData(response) {
    setLoginData(response);
  }

  final ReactiveValue<String?> _userToken = ReactiveValue(null);

  String? get userToken => _userToken.value;

  set userToken(response) {
    setUserToken(response);
  }

  final ReactiveValue<String?> _merchantImage = ReactiveValue(null);

  String? get merchantImage => _merchantImage.value;

  set merchantImage(response) {
    setMerchantImage(response);
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

  final ReactiveValue<bool?> _isBiometricEnable = ReactiveValue(true);

  bool? get isBiometricEnable => _isBiometricEnable.value;

  set isBiometricEnable(response) {
    setIsBiometricEnable(response);
  }

  final ReactiveValue<bool?> _isGuestMode = ReactiveValue(true);

  bool? get isGuestMode => _isGuestMode.value;

  set isGuestMode(response) {
    setIsBiometricEnable(response);
  }

  AppAuthService() {
    listenToReactiveValues([
      _tokenData,
      _loginData,
      _userToken,
      _qrToken,
      _notificationData,
      _merchantImage,
      _merchantImage,
    ]);
    init();
  }

  init() async {
    var existingData =
        await locator<AppSharedPrefService>().getMapData(_authDataKey);
    if (existingData != null) {
      _tokenData.value = TokenResponse.fromJson(existingData);
    }
    var existingNotifsData =
        await locator<AppSharedPrefService>().getMapData(_notificationDataKey);
    if (existingNotifsData != null) {
      _notificationData.value = AllDataModel.fromJson(existingNotifsData);
    }

    var existingLoginData =
        await locator<AppSharedPrefService>().getMapData(_loginDataKey);
    if (existingLoginData != null) {
      _loginData.value = LoginV2.fromJson(existingLoginData);
    }
    var existingUserToken =
        await locator<AppSharedPrefService>().getString(_userTokenKey);
    if (existingUserToken != null) {
      _userToken.value = existingUserToken;
    }
  }

  Future<void> setTokenData(TokenResponse response) async {
    _tokenData.value = response;
    await locator<AppSharedPrefService>()
        .setMapData(_authDataKey, response.toJson());
  }

  Future<void> setQrToken(String response) async {
    _qrToken.value = response;
    await locator<AppSharedPrefService>().setString(_qrTokenKey, response);
  }

  Future<void> setPartnerTypeData(PartnerType response) async {
    _partnerTypeData.value = response;
    final jsonData = response.toJson();
    await locator<AppSharedPrefService>().setMapData(_partnerTypeKey, jsonData);
  }

  Future<void> setUserToken(String response) async {
    _userToken.value = response;
    await locator<AppSharedPrefService>().setString(_userTokenKey, response);
  }

  Future<void> setMerchantImage(String response) async {
    _merchantImage.value = response;
    await locator<AppSharedPrefService>()
        .setString(_merchantImageKey, response);
  }

  Future<void> setEmail(String response) async {
    _email.value = response;
    await locator<AppSharedPrefService>().setString(_emailKey, response);
  }

  Future<void> setPassword(String response) async {
    _password.value = response;
    await locator<AppSharedPrefService>().setString(_passwordKey, response);
  }

  Future<void> setIsBiometricEnable(bool response) async {
    _isBiometricEnable.value = response;
    await locator<AppSharedPrefService>()
        .setBool(_isBiometricEnableKey, response);
  }

  Future<void> setIsGuestMode(bool response) async {
    _isGuestMode.value = response;
    await locator<AppSharedPrefService>().setBool(_isGuestModeKey, response);
  }

  Future<void> setLoginData(LoginV2 response) async {
    _loginData.value = response;
    final jsonData = response.toJson();
    print("Saving login data: $jsonData"); // Debug print
    await locator<AppSharedPrefService>().setMapData(_loginDataKey, jsonData);
  }

  resetAuthData() async {
    // Store email and password temporarily
    String? tempEmail = _email.value;
    String? tempPassword = _password.value;

    _tokenData.value = null;
    _loginData.value = null;
    _merchantImage.value = null;
    await locator<AppSharedPrefService>().removeData(_authDataKey);
    await locator<AppSharedPrefService>().removeData(_merchantImageKey);
    await locator<AppSharedPrefService>().removeData(_loginDataKey);

    // Restore email and password
    _email.value = tempEmail;
    _password.value = tempPassword;
  }

  final ReactiveValue<AllDataModel?> _notificationData = ReactiveValue(null);

  AllDataModel? get notificationData => _notificationData.value;

  /*set _notificationData(notifyResponse) {
    setAuthData(notifyResponse);
  }*/

  final String _notificationDataKey = "NOTIFICATION_PREF";

  Future<void> setNotifData(AllDataModel loginResponse) async {
    _notificationData.value = loginResponse;
    await locator<AppSharedPrefService>()
        .setMapData(_notificationDataKey, loginResponse.toJson());
  }

  resetNotifData() async {
    _notificationData.value = null;
    await locator<AppSharedPrefService>().removeData(_notificationDataKey);
  }
  resetIsGuestData() async {
    _isGuestMode.value = null;
    await locator<AppSharedPrefService>().removeData(_isGuestModeKey);
  }
}
