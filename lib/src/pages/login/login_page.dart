import 'dart:io';
import 'package:dart_identity_sdk/src/env/env.dart';
import 'package:dart_identity_sdk/src/pages/login/bloc/empresa_grupo_provider.dart';
import 'package:dart_identity_sdk/src/pages/login/login_form_card.dart';
import 'package:flutter/material.dart';
import 'package:kdialogs/kdialogs.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  static const path = "/login";
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (_) => EmpresaGrupoPrivider(),
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: SizedBox(
                      width: (Platform.isAndroid || Platform.isIOS)
                          ? double.infinity
                          : 400.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((Platform.isAndroid || Platform.isIOS) &&
                              size.height > size.width)
                            _logoImage(),
                          const SizedBox(height: 12.0),
                          _binvenidoMessage(context),
                          const LoginFrom(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _refreshEmpresasIcon(),
            _printInfoIcon(),
          ],
        ),
      ),
    );
  }

  SafeArea _refreshEmpresasIcon() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Builder(builder: (context) {
            return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => loadEmpresasLoginFrom(context),
                child: Ink(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.refresh, color: Colors.grey),
                  ),
                ));
          }),
        ),
      ),
    );
  }

  SafeArea _printInfoIcon() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                showKDialogContent(
                  context,
                  title: "Configuraciones",
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🔐 Identity:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          EnvConfig.identityServerUrl(),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        const Text("⚙️ Preferencias:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          EnvConfig.preferencesServerUrl(),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.info_outlined, color: Colors.grey),
              )),
        ),
      ),
    );
  }

  Padding _binvenidoMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Text(
        'BIENVENIDO',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'roboto-regular',
          fontSize: 35,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Center _logoImage() {
    return Center(
      child: Builder(builder: (context) {
        var isMovile = (Platform.isAndroid || Platform.isIOS);
        final size = MediaQuery.of(context).size;
        final imageSize = isMovile ? size.width : size.height;
        return Image(
          image: const AssetImage('assets/app/logo.png'),
          width: imageSize * 0.35,
          height: imageSize * 0.35,
        );
      }),
    );
  }
}
