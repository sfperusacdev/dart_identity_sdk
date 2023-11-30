import 'dart:convert';
import 'package:dart_identity_sdk/entities/empresa_app_perfile.dart';
import 'package:dart_identity_sdk/security/empresa.dart';
import 'package:dart_identity_sdk/services/perfiles/empresa.dart';
import 'package:dart_identity_sdk/services/perfiles/pb_perfiles.dart';
import 'package:dart_identity_sdk/utils/device_info_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_identity_sdk/application_preferences_manager.dart';

const _key = "login_EmpresaGrupoBloc_";
const _empresakey = "empresa_$_key";
Map<String, String> _init(ApplicationPreferenceManager manager) {
  var foundValue = manager.readString(_key);
  foundValue ??= "{}";
  var mapa = <String, String>{};
  final decoded = jsonDecode(foundValue);
  for (String key in decoded.keys) {
    mapa[key] = decoded[key] as String;
  }
  return mapa;
}

class EmpresaGrupoPrivider extends ChangeNotifier {
  final _manager = ApplicationPreferenceManager();
  final List<Empresa> _listaEmpresas = [];
  String? _selectedEmpresa;
  late final Map<String, String> _estado;
  EmpresaGrupoPrivider() {
    _estado = _init(_manager);
  }

  String? get getselectedEmpresa => _selectedEmpresa;

  set setselectedEmpresa(String empresa) {
    _selectedEmpresa = empresa;
    _manager.setString(_empresakey, empresa);
    notifyListeners();
  }

  set setselectedPerfil(String perfilID) {
    _estado[_selectedEmpresa ?? "unknow"] = perfilID;
    _manager.setString(_key, jsonEncode(_estado));
    notifyListeners();
  }

  List<Empresa> get empresas => _listaEmpresas;

  List<EmpresaAppPerfil> get perfiles {
    final filtered = _listaEmpresas.where((element) => element.code == _selectedEmpresa);
    if (filtered.isEmpty) return [];
    return filtered.first.perfiles;
  }

  EmpresaAppPerfil? get getSelectedPerfil {
    if (_selectedEmpresa == null) return null;
    var storedSelection = _estado[_selectedEmpresa];
    if (storedSelection == null) {
      var emps = _listaEmpresas.where((element) => element.code == _selectedEmpresa);
      if (emps.isNotEmpty) if (emps.first.perfiles.isNotEmpty) return emps.first.perfiles.first;
      return null;
    }
    var filted = perfiles.where((element) => element.id == storedSelection);
    if (filted.isEmpty) return null;
    return filted.first;
  }

  Future<void> loadEmpresasProfiles() async {
    final perfilService = AppPerfilService();
    final manager = DeviceInfoManager();
    final service = EmpresaService();
    final licenciaCodigos = manager.licences.map((e) => e.licenceCode ?? "!no-empresa").toList();
    var empresas = await service.getEmpresas(licenciaCodigos);
    final codigos = empresas.map((e) => e.code ?? "!no-empresa").toList();
    var perfiles = await perfilService.findPefiles(codigos);

    List<EmpresaAppPerfil> findEmpresa(String empresaCodigo) {
      final filtered = perfiles.where((element) => element.empresaCodigo == empresaCodigo);
      return filtered.toList();
    }

    final filteredEmpresas = <Empresa>[];
    for (var i = 0; i < empresas.length; i++) {
      empresas[i].perfiles = findEmpresa(empresas[i].code ?? "!no-empresa");
      if (empresas[i].perfiles.isNotEmpty) filteredEmpresas.add(empresas[i]);
    }
    _listaEmpresas.clear();
    _listaEmpresas.addAll(filteredEmpresas);
    final storedSelection = _manager.readString(_empresakey);
    if (_listaEmpresas.where((element) => element.code == storedSelection).isNotEmpty) {
      _selectedEmpresa = storedSelection;
      return;
    }
    if (_listaEmpresas.isNotEmpty) _selectedEmpresa = _listaEmpresas.first.code;
    notifyListeners();
  }
}
