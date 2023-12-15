import 'dart:convert';
import 'package:dart_identity_sdk/src/bases/storage/storer.dart';
import 'package:devappsdk2/devappsdk.dart';
import 'package:flutter/foundation.dart';

var _identityApp = "";
const _preferenciasService = "preferencias.server";
const _globalIdentityServerAddress = "https://api.identity2.sfperusac.com";
const _globalPreferencesServerAddress = "https://api.pb.sfperusac.com";

void setApplicationID(String id) => _identityApp = id;

class ServerSettings {
  String? identityServiceAddress;
  String? preferenciasServiceAddress;

  ServerSettings({identityServiceAddress, preferenciasServiceAddress});
  ServerSettings.fromJson(Map<String, dynamic> json) {
    identityServiceAddress = json['service_address'];
    preferenciasServiceAddress = json['preferencia_address'];
  }

  ServerSettings.zero()
      : identityServiceAddress = "",
        preferenciasServiceAddress = "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_address'] = identityServiceAddress;
    data['preferencia_address'] = preferenciasServiceAddress;
    return data;
  }

  factory ServerSettings.defaultValues() {
    return ServerSettings(
      identityServiceAddress: _globalIdentityServerAddress,
      preferenciasServiceAddress: _globalPreferencesServerAddress,
    );
  }
  Future<String> recoveryIndentityServiceAddress() async {
    var valueToReturn = identityServiceAddress ?? _globalIdentityServerAddress;
    if (kDebugMode | kProfileMode) {
      var message = 'la variable `$_identityApp` no está definida';
      final devapp = DevAppManager();
      final value = await devapp.readValue(_identityApp);
      if (value == null) throw Exception(message);
      valueToReturn = value;
    }
    return valueToReturn;
  }

  Future<String> recoveryPreferenciaServiceAddress() async {
    var valueToReturn = preferenciasServiceAddress ?? _globalPreferencesServerAddress;
    if (kDebugMode | kProfileMode) {
      const message = 'la variable `preferencias.server` no está definida';
      final devapp = DevAppManager();
      final value = await devapp.readValue(_preferenciasService);
      if (value == null) throw Exception(message);
      valueToReturn = value;
    }
    return valueToReturn;
  }

  ServerSettings copyWith({
    String? identityServiceAddress,
    String? preferenciasServiceAddress,
  }) {
    return ServerSettings(
      identityServiceAddress: identityServiceAddress ?? identityServiceAddress,
      preferenciasServiceAddress: preferenciasServiceAddress ?? preferenciasServiceAddress,
    );
  }

  String get appID => _identityApp;
}

class ServerSettingsSorage extends PreferenceStorer<ServerSettings> {
  final String _key = "ServerSettingsSorage";

  ServerSettingsSorage(super.preferences);

  @override
  ServerSettings? getValue() {
    var json = super.preferences.getString(_key);
    if (json == null) return ServerSettings.defaultValues();
    return ServerSettings.fromJson(jsonDecode(json));
  }

  @override
  void setValue(ServerSettings value) {
    super.preferences.setString(_key, jsonEncode(value.toJson()));
  }

  @override
  void clean() => super.preferences.remove(_key);
}
