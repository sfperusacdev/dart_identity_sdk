import 'package:dart_identity_sdk/bases/storage/storer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemStorageManager {
  static final _instance = SystemStorageManager._private();
  SharedPreferences? _preferences;
  SystemStorageManager._private();
  factory SystemStorageManager() => _instance;

  void setPreferencias(SharedPreferences preferencias) {
    _preferences = preferencias;
  }

  SharedPreferences get prefrences => _preferences!;

  final Map<Type, Object> _storedinstances = <Type, Object>{};
  addprovide<T extends Storer>(T Function(SharedPreferences preferences) creator) {
    _storedinstances[T] = creator(_preferences!);
  }

  T instance<T extends Storer>() {
    return _storedinstances[T] as T;
  }
}
