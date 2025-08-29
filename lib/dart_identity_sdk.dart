library dart_identity_sdk;

export 'src/entities/empresa_app_perfile.dart';
export 'src/entities/entities.dart';
export 'src/entities/preferencia.dart';

export 'src/bases/exceptions.dart';
export 'src/bases/services.dart';
export 'src/bases/sound_service.dart';
export 'src/bases/storage/storer.dart';
export 'src/bases/storage/system_storage_manager.dart';

export 'src/managers/session_manager.dart';
export 'src/managers/application_preferences.dart';
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
import 'package:dart_identity_sdk/kdialogs.dart';
import 'package:dart_identity_sdk/src/env/env.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _managerInited = false;
bool _soundInited = false;
bool _appInfoInited = false;

Future<bool> initializeIdentityDependencies({
  required String appID,
  String? defaultServiceID,
  required int logPort,
  String envFileName = '.env', // asset
  SessionValidityEvaluator? sessionValidityRule,
  List<String> minimumRequiredServices = const [],
  List<String> minimumRequiredPermissions = const [],
  LiteDatabaseConfig? database,
}) async {
  if (database != null) LiteConnection.setDatabaseConfig(database);
  if (sessionValidityRule != null) {
    SessionManagerSDK.setSessionValidityRule(
      rule: sessionValidityRule,
      minimumRequiredPermissions: minimumRequiredPermissions,
      minimumRequiredServices: minimumRequiredServices,
    );
  }

  initKDialogStrings();
  await LOG.init(logPort: logPort);
  if (kDebugMode || kProfileMode) {
    try {
      await dotenv.load(fileName: envFileName);
    } catch (e) {
      LOG.printError(
        ["ERROR cargando las variables de entorno:", e.toString()],
      );
    }
  }

  if (defaultServiceID != null) {
    ApiService.setDefaultServiceID(defaultServiceID);
  }
  EnvConfig.setApplicationID(appID);
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final ca = await PlatformAssetBundle().load('assets/certs/rootCA.pem');
      SecurityContext.defaultContext
          .setTrustedCertificatesBytes(ca.buffer.asInt8List());
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
    await AppPreferences.initialize();
    manager.setPreferencias(AppPreferences.global);
    _managerInited = true;
  }
  if (!_soundInited) {
    await SoundService.init();
    _soundInited = true;
  }
  try {
    await LicenceManagerSDK.init(
      SystemStorageManager().prefrences,
    ); // es probable que falle en versiones 8.1 de android
  } catch (e) {
    LOG.printError(e.toString());
  }

  // Connects to the local database using the current session's company domain, if available
  if (SessionManagerSDK.hasValidSession()) {
    final session = SessionManagerSDK.getCurrentSession();
    final domain = session?.session?.company;

    if (domain != null) {
      try {
        await LiteConnection.connect(domain);
      } catch (e) {
        LOG.printError("Failed to connect to database: ${e.toString()}");
      }
    } else {
      LOG.printError("Session is missing company domain");
    }
  }
  return true;
}

const _selectedBranchKey = "x_selected_branch";

String? getSelectedBranch() {
  final value = AppPreferences.private.getString(_selectedBranchKey);
  if (value != null) {
    return value;
  }
  final list = SessionManagerSDK.findCompanyBranchs();
  if (list.isNotEmpty) {
    return list.first;
  }
  return null;
}

Future<void> setSelectedBranch(String value) async {
  await AppPreferences.private.setString(_selectedBranchKey, value);
}
