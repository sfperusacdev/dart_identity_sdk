import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final controller = TextEditingCController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inputs")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTextFormField(
              label: "Nombre",
              onChanged: (value) {
                controller.setText(value);
              },
            ),
            CustomTextFormField(
              label: "Nombre",
              readonly: true,
              controller: controller,
              initValue: "Este es un texto de solo lectura",
            ),
          ],
        ),
      ),
    );
  }
}
