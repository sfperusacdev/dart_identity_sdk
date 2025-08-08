import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/env/env.dart';

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
    final uri = ApiService.buildUri(
      EnvConfig.identityServerUrl(),
      "/v1/login",
    );
    SessionManagerSDK.setIdentityServerURL(uri.toString());
    await SessionManagerSDK.login(
      licence: licence,
      deviceid: deviceid,
      deviceName: deviceName,
      empresa: empresa,
      username: username,
      password: password,
      appID: EnvConfig.appID,
      appVersion: ApplicationInfo().getAppVersion(),
      profileID: profileID,
    );
    AppPreferences.setUpDomain(empresa);
    await AppPreferences.syncPreferences();
    LOG.printInfo(
        ["LOGIN", "DeviceID:", "$deviceid,", "DeviceName:", "$deviceName,"]);
  }
}
