library dart_identity_sdk;

export 'src/entities/empresa_app_perfile.dart';
export 'src/entities/entities.dart';
export 'src/entities/preferencia.dart';

export 'src/storage/session_storage.dart';

export 'src/bases/exceptions.dart';
export 'src/bases/services.dart';
export 'src/bases/sound_service.dart';
export 'src/bases/storage/storer.dart';
export 'src/bases/storage/system_storage_manager.dart';

export 'src/managers/session_manager.dart';
export 'src/managers/application_preferences_manager.dart';
export 'src/managers/licence_manager.dart';
export 'src/managers/device_info_manager.dart';

export 'src/services/empresa.dart';
export 'src/services/login.dart';
export 'src/services/pb_perfiles.dart';

export 'src/logs/log.dart';
export 'src/router.dart';
export 'src/device_info.dart';

import 'dart:io';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/security/selected_sucursal_storage.dart';
import 'package:dart_identity_sdk/src/security/settings/login_fields.dart';
import 'package:dart_identity_sdk/src/security/settings/server_sertting_storage.dart';
import 'package:flutter/services.dart';

bool _managerInited = false;
bool _soundInited = false;
bool _appInfoInited = false;

Future<bool> initializeIdentityDependencies({required String appID, String? defaultServiceID}) async {
  await LOG.init();
  if (defaultServiceID != null) ApiService.setDefaultServiceID(defaultServiceID);
  setApplicationID(appID);
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final ca = await PlatformAssetBundle().load('assets/certs/rootCA.pem');
      SecurityContext.defaultContext.setTrustedCertificatesBytes(ca.buffer.asInt8List());
    }
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
    await LicenceManagerSDK().init(
      SystemStorageManager().prefrences,
    ); // es probable que falle en versiones 8.1 de android
  } catch (e) {
    LOG.printError(e.toString());
  }
  return true;
}

String? getSelectedCompanyBranch() {
  final manager = SystemStorageManager();
  return manager.instance<SelectedSucursalStorage>().getValue();
}

Future<void> setSelectedCompanyBranch(String value) async {
  final manager = SystemStorageManager();
  await manager.instance<SelectedSucursalStorage>().setValue(value);
}
