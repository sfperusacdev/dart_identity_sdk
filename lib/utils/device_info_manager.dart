import 'package:managersdk/managersdk.dart';
import 'package:managersdk/licence.dart';

class DeviceInfoManager {
  static final DeviceInfoManager _singleton = DeviceInfoManager._internal();
  factory DeviceInfoManager() => _singleton;
  DeviceInfoManager._internal();

  String _deviceID = "";
  String _deviceName = "";
  List<Licence> _licencias = [];

  String get deviceID => _deviceID;
  String get deviceName => _deviceName;
  List<Licence> get licences => _licencias;

  Future<(List<Licence>, String)> init() async {
    final deviceid = await ManagerSDKF().deviceID();
    final devicename = await ManagerSDKF().deviceName();
    final licences = await ManagerSDKF().readLicences();
    _deviceID = deviceid;
    _licencias = licences;
    _deviceName = devicename;
    return (licences, deviceid);
  }
}
