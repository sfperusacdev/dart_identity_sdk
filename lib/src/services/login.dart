import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/security/settings/server_sertting_storage.dart';

class LoginService {
  Future<void> login({
    required String licence,
    required String deviceid,
    required String deviceName,
    required String empresa,
    required String username,
    required String password,
    required String profileID,
  }) async {
    var settings = SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.parseUri(await settings.recoveryIndentityServiceAddress(), "/v1/login");
    final manager = SessionManagerSDK();
    manager.setIdentityServerURL(uri.toString());
    await manager.login(
      licence: licence,
      deviceid: deviceid,
      deviceName: deviceName,
      empresa: empresa,
      username: username,
      password: password,
      appID: settings.appID,
      appVersion: ApplicationInfo().getAppVersion(),
      profileID: profileID,
    );
    final perfilService = AppPerfilService();
    final preferencias = await perfilService.findPreferencias(profileID);
    final map = <String, dynamic>{};
    for (int i = 0; i < preferencias.length; i++) {
      final preff = preferencias[i];
      preff.identiticador ??= "unknow";
      map[preff.identiticador!.trim()] = preff.valor;
    }
    final handle = ApplicationPreferenceManager();
    await handle.setFromMap(map);
    LOG.printInfo(["LOGIN", "DeviceID:", "$deviceid,", "DeviceName:", "$deviceName,"]);
  }
}
