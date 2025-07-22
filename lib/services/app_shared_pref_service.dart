import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPrefService {
  Future<bool?>? setMapData(String key, Map<String, dynamic> data) async {
    var save = await (await SharedPreferences.getInstance())
        .setString(key, jsonEncode(data));
    print(save);
    return save;
  }

  Future<Map<String, dynamic>?>? getMapData(String key) async {
    var data = (await SharedPreferences.getInstance()).getString(key);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<bool?>? setString(String key, String data) async {
    var save = await (await SharedPreferences.getInstance())
        .setString(key, data);
    print(save);
    return save;
  }

  Future<String>? getString(String key) async {
    var data = (await SharedPreferences.getInstance()).getString(key);
    if (data != null) {
      return data;
    }
    return "";
  }

  Future<bool>? removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isBusinessFlow');
    return prefs.remove(key);
  }


  Future<bool?>? setBool(String key, bool data) async {
    var save = await (await SharedPreferences.getInstance())
        .setBool(key, data);
    print(save);
    return save;
  }

  Future<bool>? getBool(String key) async {
    var data = (await SharedPreferences.getInstance()).getBool(key);
    if (data != null) {
      return data;
    }
    return false;
  }

}
