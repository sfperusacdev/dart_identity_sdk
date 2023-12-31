import 'package:dart_identity_sdk/src/bases/storage/storer.dart';

class SelectedSucursalStorage extends PreferenceStorer<String> {
  final String _key = "SelectedSucursalStorage";
  SelectedSucursalStorage(super.preferences);
  @override
  String? getValue() {
    return super.preferences.getString(_key);
  }

  @override
  Future<void> setValue(String value) async {
    await super.preferences.setString(_key, value);
  }

  @override
  void clean() => super.preferences.remove(_key);
}
