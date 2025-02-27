import 'package:dart_identity_sdk/src/bases/services.dart';
import 'package:dart_identity_sdk/src/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/src/security/empresa.dart';
import 'package:dart_identity_sdk/src/security/settings/server_sertting_storage.dart';

class EmpresaService {
  Future<List<Empresa>> getEmpresas(List<String> licencias) async {
    if (licencias.isEmpty) return [];
    var settings =
        SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.buildUri(
      await settings.recoveryIndentityServiceAddress(),
      "/v1/get-licence-empresa",
    );
    var result = await ApiService.post(
      withUri: uri,
      payload: {
        "licence": licencias,
      },
    );
    if (result == null) return [];
    final empresas = <Empresa>[];
    for (var r in result) {
      empresas.add(Empresa.fromMap(r));
    }
    return empresas;
  }
}
