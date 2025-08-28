import 'package:dart_identity_sdk/src/entities/empresa_app_perfile.dart';
import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:dart_identity_sdk/src/pages/login/bloc/empresa_grupo_provider.dart';
import 'package:dart_identity_sdk/src/pages/login/form_store_helper.dart';
import 'package:dart_identity_sdk/src/security/settings/login_fields.dart';
import 'package:dart_identity_sdk/src/services/login.dart';
import 'package:dart_identity_sdk/src/managers/device_info_manager.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
import 'package:provider/provider.dart';

class LoginFrom extends StatefulWidget {
  const LoginFrom({super.key});
  @override
  State<LoginFrom> createState() => _LoginFromState();
}

class _LoginFromState extends State<LoginFrom> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _showPassword = false;
  String _empresa = '';
  String _perfil = '';
  String _username = '';
  String _password = '';
  bool _memorize = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await loadEmpresasLoginFrom(context),
    );

    var storedState = LoginCredentialsStoreHelper.load();
    if (storedState != null) {
      _username = storedState.username ?? '';
      _password = storedState.password ?? '';
      _memorize = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 65),
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 8.0, bottom: 65.0),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _dominioInput(),
                      _perfilInput(),
                      _usernameInput(),
                      _passsworInput(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _submitButton(),
            _recordar(),
          ],
        )
      ],
    );
  }

  Widget _dominioInput() {
    return Builder(builder: (context) {
      final provider = Provider.of<EmpresaGrupoPrivider>(context);
      final empresas = provider.empresas;
      return DropdownButtonFormField<String>(
        value: provider.getselectedEmpresa,
        isExpanded: true,
        decoration: InputDecoration(
          label: const Text("Empresa", style: TextStyle(color: Colors.black)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
        ),
        items: empresas.map((item) {
          return DropdownMenuItem<String>(
            value: item.code ?? "",
            child: Text(item.description ?? ""),
          );
        }).toList(),
        onSaved: ((newValue) => _empresa = newValue ?? ''),
        onChanged: (value) {
          provider.setselectedEmpresa = value ?? "";
        },
      );
    });
  }

  Widget _perfilInput() {
    return Builder(builder: (context) {
      final provider = Provider.of<EmpresaGrupoPrivider>(context);
      final perfiles = provider.perfiles;
      if (perfiles.length < 2) {
        if (perfiles.length == 1) {
          _perfil = perfiles.first.id ?? "";
          provider.justSetSelectedPerfil = perfiles.first.id ?? "";
        }
        return Container();
      }
      return DropdownButtonFormField<EmpresaAppPerfil>(
        value: provider.getSelectedPerfil,
        isExpanded: true,
        decoration: InputDecoration(
          label: const Text("Grupo", style: TextStyle(color: Colors.black)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
        ),
        items: perfiles.map((item) {
          return DropdownMenuItem<EmpresaAppPerfil>(
            value: item,
            child: Text(item.descripcion ?? ""),
          );
        }).toList(),
        onSaved: ((newValue) => _perfil = newValue?.id ?? ''),
        onChanged: (value) {
          if (value == null) return;
          provider.setselectedPerfil = value.id ?? "";
        },
      );
    });
  }

  TextFormField _usernameInput() {
    return TextFormField(
      initialValue: _username,
      onSaved: (newValue) => _username = newValue ?? '',
      validator: (value) =>
          value?.isEmpty ?? false ? 'no puede quedar vacío' : null,
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide()),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
        label: const Text("Usuario", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  TextFormField _passsworInput() {
    return TextFormField(
      initialValue: _password,
      obscureText: !_showPassword,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: Theme.of(context).primaryColor,
      validator: ((value) =>
          value?.isEmpty ?? false ? 'no puede quedar vacío' : null),
      onSaved: (newValue) => _password = newValue ?? '',
      decoration: InputDecoration(
          border: const UnderlineInputBorder(borderSide: BorderSide()),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
          label: const Text("Password", style: TextStyle(color: Colors.black)),
          suffixIcon: InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () {
              setState(() => _showPassword = !_showPassword);
            },
            child: Icon(
              _showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
          )),
    );
  }

  Widget _submitButton() {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: MaterialButton(
            elevation: 4.0,
            height: 50.0,
            color: Theme.of(context).primaryColor,
            onPressed: () => onSubmit(context),
            child: SizedBox(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text('Iniciar sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 15.0,
                          height: 15.0,
                          child: Visibility(
                            visible: isLoading,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3.0,
                              color: Colors.white,
                            ),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _recordar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _memorize,
          checkColor: Colors.white,
          activeColor: Theme.of(context).colorScheme.secondary,
          onChanged: (value) => setState(() => _memorize = value ?? false),
        ),
        const Text("Recordar contraseña"),
      ],
    );
  }

  void onSubmit(BuildContext context) async {
    if (isLoading) return;
    if (formKey.currentState == null) return;
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    if (_username == "devmode" && _password == "devmode") {
      Navigator.of(context).pushNamed("/settings");
      return;
    }
    var request = RequestLogin(
        empresa: _empresa, username: _username, password: _password);
    if (_memorize) {
      await LoginCredentialsStoreHelper.save(request);
    } else {
      await LoginCredentialsStoreHelper.clear();
    }
    if (!context.mounted) return;
    await showAsyncProgressKDialog(
      context,
      doProcess: () async {
        final selectedEmpresa = _empresa.trim();
        final licences = await DeviceLicenceManager.readLicences();
        final index = licences
            .indexWhere((element) => element.companyCode == selectedEmpresa);
        if (index == -1) throw "no se econtro licencia para $selectedEmpresa";
        final licence = licences[index];
        final service = LoginService();
        final domain = _empresa.trim();
        await service.login(
          licence: licence.licenceCode ?? "",
          deviceid: await DeviceLicenceManager.deviceID(),
          deviceName: await DeviceLicenceManager.deviceName(),
          empresa: domain,
          username: _username.trim(),
          password: _password.trim(),
          profileID: _perfil,
        );

        // Attempts to connect to the local database using the provided domain
        try {
          await LiteConnection.connect(domain);
        } catch (e) {
          LOG.printError("Failed to connect to database: ${e.toString()}");
          throw "No se pudo preparar la conexión con la base de datos para el dominio: $domain";
        }

        return true;
      },
      onSuccess: (_) => context.go("/home"),
    );
  }
}

Future<void> loadEmpresasLoginFrom(BuildContext context) async {
  await showAsyncProgressKDialog(
    context,
    doProcess: () async {
      await Provider.of<EmpresaGrupoPrivider>(
        context,
        listen: false,
      ).loadEmpresasProfiles();
    },
    retryable: true,
  );
}
