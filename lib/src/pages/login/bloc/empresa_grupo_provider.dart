import 'dart:convert';
import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/security/empresa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

const _key = "login_EmpresaGrupoBloc_";
const _empresakey = "empresa_$_key";

Map<String, String> _loadFromPreferences() {
  var jsonString = AppPreferences.global.getString(_key) ?? "{}";
  var result = <String, String>{};
  final decodedMap = jsonDecode(jsonString);
  for (String key in decodedMap.keys) {
    result[key] = decodedMap[key] as String;
  }
  return result;
}

class EmpresaGrupoPrivider extends ChangeNotifier {
  final List<Empresa> _listaEmpresas = [];
  String? _selectedEmpresa;
  late final Map<String, String> _estado;
  EmpresaGrupoPrivider() {
    _estado = _loadFromPreferences();
  }

  String? get getselectedEmpresa => _selectedEmpresa;

  set setselectedEmpresa(String empresa) {
    _selectedEmpresa = empresa;
    AppPreferences.global.setString(_empresakey, empresa);
    notifyListeners();
  }

  set justSetSelectedPerfil(String perfilID) {
    _estado[_selectedEmpresa ?? "unknow"] = perfilID;
    final str = jsonEncode(_estado);
    AppPreferences.global.setString(_key, str);
  }

  set setselectedPerfil(String perfilID) {
    _estado[_selectedEmpresa ?? "unknow"] = perfilID;
    final str = jsonEncode(_estado);
    AppPreferences.global.setString(_key, str);
    notifyListeners();
  }

  List<Empresa> get empresas => _listaEmpresas;

  List<EmpresaAppPerfil> get perfiles {
    final filtered =
        _listaEmpresas.where((element) => element.code == _selectedEmpresa);
    if (filtered.isEmpty) return [];
    return filtered.first.perfiles;
  }

  EmpresaAppPerfil? get getSelectedPerfil {
    if (_selectedEmpresa == null) return null;
    var storedSelection = _estado[_selectedEmpresa];
    if (storedSelection == null) {
      var emps =
          _listaEmpresas.where((element) => element.code == _selectedEmpresa);
      if (emps.isNotEmpty && emps.first.perfiles.isNotEmpty) {
        return emps.first.perfiles.first;
      }
      return null;
    }
    var filted = perfiles.where((element) => element.id == storedSelection);
    if (filted.isEmpty) return null;
    return filted.first;
  }

  Future<void> loadEmpresasProfiles() async {
    final perfilService = AppPerfilService();
    final service = EmpresaService();
    final licensesFound = await DeviceLicenceManager.readLicences();
    final licenciaCodigos =
        licensesFound.map((e) => e.licenceCode ?? "!no-empresa").toList();
    var empresas = await service.getEmpresas(licenciaCodigos);
    final codigos = empresas.map((e) => e.code ?? "!no-empresa").toList();
    var perfiles = await perfilService.findPefiles(codigos);

    List<EmpresaAppPerfil> findEmpresa(String empresaCodigo) {
      final filtered =
          perfiles.where((element) => element.empresaCodigo == empresaCodigo);
      return filtered.toList();
    }

    final filteredEmpresas = <Empresa>[];
    for (var i = 0; i < empresas.length; i++) {
      empresas[i].perfiles = findEmpresa(empresas[i].code ?? "!no-empresa");
      if (empresas[i].perfiles.isNotEmpty) filteredEmpresas.add(empresas[i]);
    }
    _listaEmpresas.clear();
    _listaEmpresas.addAll(filteredEmpresas);
    final storedSelection = AppPreferences.global.getString(_empresakey);
    if (_listaEmpresas
        .where((element) => element.code == storedSelection)
        .isNotEmpty) {
      _selectedEmpresa = storedSelection;
      notifyListeners();
      return;
    }
    if (_listaEmpresas.isNotEmpty) _selectedEmpresa = _listaEmpresas.first.code;
    notifyListeners();
  }
}
