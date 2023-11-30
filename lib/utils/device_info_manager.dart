import 'package:managersdk/managersdk.dart';
import 'package:managersdk/licence.dart';

class DeviceInfoManager {
  static final DeviceInfoManager _singleton = DeviceInfoManager._internal();
  factory DeviceInfoManager() => _singleton;
  DeviceInfoManager._internal();
  static const devappProviderAuthority = "com.sfperusac.manager.licences";

  String _deviceID = "";
  List<Licence> _licencias = [];

  String get deviceID => _deviceID;
  List<Licence> get licences => _licencias;

  Future<(List<Licence>, String)> init() async {
    final licences = await ManagerSDKF().readLicences();
    final deviceid = await ManagerSDKF().deviceID();
    _deviceID = deviceid;
    _licencias = licences;
    return (licences, deviceid);
  }
}
