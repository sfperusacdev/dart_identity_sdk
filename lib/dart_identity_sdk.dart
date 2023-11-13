library dart_identity_sdk;

import 'dart:convert';

import 'package:dart_identity_sdk/entities/entities.dart';
import 'package:dart_identity_sdk/src/storage/session_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

part 'login_post.dart';

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
    if (_storage == null) return;
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

  Future<void> loginOut() async {
    if (_storage == null) return;
    await _storage?.clean();
  }

  Future<void> login({
    required String licence,
    required String deviceid,
    required String empresa,
    required String username,
    required String password,
    required String appID,
    required String appVersion,
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
        "licence": licence,
        "app": appID,
        "version": appVersion,
      },
    );
    final session = IdentitySessionResponse.fromMap(response);
    _storage?.setValue(session);
  }
}
