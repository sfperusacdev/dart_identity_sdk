import 'dart:async';

import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:dart_identity_sdk/src/managers/licence_manager.dart';

const _tag = "DeviceLicenceManager";

class DeviceLicenceManager {
  static final DeviceLicenceManager _singleton = DeviceLicenceManager._internal();
  factory DeviceLicenceManager() => _singleton;
  DeviceLicenceManager._internal();

  Future<String> deviceID() async {
    try {
      return await LicenceManagerSDK().deviceID();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No fue posible leer la identificación del dispositivo";
    }
  }

  Future<String> deviceName() async {
    try {
      return await LicenceManagerSDK().deviceName();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No fue posible leer la informacion del dispositivo";
    }
  }

  Future<List<Licence>> readLicences() async {
    try {
      return await LicenceManagerSDK().readLicences();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No se pudo cargar las licencias asociadas a este dispositivo";
    }
  }
}
