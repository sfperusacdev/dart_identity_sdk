import 'package:dart_identity_sdk/bases/storage/storer.dart';

class SelectedSucursalStorage extends PreferenceStorer<String> {
  final String _key = "SelectedSucursalStorage";
  SelectedSucursalStorage(super.preferences);
  @override
  String? getValue() {
    return super.preferences.getString(_key);
  }

  @override
  void setValue(String value) {
    super.preferences.setString(_key, value);
  }

  @override
  void clean() => super.preferences.remove(_key);
}
