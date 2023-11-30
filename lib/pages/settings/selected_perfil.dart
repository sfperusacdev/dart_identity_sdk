import 'package:dart_identity_sdk/application_preferences_manager.dart';

class SelectedPerfilStore {
  final _key = "SelectedPerfilStore_cjgdt2r0hnna4f6pnoe0";
  final _manager = ApplicationPreferenceManager();
  Future<bool> setPerfilid(String id) => _manager.setString(_key, id);
  String get perfilID => _manager.getString(_key) ?? "";
}
