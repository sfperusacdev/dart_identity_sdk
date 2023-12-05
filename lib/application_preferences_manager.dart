import 'dart:convert';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localPreferencesUniqueKey = "application_preference_manager";

class ApplicationPreferenceManager {
  static final _instance = ApplicationPreferenceManager._private();
  late SharedPreferences _preferences;
  ApplicationPreferenceManager._private();
  factory ApplicationPreferenceManager() => _instance;

  // Estras preferencias no seran eliminadas al hacer clean
  final localKeys = <String>[];

  Future<SharedPreferences> load() async {
    await SessionManagerSDK().init();
    _preferences = SessionManagerSDK().preferences ?? await SharedPreferences.getInstance();
    localKeys.clear();
    final keys = _preferences.getStringList(_localPreferencesUniqueKey);
    localKeys.addAll(keys ?? []);
    return _preferences;
  }

  SharedPreferences get prefrences => _preferences;

  Map<String, dynamic> read(String key) {
    var value = prefrences.getString(key);
    if (value == null) return {};
    var decoded = <String, dynamic>{};
    try {
      decoded = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return decoded;
  }

  Future<bool> write(String key, Map<String, dynamic> value) => _preferences.setString(key, jsonEncode(value));

  List<Map<String, dynamic>> readList(String key) {
    var value = prefrences.getString(key);
    if (value == null) return [];
    var decoded = <Map<String, dynamic>>[];
    try {
      decoded = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return decoded;
  }

  dynamic justRead(String key) {
    var value = prefrences.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  int? getInt(String key) => _preferences.getInt(key);
  bool? getBool(String key) => _preferences.getBool(key);
  double? getDouble(String key) => _preferences.getDouble(key);
  String? getString(String key) => _preferences.getString(key);

  int? readInt(String key) {
    final value = getString(key);
    if (value == null) return null;
    int? num;
    try {
      num = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return num;
  }

  bool? readBool(String key) {
    final value = getString(key);
    if (value == null) return null;
    bool? flag;
    try {
      flag = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return flag;
  }

  double? readDouble(String key) {
    final value = getString(key);
    if (value == null) return null;
    double? number;
    try {
      number = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return number;
  }

  String? readString(String key) {
    final value = getString(key);
    if (value == null) return null;
    String? str;
    try {
      str = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return str;
  }

  ////
  Future<bool> setInt(String key, int value) {
    var results = _preferences.setInt(key, value);
    if (localKeys.contains(key)) return results;
    localKeys.add(key);
    return results;
  }

  Future<bool> setString(String key, String value) {
    var results = _preferences.setString(key, jsonEncode(value));
    if (localKeys.contains(key)) return results;
    localKeys.add(key);
    return results;
  }

  Future<bool> setDouble(String key, double value) {
    var results = _preferences.setDouble(key, value);
    if (localKeys.contains(key)) return results;
    localKeys.add(key);
    return results;
  }

  Future<bool> setBool(String key, bool value) {
    var results = _preferences.setBool(key, value);
    if (localKeys.contains(key)) return results;
    localKeys.add(key);
    return results;
  }

  Future<bool> setFromMap(Map<String, dynamic> map) async {
    final futures = <Future<bool>>[];
    for (var key in map.keys) {
      futures.add(prefrences.setString(key, jsonEncode(map[key])));
    }
    var results = await Future.wait(futures);
    for (var r in results) {
      if (!r) return false;
    }
    return true;
  }
}
