import 'package:dart_identity_sdk/bases/services.dart';
import 'package:dart_identity_sdk/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/entities/empresa_app_perfile.dart';
import 'package:dart_identity_sdk/entities/preferencia.dart';
import 'package:dart_identity_sdk/security/settings/server_sertting_storage.dart';

class AppPerfilService {
  Future<List<EmpresaAppPerfil>> findPefiles(List<String> empresas) async {
    var settings = SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.parseUri(
      await settings.recoveryPreferenciaServiceAddress(),
      "/v1/api/perfiles",
    );
    var result = await ApiService.postWithUri(
      uri,
      payload: {"empresa": empresas, "servicio": settings.appID},
    );
    var perfiles = <EmpresaAppPerfil>[];
    for (var r in result) {
      perfiles.add(EmpresaAppPerfil.fromMap(r));
    }
    return perfiles;
  }

  Future<List<Preferencia>> findPreferencias(String perfilid) async {
    var settings = SystemStorageManager().instance<ServerSettingsSorage>().getValue();
    if (settings == null) throw Exception("invalid settings");
    final uri = ApiService.parseUri(
      await settings.recoveryPreferenciaServiceAddress(),
      "/v1/api/perfil/$perfilid/preferencias",
    );
    var result = await ApiService.getWithUri(uri);
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
