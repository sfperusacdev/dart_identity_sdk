import 'dart:convert';

import 'package:dart_identity_sdk/src/bases/storage/storer.dart';

class RequestLogin {
  String? empresa;
  String? username;
  String? password;
  String? deviceId;
  String? licence;

  RequestLogin({this.empresa, this.username, this.password, this.deviceId, this.licence});

  RequestLogin.fromJson(Map<String, dynamic> json) {
    empresa = json['empresa'];
    username = json['username'];
    password = json['password'];
    deviceId = json['device_id'];
    licence = json['licence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['empresa'] = empresa;
    data['username'] = username;
    data['password'] = password;
    data['device_id'] = deviceId;
    data['licence'] = licence;
    return data;
  }
}

class LoginFielsStorage extends PreferenceStorer<RequestLogin> {
  final String _key = "LoginFilesStorage";
  LoginFielsStorage(super.preferences);
  @override
  RequestLogin? getValue() {
    var json = super.preferences.getString(_key);
    if (json == null) return null;
    return RequestLogin.fromJson(jsonDecode(json));
  }

  @override
  void setValue(RequestLogin value) {
    super.preferences.setString(_key, jsonEncode(value.toJson()));
  }

  @override
  void clean() => super.preferences.remove(_key);
}
