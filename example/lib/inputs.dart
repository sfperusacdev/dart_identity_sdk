import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:dart_identity_sdk/widgets/text/text.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final controller01 = TextEditingCController.withText("00");
  final controller02 = TextEditingCController();
  final controller03 = TextEditingCController();
  final textcontroller = TextEditingCController.withText("hola11");
  final multiline = TextEditingCController.withText(
    "Este es un texto super largo para probar el comportamiento del input en multilines",
  );
  final camera = TextEditingCController.withText("hola11");
  final dark = TextEditingCController.withText("00");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inputs")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTextFormField(
              label: "DNI",
              controller: camera,
              scannable: true,
              onSubmit: (txt) async {
                await showAsyncProgressKDialog(
                  context,
                  doProcess: () async {
                    await Future.delayed(Duration(milliseconds: 15));
                    txt.clear();
                    return true;
                  },
                );
              },
            ),
            CustomTextFormField(
              label: "Nombres",
              onChanged: (value) {
                controller01.setText(value);
                textcontroller.setText(value);
              },
            ),
            CustomTextFormField(
              label: "Apellido Paterno",
              readonly: true,
              controller: controller01,
            ),
            CustomTextFormField(
              label: "Apellido Materno",
              readonly: true,
              controller: controller02,
            ),
            CustomTextFormField(
              label: "Direccion",
              controller: controller03,
              suffixIcon: Icons.search,
              onSuffixIconTab: (txt) {},
              // initValue: Icons.search,
            ),
            CustomTextFormField(
              label: "Multi Lines",
              controller: multiline,
              multiLine: true,
              suffixIcon: Icons.search,
              onSuffixIconTab: (txt) {},
            ),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextFormField(
                  label: "Input dark",
                  darkMode: true,
                  controller: dark,
                  suffixIcon: Icons.search,
                  onSuffixIconTab: (txt) {
                    txt.updateBottomLabel("hola");
                  },
                ),
              ),
            ),
            Divider(),
            ControlledText(controller: textcontroller, label: "Prueba"),
            Divider(),
          ],
        ),
      ),
    );
  }
}
