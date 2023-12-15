import 'dart:convert';

import 'package:dart_identity_sdk/src/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/src/entities/entities.dart';
import 'package:dart_identity_sdk/src/pages/login/login_page.dart';
import 'package:dart_identity_sdk/src/security/selected_sucursal_storage.dart';
import 'package:dart_identity_sdk/src/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

class SessionManagerSDK {
  SessionManagerSDK._privateConstructor();
  static final SessionManagerSDK _instance = SessionManagerSDK._privateConstructor();
  factory SessionManagerSDK() => _instance;

  SharedPreferences? _preferences;
  SharedPreferences? get preferences => _preferences;

  SessionStorage? _storage;

  String? _identityURL;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    if (_preferences == null) return;
    _storage = SessionStorage(_preferences!);
    _storage!.authsession;
  }

  void setIdentityServerURL(String url) {
    _identityURL = url;
  }

  String? findServiceLocation(String serviceID) {
    final locations = _storage?.authsession?.locations ?? [];
    final index = locations.indexWhere((element) => element.codigo == serviceID);
    if (index == -1) return null;
    return locations[index].location;
  }

  List<String> findCompanyBranchs() {
    final sucursales = _storage?.authsession?.sucursales ?? [];
    return sucursales.map((s) => s.code ?? "").toList();
  }

  (List<String>, bool) checkDependencies(List<String> dependencies) {
    final locations = _storage?.authsession?.locations ?? [];
    var notfound = <String>[];
    for (var service in dependencies) {
      var index = locations.indexWhere((elm) => elm.codigo == service);
      if (index == -1) {
        notfound.add(service);
      } else if (locations[index].location == null) {
        notfound.add(service);
      } else if (locations[index].location == "") {
        notfound.add(service);
      }
    }
    return (notfound, notfound.isEmpty);
  }

  String? getToken() => _storage?.authsession?.token;
  String? profileID() => _storage?.authsession?.profileID;
  String? getCompanyCode() => _storage?.authsession?.session?.company ?? "";
  String? getUsername() => _storage?.authsession?.usuario?.username;
  String? getReferenceCode() => _storage?.authsession?.usuario?.referenceCode;

  DateTime? lastLoginDate() => _storage?.authsession?.date;

  bool isLoginActive() {
    if (_storage?.authsession == null) return false;
    if (_storage?.authsession?.timeStamp == null) return false;
    if (_storage?.authsession?.date == null) return false;
    final now = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final last = intl.DateFormat('yyyy-MM-dd').format(lastLoginDate()!);
    return now == last;
  }

  bool hasPerm(String permission) {
    final authsession = _storage?.authsession;
    if (authsession == null) return false;
    final permissions = authsession.session?.permissions ?? [];
    for (var p in permissions) {
      if (p.id == permission) return true;
    }
    return false;
  }

  bool hasPermOnBranch(String permission, String branch) {
    final authsession = _storage?.authsession;
    if (authsession == null) return false;
    final permissions = authsession.session?.permissions ?? [];
    for (var p in permissions) {
      if (p.id == permission) {
        final branchs = p.companyBrances ?? [];
        for (var b in branchs) {
          if (b == branch) return true;
        }
      }
    }
    return false;
  }

  List<String> getSubordinates() {
    return _storage?.authsession?.session?.subordinates ?? [];
  }

  List<String> getSupervisors() {
    return _storage?.authsession?.session?.supervisors ?? [];
  }

  Future<void> goOut(BuildContext context) async {
    await loginOut();
    if (context.mounted) context.go(LoginPage.path);
  }

  Future<void> loginOut() async {
    SystemStorageManager().instance<SelectedSucursalStorage>().clean();
    if (_storage == null) return;
    await _storage?.clean();
  }

  Future<void> login({
    required String licence,
    required String deviceid,
    required String deviceName,
    required String empresa,
    required String username,
    required String password,
    required String appID,
    required String appVersion,
    required String profileID,
  }) async {
    final uri = Uri.tryParse(_identityURL ?? "");
    if (uri == null) throw Exception("($_identityURL), no es una url valida");
    final response = await _postlogin(
      uri: uri,
      payload: {
        "empresa": empresa,
        "username": username,
        "password": password,
        "device_id": deviceid,
        "device_name": deviceName,
        "licence": licence,
        "app": appID,
        "version": appVersion,
        "profile_id": profileID,
      },
    );
    final session = IdentitySessionResponse.fromMap(response);
    await _storage?.setValue(session.copyWith(profileID: profileID));
  }
}

class _ApiErrorResponse implements Exception {
  final String _message;
  _ApiErrorResponse(this._message);
  @override
  String toString() => _message;
}

Future _postlogin({
  required Uri uri,
  Object? payload = const {},
}) async {
  var client = http.Client();
  try {
    final response = await client.post(
      uri,
      body: jsonEncode(payload),
      headers: {"Content-Type": "application/json"},
    );
    final decoded = json.decode(response.body);
    if ((response.statusCode / 100).truncate() != 2) {
      throw _ApiErrorResponse(decoded["message"] ?? 'Error desconocido en la API.');
    }
    return decoded["data"];
  } catch (e) {
    if (e is _ApiErrorResponse) rethrow;
    if (e.toString().contains('SocketException')) {
      throw Exception('Error de conexión a Internet o con el servicio. Verifica tu conexión.');
    } else if (e.toString().contains('HttpException')) {
      throw Exception('Error en la solicitud HTTP. Comprueba la URL.');
    } else if (e.toString().contains('FormatException')) {
      throw Exception('Error de formato. La respuesta no es un JSON válido.');
    } else {
      throw Exception('Otro tipo de error. Comunícate con el soporte técnico.');
    }
  } finally {
    client.close();
  }
}
