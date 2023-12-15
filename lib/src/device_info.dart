import 'package:package_info_plus/package_info_plus.dart';

class ApplicationInfo {
  String? _appVersion;
  static final ApplicationInfo _singleton = ApplicationInfo._internal();
  factory ApplicationInfo() {
    return _singleton;
  }
  ApplicationInfo._internal();
  Future<void> init() async {
    final platform = await PackageInfo.fromPlatform();
    _appVersion = platform.version;
  }

  String getAppVersion() {
    return _appVersion ?? "";
  }
}
