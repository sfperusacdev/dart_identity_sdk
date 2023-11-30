import 'package:shared_preferences/shared_preferences.dart';

abstract class Storer<T> {
  void setValue(T value);
  void clean(){}
  T? getValue();
}

abstract class PreferenceStorer<T> extends Storer<T> {
  SharedPreferences preferences;
  PreferenceStorer(this.preferences);
}
