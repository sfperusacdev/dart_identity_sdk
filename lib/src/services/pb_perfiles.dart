import 'package:dart_identity_sdk/src/bases/services.dart';
import 'package:dart_identity_sdk/src/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/src/entities/empresa_app_perfile.dart';
import 'package:dart_identity_sdk/src/entities/preferencia.dart';
import 'package:dart_identity_sdk/src/security/settings/server_sertting_storage.dart';

class AppPerfilService {
  Future<List<EmpresaAppPerfil>> findPefiles(List<String> empresas) async {
    var settings =
        SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.buildUri(
      await settings.recoveryPreferenciaServiceAddress(),
      "/v1/api/perfiles",
    );
    var result = await ApiService.post(
      withUri: uri,
      payload: {"empresa": empresas, "servicio": settings.appID},
    );
    var perfiles = <EmpresaAppPerfil>[];
    for (var r in result) {
      perfiles.add(EmpresaAppPerfil.fromMap(r));
    }
    return perfiles;
  }

  Future<List<Preferencia>> findPreferencias(String perfilid) async {
    var settings =
        SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.buildUri(
      await settings.recoveryPreferenciaServiceAddress(),
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
