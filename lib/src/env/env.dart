import 'package:flutter_dotenv/flutter_dotenv.dart';

const _globalIdentityServerAddress = "https://api.identity2.sfperusac.com";
const _globalPreferencesServerAddress = "https://console.sfperusac.com";

class EnvConfig {
  static late final String _identityApp;
  static late final String? _identityName;
  static bool _isApplicationIDSet = false;

  static void setApplicationID(String id, {String? name}) {
    if (!_isApplicationIDSet) {
      _identityApp = id;
      _identityName = name;
      _isApplicationIDSet = true;
    }
  }

  static String? get appName => _identityName;
  static String get appID => _identityApp;

  static String identityServerUrl() {
    try {
      final value = dotenv.get("IDENTITY_SERVER_URL");
      return value.isEmpty ? _globalIdentityServerAddress : value;
    } catch (_) {
      return _globalIdentityServerAddress;
    }
  }

  static String preferencesServerUrl() {
    try {
      final value = dotenv.get("PREFERENCES_SERVER_URL");
      return value.isEmpty ? _globalPreferencesServerAddress : value;
    } catch (_) {
      return _globalPreferencesServerAddress;
    }
  }
}
