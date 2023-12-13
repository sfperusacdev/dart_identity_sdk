import 'dart:convert';
import 'dart:io';
import 'package:dart_identity_sdk/manager/licence.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences_content_provider/shared_preferences_content_provider.dart';
import 'package:http/http.dart' as http;

abstract class ReadeProvider {
  Future<void> init() async {}
  Future<List<Licence>> licences();
  Future<String> deviceID();
  Future<String> deviceName();
}

class _SharedPreferences implements ReadeProvider {
  static const providerAuthority = "com.sfperusac.licences.provider";
  @override
  Future<String> deviceID() async {
    final value = await SharedPreferencesContentProvider.get("__device_id__");
    if (value is String) return value;
    return "---device-id-not-found---";
  }

  @override
  Future<String> deviceName() async {
    final value = await SharedPreferencesContentProvider.get("__device_name__");
    if (value is String) return value;
    return "--device-name-not-found";
  }

  @override
  Future<void> init() async {
    await SharedPreferencesContentProvider.init(
      providerAuthority: providerAuthority,
    );
  }

  @override
  Future<List<Licence>> licences() async {
    final value = await SharedPreferencesContentProvider.get("licences");
    if (value is String && value.trim().isNotEmpty) return licenceFromJson(value.trim());
    return [];
  }
}

class _LocalServer implements ReadeProvider {
  @override
  Future<String> deviceName() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/devicename");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity DeviceID: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return decoded["data"]["name"] as String;
  }

  @override
  Future<String> deviceID() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/deviceid");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity DeviceID: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return decoded["data"]["id"] as String;
  }

  @override
  Future<List<Licence>> licences() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/device_licences");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity Licences: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return licenceFromJson(jsonEncode(decoded["data"]));
  }

  @override
  Future<void> init() async {}
}

class ManagerSDKF {
  static final ManagerSDKF _singleton = ManagerSDKF._internal();
  factory ManagerSDKF() => _singleton;
  ManagerSDKF._internal();
  late ReadeProvider reader;
  bool _wastInited = false;
  Future<void> init() async {
    if (_wastInited) return;
    if (Platform.isIOS) throw "IOS is not soported";
    reader = (Platform.isAndroid) ? _SharedPreferences() : _LocalServer();
    try {
      await reader.init();
      await Future.delayed(const Duration(seconds: 1));
      _wastInited = true;
    } catch (err) {
      if (kDebugMode) print("ManagerSDKF.init EROR: ${err.toString()}");
      throw '''Servicio de autentificación no encontrado''';
    }
  }

  Future<List<Licence>> readLicences() async {
    await init();
    return await reader.licences();
  }

  Future<String> deviceID() async {
    await init();
    return reader.deviceID();
  }

  Future<String> deviceName() async {
    await init();
    return reader.deviceName();
  }
}
