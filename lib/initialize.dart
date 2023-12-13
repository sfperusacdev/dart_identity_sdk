import 'dart:io';
import 'package:dart_identity_sdk/application_preferences_manager.dart';
import 'package:dart_identity_sdk/bases/services.dart';
import 'package:dart_identity_sdk/bases/sound_service.dart';
import 'package:dart_identity_sdk/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/logs/log.dart';
import 'package:dart_identity_sdk/manager/managersdk.dart';
import 'package:dart_identity_sdk/security/selected_sucursal_storage.dart';
import 'package:dart_identity_sdk/security/settings/login_fields.dart';
import 'package:dart_identity_sdk/security/settings/server_sertting_storage.dart';
import 'package:dart_identity_sdk/utils/device_info.dart';
import 'package:flutter/services.dart';

bool _managerInited = false;
bool _soundInited = false;
bool _appInfoInited = false;
Future<bool> initializeIdentityDependencies({required String appID, String? defaultServiceID}) async {
  if (defaultServiceID != null) ApiService.setDefaultServiceID(defaultServiceID);
  setApplicationID(appID);
  try {
    final ca = await PlatformAssetBundle().load('assets/certs/rootCA.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(ca.buffer.asInt8List());
  } catch (err) {
    LOG.printError([err]);
  }
  if (!_appInfoInited) {
    await ApplicationInfo().init();
    _appInfoInited = true;
  }
  if (!_managerInited) {
    var manager = SystemStorageManager();
    manager.setPreferencias(await ApplicationPreferenceManager().load());
    manager.addprovide((preferences) => ServerSettingsSorage(preferences));
    manager.addprovide((preferences) => LoginFielsStorage(preferences));
    manager.addprovide((preferences) => SelectedSucursalStorage(preferences));
    _managerInited = true;
  }
  if (!_soundInited) {
    await SoundService().init();
    _soundInited = true;
  }
  try {
    await ManagerSDKF().init(); //es probable que falle en versiones 8.1 de android
  } catch (e) {
    LOG.printError(e.toString());
  }
  return true;
}
