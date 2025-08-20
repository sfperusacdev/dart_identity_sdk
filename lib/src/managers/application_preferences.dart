import 'dart:convert';

import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:dart_identity_sdk/src/managers/session_manager.dart';
import 'package:dart_identity_sdk/src/services/pb_perfiles.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesDomainNotSet = Exception(
  'AppPreferences domain is not set. Please configure it before accessing',
);

class PreferencesWrapper {
  final SharedPreferences _prefs;
  String? _domain;
  PreferencesWrapper(this._prefs);
  Future<void> setDomain(String domain) async {
    _domain = domain.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  SharedPreferences get global => _prefs;

  String get domain {
    if (_domain == null) throw appPreferencesDomainNotSet;
    return _domain!;
  }

  String _wrapKey(String key) => "$domain.$key";

//-------------------------------------------------------------------------//

  Object? get(String key) => global.get(_wrapKey(key));
  bool? getBool(String key) => global.getBool(_wrapKey(key));
  int? getInt(String key) => global.getInt(_wrapKey(key));
  double? getDouble(String key) => global.getDouble(_wrapKey(key));
  String? getString(String key) => global.getString(_wrapKey(key));

  List<String>? getStringList(String key) =>
      global.getStringList(_wrapKey(key));

  Future<bool> setBool(String key, bool value) =>
      global.setBool(_wrapKey(key), value);

  Future<bool> setInt(String key, int value) =>
      global.setInt(_wrapKey(key), value);

  Future<bool> setDouble(String key, double value) =>
      global.setDouble(_wrapKey(key), value);

  Future<bool> setString(String key, String value) =>
      global.setString(_wrapKey(key), value);

  Future<bool> setStringList(String key, List<String> value) =>
      global.setStringList(_wrapKey(key), value);

  Future<bool> remove(String key) => global.remove(_wrapKey(key));

  bool containsKey(String key) => global.containsKey(_wrapKey(key));
  // helper
  Future<bool> setEntry(String key, String code, String description) async {
    final data = {
      'code': code,
      'description': description,
    };
    return setString(key, jsonEncode(data));
  }

  Future<(String?, String?)> getEntry(String key) async {
    final raw = getString(key);
    if (raw == null) return (null, null);
    final Map<String, dynamic> data = jsonDecode(raw);
    final code = data['code'];
    final description = data['description'];
    if (code is String && description is String) return (code, description);
    return (null, null);
  }

  //--------//
  Future<bool> _saveMapToStorage(Map<String, dynamic> map) async {
    final futures = <Future<bool>>[];
    for (var key in map.keys) {
      futures.add(global.setString(_wrapKey(key), jsonEncode(map[key])));
    }
    var results = await Future.wait(futures);
    for (var result in results) {
      if (!result) return false;
    }
    return true;
  }
}

class AppPreferences {
  static late PreferencesWrapper _preferencesWrapper;

  static Future<void> initialize() async {
    final instantence = await SharedPreferences.getInstance();
    _preferencesWrapper = PreferencesWrapper(instantence);
  }

  static SharedPreferences get global => _preferencesWrapper.global;
  static PreferencesWrapper get private => _preferencesWrapper;

  static Future<void> setUpDomain(String domain) async =>
      private.setDomain(domain);

  //-----------------------------------SYNC DATA--------------------------------------//
  static Future<bool?> syncPreferencesWithLoaderIndicator(
      BuildContext context) async {
    return showAsyncProgressKDialog<bool>(
      context,
      doProcess: () async {
        final syncFuture = syncPreferences();
        await Future.wait([
          syncFuture,
          Future.delayed(const Duration(seconds: 1)),
        ]);
        final success = await syncFuture;
        if (success) return true;
        throw 'Ocurrió un error al sincronizar las preferencias';
      },
    );
  }

  static Future<bool> syncPreferences() async {
    try {
      final profileId = SessionManagerSDK.getProfileID();
      if (profileId == null || profileId.isEmpty) return false;

      final perfilService = AppPerfilService();
      final preferencias = await perfilService.findPreferencias(profileId);

      final preferencesMap = <String, dynamic>{};
      for (final pref in preferencias) {
        String key = pref.identiticador?.trim() ?? '';
        if (key.isEmpty) key = 'unknown';
        preferencesMap[key] = pref.valor;
      }

      final success = await private._saveMapToStorage(preferencesMap);
      LOG.printInfo(['SYNC_PREFERENCES:', success]);
      return success;
    } catch (err) {
      LOG.printError(['SYNC_PREFERENCES_ERROR:', err.toString()]);
      return false;
    }
  }

  //-----------------------------------ACCESS DATA--------------------------------------//
  static Map<String, dynamic> readMap(String key) {
    final value = private.getString(key);
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (err) {
      debugPrint(err.toString());
      return {};
    }
  }

  static List<Map<String, dynamic>> readList(String key) {
    final value = private.getString(key);
    if (value == null) return [];
    try {
      final decoded = jsonDecode(value);
      return decoded is List ? List<Map<String, dynamic>>.from(decoded) : [];
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }

  static dynamic readRaw(String key) {
    final value = private.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value);
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  static int? readInt(String key) {
    final value = private.getString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is int ? decoded : null;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  static bool? readBool(String key) {
    final value = private.getString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is bool ? decoded : null;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  static double? readDouble(String key) {
    final value = private.getString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is double ? decoded : null;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  static String? readString(String key) {
    final value = private.getString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is String ? decoded : value;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }
}
