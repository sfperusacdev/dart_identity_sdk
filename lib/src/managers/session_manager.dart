import 'dart:convert';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/entities/refresh_token_response.dart';
import 'package:dart_identity_sdk/src/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

const _sessionStorageKey = "dart_identity_sdk_session_storage";

class SessionManagerSDK {
  static IdentitySessionResponse? _session;
  static String? _identityURL;

  static bool _firstOpen = false;

  static IdentitySessionResponse? getCurrentSession() {
    if (_session != null) return _session;
    var raw = AppPreferences.global.getString(_sessionStorageKey);
    if (raw == null || raw.isEmpty) return null;
    _session = IdentitySessionResponse.fromJson(raw);
    return _session;
  }

  static void setIdentityServerURL(String url) {
    _identityURL = url;
  }

  static String? findServiceLocation(String serviceID) {
    final session = getCurrentSession();
    final locations = session?.locations ?? [];
    final index =
        locations.indexWhere((element) => element.codigo == serviceID);
    if (index == -1) return null;
    return locations[index].location;
  }

  static List<String> findCompanyBranchs() {
    final session = getCurrentSession();
    final sucursales = session?.sucursales ?? [];
    return sucursales.map((s) => s.code ?? "").toList();
  }

  static (List<String>, bool) checkDependencies(List<String> dependencies) {
    final session = getCurrentSession();
    final locations = session?.locations ?? [];
    var missing = <String>[];
    for (var service in dependencies) {
      final index = locations.indexWhere((l) => l.codigo == service);
      if (index == -1 ||
          locations[index].location == null ||
          locations[index].location!.isEmpty) {
        missing.add(service);
      }
    }
    return (missing, missing.isEmpty);
  }

  static String? getToken() => _session?.token;

  static String getLicenceCode() => _session?.device?.companyLicenceCode ?? "";

  static String? getProfileID() => _session?.profileID;

  static String getCompanyCode() => _session?.session?.company ?? "";

  static String? getUsername() => _session?.usuario?.username;

  static String? getReferenceCode() => _session?.usuario?.referenceCode;

  static DateTime? getLastLoginDate() {
    final timestamp = _session?.timeStamp;
    return (timestamp != null)
        ? DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
        : null;
  }

  static bool hasValidSession({bool Function(DateTime? loginDate)? criteria}) {
    if (getCurrentSession()?.timeStamp == null) return false;
    final lastLogin = getLastLoginDate();
    if (criteria != null) return criteria(lastLogin);
    final last = intl.DateFormat('yyyy-MM-dd').format(lastLogin!.toLocal());
    final now = intl.DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
    return now == last;
  }

  static bool hasPerm(String permission) {
    final permissions = getCurrentSession()?.session?.permissions ?? [];
    return permissions.any((p) => p.id == permission);
  }

  static bool hasPermOnBranch(String permission, String branch) {
    final permissions = getCurrentSession()?.session?.permissions ?? [];
    return permissions.any(
        (p) => p.id == permission && (p.companyBrances ?? []).contains(branch));
  }

  static List<String> getSubordinates() {
    return getCurrentSession()?.session?.subordinates ?? [];
  }

  static List<String> getSupervisors() {
    return getCurrentSession()?.session?.supervisors ?? [];
  }

  static Future<void> logout(BuildContext context) async {
    _session = null;
    await AppPreferences.global.remove(_sessionStorageKey);
    if (context.mounted) context.go(LoginPage.path);
    _firstOpen = false;
  }

  static Future<void> login({
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
    final response = await _postLoginRequest(
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
    _firstOpen = true;
    await _persistSession(session.copyWith(profileID: profileID));
  }

  static bool get ifFirstOpen => _firstOpen;

  static Future<void> refreshToken() async {
    final currentSession = getCurrentSession();
    if (currentSession == null || !hasValidSession()) return;
    final uri = Uri.tryParse("$_identityURL/refresh-token");
    if (uri == null) {
      throw Exception("($_identityURL/refresh-token), no es una url valida");
    }

    final response = await _refreshTokenRequest(
      uri: uri,
      currentToken: currentSession.token ?? "",
    );

    final updated = currentSession.copyWith(
      token: response.token,
      date: response.date,
      timeStamp: response.timeStamp,
    );

    await _persistSession(updated);
  }

  static Future<void> _persistSession(IdentitySessionResponse session) async {
    await AppPreferences.global.setString(_sessionStorageKey, session.toJson());
    _session = session;
  }
}

class _ApiErrorResponse implements Exception {
  final String _message;
  _ApiErrorResponse(this._message);
  @override
  String toString() => _message;
}

Future<RefreshTokenResponse> _refreshTokenRequest({
  required Uri uri,
  required String currentToken,
}) async {
  final client = http.Client();
  try {
    final response = await client.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        'Authorization': currentToken
      },
    );
    final decoded = json.decode(response.body);
    if ((response.statusCode / 100).truncate() != 2) {
      throw _ApiErrorResponse(
          decoded["message"] ?? 'Error desconocido en la API.');
    }
    return RefreshTokenResponse.fromMap(decoded["data"]);
  } catch (e) {
    if (e is _ApiErrorResponse) rethrow;
    if (e.toString().contains('SocketException')) {
      throw Exception(
          'Error de conexión a Internet o con el servicio. Verifica tu conexión.');
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

Future _postLoginRequest({
  required Uri uri,
  Object? payload = const {},
}) async {
  final client = http.Client();
  try {
    final response = await client.post(
      uri,
      body: jsonEncode(payload),
      headers: {"Content-Type": "application/json"},
    );
    final decoded = json.decode(response.body);
    if ((response.statusCode / 100).truncate() != 2) {
      throw _ApiErrorResponse(
          decoded["message"] ?? 'Error desconocido en la API.');
    }
    return decoded["data"];
  } catch (e) {
    if (e is _ApiErrorResponse) rethrow;
    if (e.toString().contains('SocketException')) {
      throw Exception(
          'Error de conexión a Internet o con el servicio. Verifica tu conexión.');
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
