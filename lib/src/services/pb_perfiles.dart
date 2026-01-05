import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/env/env.dart';

class AppPerfilService {
  Future<List<EmpresaAppPerfil>> findPefiles(List<String> empresas) async {
    final uri = ApiService.buildUri(
      await LicenceManagerSDK.preferencesUrl(),
      "/v1/api/perfiles",
    );
    var result = await ApiService.post(
      withUri: uri,
      payload: {"empresa": empresas, "servicio": EnvConfig.appID},
    );
    var perfiles = <EmpresaAppPerfil>[];
    for (var r in result) {
      perfiles.add(EmpresaAppPerfil.fromMap(r));
    }
    return perfiles;
  }

  Future<List<Preferencia>> findPreferencias(String perfilid) async {
    final uri = ApiService.buildUri(
      await LicenceManagerSDK.preferencesUrl(),
      "/v1/api/perfil/$perfilid/preferencias",
    );
    var result = await ApiService.get(
      timeout: const Duration(seconds: 5),
      withUri: uri,
    );
    var grupos = <GrupoPreferencia>[];
    for (var r in result) {
      grupos.add(GrupoPreferencia.fromMap(r));
    }
    var preferencias = <Preferencia>[];
    for (var g in grupos) {
      preferencias.addAll(g.preferencias ?? []);
    }
    return preferencias;
  }
}
