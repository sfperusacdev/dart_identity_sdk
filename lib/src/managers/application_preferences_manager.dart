// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kdialogs/kdialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dart_identity_sdk/dart_identity_sdk.dart';

const _localPreferencesUniqueKey = "application_preference_manager";

//_P intenta abstraer la gestión de preferencias locales
class _P {
  final SharedPreferences _preferences;
  final bool Function(String key) _containsKey;
  final Future<void> Function(String key) _addkey;
  _P(
    this._preferences, {
    required bool Function(String key) containsKey,
    required Future<void> Function(String key) addkey,
  })  : _containsKey = containsKey,
        _addkey = addkey;

  SharedPreferences get preferences => _preferences;

  Future<bool> write(String key, Map<String, dynamic> value) {
    return _preferences.setString(key, jsonEncode(value));
  }

  int? getInt(String key) => _preferences.getInt(key);
  bool? getBool(String key) => _preferences.getBool(key);
  double? getDouble(String key) => _preferences.getDouble(key);
  String? getString(String key) {
    final value = _preferences.getString(key);
    if (value == null) return value;
    try {
      final decoded = jsonDecode(value);
      if (decoded is String) return decoded;
      return value;
    } catch (err) {
      LOG.printWarn(["application_preferences_manager", err.toString()]);
      return value;
    }
  }

  Future<bool> setInt(String key, int value) {
    var results = _preferences.setInt(key, value);
    if (_containsKey(key)) return results;
    _addkey(key);
    return results;
  }

  Future<bool> setString(String key, String value) {
    var results = _preferences.setString(key, jsonEncode(value));
    if (_containsKey(key)) return results;
    _addkey(key);
    return results;
  }

  Future<bool> setDouble(String key, double value) {
    var results = _preferences.setDouble(key, value);
    if (_containsKey(key)) return results;
    _addkey(key);
    return results;
  }

  Future<bool> setBool(String key, bool value) {
    var results = _preferences.setBool(key, value);
    if (_containsKey(key)) return results;
    _addkey(key);
    return results;
  }
}

class ApplicationPreferenceManager {
  static final _instance = ApplicationPreferenceManager._private();
  late SharedPreferences _preferences;
  // ignore: library_private_types_in_public_api
  late _P P;

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
    P = _P(
      _preferences,
      addkey: (value) async {
        localKeys.add(value);
      },
      containsKey: (value) => localKeys.contains(value),
    );
    return _preferences;
  }

  Map<String, dynamic> read(String key) {
    var value = P.preferences.getString(key);
    if (value == null) return {};
    var decoded = <String, dynamic>{};
    try {
      decoded = jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
    return decoded;
  }

  List<Map<String, dynamic>> readList(String key) {
    var value = P.preferences.getString(key);
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
    var value = P.preferences.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  int? readInt(String key) {
    final value = P.getString(key);
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
    final value = P.getString(key);
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
    final value = P.getString(key);
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
    final value = P.getString(key);
    if (value == null) return null;
    String? str;
    try {
      final decoded = jsonDecode(value);
      if (decoded is String) return decoded;
      return value;
    } catch (err) {
      debugPrint(err.toString());
    }
    return str;
  }

  Future<bool> _setFromMap(Map<String, dynamic> map) async {
    final futures = <Future<bool>>[];
    for (var key in map.keys) {
      futures.add(P.preferences.setString(key, jsonEncode(map[key])));
    }
    var results = await Future.wait(futures);
    for (var r in results) {
      if (!r) return false;
    }
    return true;
  }

  Future<bool?> syncPreferencesWithLoaderIndicator(BuildContext context) async {
    return showAsyncProgressKDialog<bool>(context, doProcess: () async {
      final wait = syncPreferences();
      final delay = Future.delayed(const Duration(seconds: 1));
      await Future.wait([wait, delay]);
      return await wait;
    });
  }

  Future<bool> syncPreferences() async {
    final sessionManager = SessionManagerSDK();
    final profileID = sessionManager.profileID();
    if (profileID == null || profileID.isEmpty) return false;
    final perfilService = AppPerfilService();
    final preferencias = await perfilService.findPreferencias(profileID);
    final map = <String, dynamic>{};
    for (int i = 0; i < preferencias.length; i++) {
      final preff = preferencias[i];
      preff.identiticador ??= "unknow";
      map[preff.identiticador!.trim()] = preff.valor;
    }
    final handle = ApplicationPreferenceManager();
    final result = await handle._setFromMap(map);
    LOG.printInfo(["SYNC-PREFERENCES:", result]);
    return result;
  }
}
