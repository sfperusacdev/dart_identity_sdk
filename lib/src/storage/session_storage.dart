import 'package:dart_identity_sdk/entities/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  final SharedPreferences _preferences;
  final String _key = "dart_identity_sdk_session_storage";

  SessionStorage(this._preferences);

  IdentitySessionResponse? _session;

  IdentitySessionResponse? get authsession {
    if (_session != null) return _session;
    var jsonString = _preferences.getString(_key);
    if (jsonString == null) return null;
    if (jsonString == "") jsonString = "{}";
    _session = IdentitySessionResponse.fromJson(jsonString);
    return _session;
  }

  Future<void> setValue(IdentitySessionResponse session) async {
    await _preferences.setString(_key, session.toJson());
    _session = session;
  }

  Future<void> clean() async {
    await _preferences.remove(_key);
    _session = null;
  }
}
