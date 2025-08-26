import 'package:dart_identity_sdk/widgets/scaffold/appbar.dart';
import 'package:flutter/material.dart';

class AppbarPage extends StatelessWidget {
  const AppbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: SearchAppBar(title: "Prueba"));
  }
}
