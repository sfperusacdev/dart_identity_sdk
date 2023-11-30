import 'dart:io';

import 'package:dart_identity_sdk/pages/login/bloc/empresa_grupo_provider.dart';
import 'package:dart_identity_sdk/pages/login/login_form_card.dart';
import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider(
      create: (_) => EmpresaGrupoPrivider(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: SizedBox(
                        width: (Platform.isAndroid || Platform.isIOS) ? double.infinity : 400.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: Image(
                                image: AssetImage('assets/app/logo.png'),
                                width: 135,
                                height: 135,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Padding(
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
                            ),
                            Builder(builder: (context) {
                              return const LoginFrom();
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Builder(builder: (context) {
                    return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => loadEmpresasLoginFrom(context),
                        child: Ink(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.refresh, color: Colors.grey),
                          ),
                        ));
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
