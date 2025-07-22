import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class AppPreferencesService with ListenableServiceMixin {
  static const String _languageKey = 'app_language';
  SharedPreferences? _prefs;
  bool _initialized = false;
  String _currentLanguage = 'en';

  AppPreferencesService() {
    listenToReactiveValues([_currentLanguage]);
  }

  Future<void> initializePrefs() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _currentLanguage = _prefs?.getString(_languageKey) ?? 'en';
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!_initialized) await initializePrefs();
    await _prefs?.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
    notifyListeners();
  }

  String getLanguage() {
    return _currentLanguage;
  }
}
