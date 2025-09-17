import 'package:package_info_plus/package_info_plus.dart';

class ApplicationInfo {
  static String? _appVersion;

  static Future<void> init() async {
    final platform = await PackageInfo.fromPlatform();
    _appVersion = platform.version;
  }

  static String get appVersion => _appVersion ?? "";
}
