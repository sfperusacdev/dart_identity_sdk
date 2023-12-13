import 'dart:async';

import 'package:dart_identity_sdk/logs/log.dart';
import 'package:dart_identity_sdk/manager/licence.dart';
import 'package:dart_identity_sdk/manager/managersdk.dart';

const _tag = "DeviceLicenceManager";

class DeviceLicenceManager {
  static final DeviceLicenceManager _singleton = DeviceLicenceManager._internal();
  factory DeviceLicenceManager() => _singleton;
  DeviceLicenceManager._internal();

  Future<String> deviceID() async {
    try {
      return await ManagerSDKF().deviceID();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No fue posible leer la identificación del dispositivo";
    }
  }

  Future<String> deviceName() async {
    try {
      return await ManagerSDKF().deviceName();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No fue posible leer la informacion del dispositivo";
    }
  }

  Future<List<Licence>> readLicences() async {
    try {
      return await ManagerSDKF().readLicences();
    } catch (e) {
      LOG.printError([_tag, e.toString()]);
      throw "No se pudo cargar las licencias asociadas a este dispositivo";
    }
  }
}
