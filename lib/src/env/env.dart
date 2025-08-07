import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String? identityServerUrl() {
    try {
      final value = dotenv.get("IDENTITY_SERVER_URL");
      return value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }

  static String? preferencesServerUrl() {
    try {
      final value = dotenv.get("PREFERENCES_SERVER_URL");
      return value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }
}
