import 'dart:convert';
import 'dart:io';
import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_content_provider/shared_preferences_content_provider.dart';
import 'package:http/http.dart' as http;

abstract class ReadeProvider {
  Future<void> init() async {}
  Future<List<Licence>> licences();
  Future<String> deviceID();
  Future<String> deviceName();
}

class _SharedPreferences implements ReadeProvider {
  static const providerAuthority = "com.sfperusac.manager.provider";
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
    if (value is String && value.trim().isNotEmpty) {
      return licenceFromJson(value.trim());
    }
    return [];
  }
}

class _LocalServer implements ReadeProvider {
  Future<String?> getFunctionalUrl(List<String> urls) async {
    for (String url in urls) {
      try {
        final request = await HttpClient()
            .getUrl(Uri.parse(url))
            .timeout(const Duration(seconds: 2));
        final response =
            await request.close().timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) return url;
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Future<String?> getURL() async {
    final envValue = Platform.environment["LOCAL_IDENTITY_ADDRESS"];
    if (envValue != null) {
      return envValue;
    }
    const defaultUrls = [
      "https://localhost:10206",
      "https://local.identity.sfperusac.com:10206"
    ];
    return await getFunctionalUrl(defaultUrls);
  }

  @override
  Future<String> deviceName() async {
    final url = Uri.parse("${await getURL()}/v1/devicename");
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
    final url = Uri.parse("${await getURL()}/v1/deviceid");
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
    final url = Uri.parse("${await getURL()}/v1/device_licences");
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

class LicenceManagerSDK {
  static late ReadeProvider _reader;
  static bool _wasInited = false;
  static late SharedPreferences _preferences;

  static Future<void> init(SharedPreferences preferences) async {
    if (_wasInited) return;
    if (Platform.isIOS) throw "IOS is not supported";
    _preferences = preferences;
    _reader = (Platform.isAndroid) ? _SharedPreferences() : _LocalServer();
    try {
      await _reader.init();
      await Future.delayed(const Duration(seconds: 1));
      _wasInited = true;
    } catch (err) {
      if (kDebugMode) print("LicenceManagerSDK.init ERROR: ${err.toString()}");
      throw '''Servicio de autentificación no encontrado''';
    }
  }

  static Future<List<Licence>> readLicences() async {
    if (!_wasInited) throw "LicenceManagerSDK was not initialized";
    try {
      final result = await _reader.licences();
      _preferences.setString("IDENTITY_LICENCES", licenceToJson(result));
      return result;
    } catch (err) {
      LOG.printWarn("Device Licenses read from SharedPreferences");
      final stored = _preferences.getString("IDENTITY_LICENCES");
      if (stored == null) rethrow;
      return licenceFromJson(stored);
    }
  }

  static Future<String> deviceID() async {
    if (!_wasInited) throw "LicenceManagerSDK was not initialized";
    try {
      final result = await _reader.deviceID();
      _preferences.setString("IDENTITY_DEVICE_ID", result);
      return result;
    } catch (err) {
      LOG.printWarn("Device ID read from SharedPreferences");
      final stored = _preferences.getString("IDENTITY_DEVICE_ID");
      if (stored == null) rethrow;
      return stored;
    }
  }

  static Future<String> deviceName() async {
    if (!_wasInited) throw "LicenceManagerSDK was not initialized";
    try {
      final result = await _reader.deviceName();
      _preferences.setString("IDENTITY_DEVICE_NAME", result);
      return result;
    } catch (err) {
      LOG.printWarn("Device name read from SharedPreferences");
      final stored = _preferences.getString("IDENTITY_DEVICE_NAME");
      if (stored == null) rethrow;
      return stored;
    }
  }
}

List<Licence> licenceFromJson(String str) =>
    List<Licence>.from(json.decode(str).map((x) => Licence.fromMap(x)));

String licenceToJson(List<Licence> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Licence {
  String? licenceCode;
  String? companyCode;
  String? company;
  bool? allowed;

  Licence({
    this.licenceCode,
    this.companyCode,
    this.company,
    this.allowed,
  });

  Licence copyWith({
    String? licenceCode,
    String? companyCode,
    String? company,
    bool? allowed,
  }) =>
      Licence(
        licenceCode: licenceCode ?? this.licenceCode,
        companyCode: companyCode ?? this.companyCode,
        company: company ?? this.company,
        allowed: allowed ?? this.allowed,
      );

  factory Licence.fromMap(Map<String, dynamic> json) => Licence(
        licenceCode: json["licence_code"],
        companyCode: json["company_code"],
        company: json["company"],
        allowed: json["allowed"],
      );

  Map<String, dynamic> toMap() => {
        "licence_code": licenceCode,
        "company_code": companyCode,
        "company": company,
        "allowed": allowed,
      };
}
