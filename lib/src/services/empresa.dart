import 'package:dart_identity_sdk/src/bases/services.dart';
import 'package:dart_identity_sdk/src/env/env.dart';
import 'package:dart_identity_sdk/src/security/empresa.dart';

class EmpresaService {
  Future<List<Empresa>> getEmpresas(List<String> licencias) async {
    if (licencias.isEmpty) return [];
    final uri = ApiService.buildUri(
      EnvConfig.identityServerUrl(),
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
