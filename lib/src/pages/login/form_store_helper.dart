import 'dart:convert';

import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/security/settings/login_fields.dart';

class LoginCredentialsStoreHelper {
  static const String _storageKey = "_login_form_fields_state";

  static RequestLogin? load() {
    final jsonString = AppPreferences.global.getString(_storageKey);
    if (jsonString == null) return null;
    return RequestLogin.fromJson(jsonDecode(jsonString));
  }

  static Future<void> save(RequestLogin data) async {
    final encoded = jsonEncode(data.toJson());
    await AppPreferences.global.setString(_storageKey, encoded);
  }

  static Future<void> clear() async {
    await AppPreferences.global.remove(_storageKey);
  }
}
