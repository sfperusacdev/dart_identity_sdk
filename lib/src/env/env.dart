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
}
