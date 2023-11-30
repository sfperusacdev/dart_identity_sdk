import 'package:dart_identity_sdk/bases/services.dart';
import 'package:dart_identity_sdk/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/security/settings/server_sertting_storage.dart';
import 'package:dart_identity_sdk/utils/device_info.dart';

class LoginService {
  Future<void> login({
    required String licence,
    required String deviceid,
    required String empresa,
    required String username,
    required String password,
  }) async {
    var settings = SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.parseUri(await settings.recoveryIndentityServiceAddress(), "/v1/login");
    final manager = SessionManagerSDK();
    manager.setIdentityServerURL(uri.toString());
    await manager.login(
      licence: licence,
      deviceid: deviceid,
      empresa: empresa,
      username: username,
      password: password,
      appID: settings.appID,
      appVersion: ApplicationInfo().getAppVersion(),
    );
  }
}
