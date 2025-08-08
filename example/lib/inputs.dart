import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';

class InputsPage extends StatelessWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inputs")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [CustomTextFormField(label: "Nombre")]),
      ),
    );
  }
}
