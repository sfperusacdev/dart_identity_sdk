import 'dart:io';

import 'package:dart_identity_sdk/application_preferences_manager.dart';
import 'package:dart_identity_sdk/bases/sound_service.dart';
import 'package:dart_identity_sdk/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/logs/log.dart';
import 'package:dart_identity_sdk/security/selected_sucursal_storage.dart';
import 'package:dart_identity_sdk/security/settings/login_fields.dart';
import 'package:dart_identity_sdk/security/settings/server_sertting_storage.dart';
import 'package:dart_identity_sdk/utils/device_info.dart';
import 'package:dart_identity_sdk/utils/device_info_manager.dart';
import 'package:flutter/services.dart';

Future<void> initializeIdentity(String appid) async {
  setApplicationID(appid);
  try {
    final ca = await PlatformAssetBundle().load('assets/certs/rootCA.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(ca.buffer.asInt8List());
  } catch (err) {
    LOG.printError([err]);
  }
  await ApplicationInfo().init();
  var manager = SystemStorageManager();
  manager.setPreferencias(await ApplicationPreferenceManager().load());
  manager.addprovide((preferences) => ServerSettingsSorage(preferences));
  manager.addprovide((preferences) => LoginFielsStorage(preferences));
  manager.addprovide((preferences) => SelectedSucursalStorage(preferences));
  await SoundService().init();
  final infoManager = DeviceInfoManager();
  await infoManager.init();
  if (infoManager.licences.isEmpty) throw "No hay ninguna licencia asociada con este dispositivo";
}