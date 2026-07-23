import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dart_identity_sdk/src/bases/services.dart';
import 'package:dart_identity_sdk/src/device_info.dart';
import 'package:dart_identity_sdk/src/env/env.dart';
import 'package:dart_identity_sdk/src/managers/licence_manager.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

typedef ApkInstaller = Future<void> Function(String apkPath);
typedef AppUpdateDownloadProgress = void Function(
  int downloadedBytes,
  int? totalBytes,
);

class AppUpdateInstallPermissionDenied implements Exception {
  final String message;

  AppUpdateInstallPermissionDenied([this.message = 'Permiso denegado']);

  @override
  String toString() => message;
}

class AppUpdateOpenSettingsUnavailable implements Exception {
  final String message;

  AppUpdateOpenSettingsUnavailable([
    this.message =
        'No se pudo abrir la configuracion automaticamente. Abre Ajustes > Apps > esta aplicacion > Instalar apps desconocidas y activa el permiso.',
  ]);

  @override
  String toString() => message;
}

class AppReleaseApk {
  final int? id;
  final String name;
  final int? size;
  final String? contentType;

  AppReleaseApk({
    required this.id,
    required this.name,
    required this.size,
    required this.contentType,
  });

  factory AppReleaseApk.fromMap(Map<String, dynamic> map) {
    return AppReleaseApk(
      id: map['id'] is int ? map['id'] as int : null,
      name: map['name']?.toString() ?? 'app-release.apk',
      size: map['size'] is int ? map['size'] as int : null,
      contentType: map['content_type']?.toString(),
    );
  }
}

class AppRelease {
  final String version;
  final String name;
  final DateTime? publishedAt;
  final AppReleaseApk apk;

  AppRelease({
    required this.version,
    required this.name,
    required this.publishedAt,
    required this.apk,
  });

  factory AppRelease.fromMap(Map<String, dynamic> map) {
    final apk = map['apk'];
    if (apk is! Map<String, dynamic>) {
      throw 'La release no contiene un APK valido';
    }
    return AppRelease(
      version: map['version']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      publishedAt: DateTime.tryParse(map['published_at']?.toString() ?? ''),
      apk: AppReleaseApk.fromMap(apk),
    );
  }
}

class AppUpdateCheckResult {
  final AppRelease? release;
  final String currentVersion;

  AppUpdateCheckResult({
    required this.release,
    required this.currentVersion,
  });

  bool get hasUpdate => release != null;
}

class AppUpdateService {
  static ApkInstaller? _customInstaller;

  static void setInstaller(ApkInstaller? installer) {
    _customInstaller = installer;
  }

  Future<AppUpdateCheckResult> checkForUpdate() async {
    if (!Platform.isAndroid) {
      throw 'Las actualizaciones APK solo estan disponibles en Android';
    }

    final releases = await _fetchReleases();
    releases.sort((a, b) => _compareVersions(b.version, a.version));
    final latest = releases.isEmpty ? null : releases.first;
    final currentVersion = ApplicationInfo.appVersion;

    if (latest == null ||
        _compareVersions(latest.version, currentVersion) <= 0) {
      return AppUpdateCheckResult(
        release: null,
        currentVersion: currentVersion,
      );
    }

    return AppUpdateCheckResult(
      release: latest,
      currentVersion: currentVersion,
    );
  }

  Future<AppUpdateCheckResult> checkForUpdateSilently() async {
    try {
      return await checkForUpdate();
    } catch (_) {
      return AppUpdateCheckResult(
        release: null,
        currentVersion: ApplicationInfo.appVersion,
      );
    }
  }

  Future<String> downloadApk(
    AppRelease release, {
    AppUpdateDownloadProgress? onProgress,
  }) async {
    final uri = ApiService.buildUri(
      await LicenceManagerSDK.preferencesUrl(),
      '/v1/api/releases/${Uri.encodeComponent(EnvConfig.appID)}/${Uri.encodeComponent(release.version)}/download',
    );
    final directory = await getTemporaryDirectory();
    final apkName = _safeApkName(release);
    final file = File('${directory.path}/$apkName');

    if (await _isDownloadedApk(file, release)) {
      final size = await file.length();
      onProgress?.call(size, size);
      return file.path;
    }

    if (await file.exists()) await file.delete();

    await _download(
      uri: uri,
      file: file,
      expectedBytes: release.apk.size,
      onProgress: onProgress,
    );
    return file.path;
  }

  Future<String?> downloadedApkPath(AppRelease release) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_safeApkName(release)}');
    if (await _isDownloadedApk(file, release)) return file.path;
    return null;
  }

  Future<void> installApk(String apkPath) async {
    final installer = _customInstaller ?? _defaultInstaller;
    await installer(apkPath);
  }

  Future<void> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
        data: 'package:${info.packageName}',
      );
      await intent.launch();
    } on MissingPluginException {
      throw AppUpdateOpenSettingsUnavailable();
    }
  }

  Future<List<AppRelease>> _fetchReleases() async {
    final uri = ApiService.buildUri(
      await LicenceManagerSDK.preferencesUrl(),
      '/v1/api/releases/${Uri.encodeComponent(EnvConfig.appID)}',
    );
    final result = await ApiService.get(withUri: uri);
    if (result is! List) return [];
    return result
        .whereType<Map<String, dynamic>>()
        .map(AppRelease.fromMap)
        .where((release) => release.version.isNotEmpty)
        .toList();
  }

  static Future<void> _defaultInstaller(String apkPath) async {
    final result = await OpenFile.open(
      apkPath,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      if (_isPermissionDenied(result.message)) {
        throw AppUpdateInstallPermissionDenied(result.message);
      }
      throw result.message;
    }
  }

  static Future<void> _download({
    required Uri uri,
    required File file,
    required int? expectedBytes,
    AppUpdateDownloadProgress? onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', uri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': '',
          'X-Origin': 'android:${EnvConfig.appID}',
        });

      final response = await client.send(request).timeout(
            const Duration(minutes: 10),
          );

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw _apiDownloadError(body);
      }

      var downloaded = 0;
      final total = expectedBytes ?? response.contentLength;
      onProgress?.call(downloaded, total);

      final sink = file.openWrite(mode: FileMode.write);
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          downloaded += chunk.length;
          onProgress?.call(downloaded, total);
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      if (total != null && downloaded < total) {
        throw 'Descarga incompleta. Vuelve a intentar para descargar el APK nuevamente.';
      }
    } on TimeoutException {
      throw 'La descarga tomo demasiado tiempo. Vuelve a intentar para descargar el APK nuevamente.';
    } on SocketException {
      throw 'Error de conexion. Vuelve a intentar para descargar el APK nuevamente.';
    } finally {
      client.close();
    }
  }

  static Future<bool> _isDownloadedApk(File file, AppRelease release) async {
    if (!await file.exists()) return false;
    final size = await file.length();
    final expectedSize = release.apk.size;
    if (expectedSize == null || expectedSize <= 0) return size > 0;
    return size == expectedSize;
  }

  static String _apiDownloadError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return 'No se pudo descargar la actualizacion.';
  }

  static bool _isPermissionDenied(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('permission') ||
        normalized.contains('permiso') ||
        normalized.contains('denied') ||
        normalized.contains('not allowed') ||
        normalized.contains('unknown sources');
  }

  static String _safeApkName(AppRelease release) {
    final version = release.version.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final apkName = release.apk.name.trim().isEmpty
        ? 'app-release.apk'
        : release.apk.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '${EnvConfig.appID}-$version-$apkName';
  }

  static int _compareVersions(String remoteVersion, String currentVersion) {
    final remote = _versionParts(remoteVersion);
    final current = _versionParts(currentVersion);
    final length =
        remote.length > current.length ? remote.length : current.length;

    for (var i = 0; i < length; i++) {
      final remotePart = i < remote.length ? remote[i] : 0;
      final currentPart = i < current.length ? current[i] : 0;
      if (remotePart != currentPart) return remotePart.compareTo(currentPart);
    }
    return 0;
  }

  static List<int> _versionParts(String version) {
    final normalized = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return normalized
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
