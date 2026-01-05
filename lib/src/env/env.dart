import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static Future<String> identityServerUrl() async {
    final identity = await LicenceManagerSDK.identityUrl();
    final value = dotenv.maybeGet("IDENTITY_SERVER_URL");
    return (value == null || value.isEmpty) ? identity : value;
  }

  static Future<String> preferencesServerUrl() async {
    final preferences = await LicenceManagerSDK.preferencesUrl();
    final value = dotenv.maybeGet("PREFERENCES_SERVER_URL");
    return (value == null || value.isEmpty) ? preferences : value;
  }
}
