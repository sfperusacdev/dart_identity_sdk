import 'package:flutter/material.dart';

class SettingIntput extends StatelessWidget {
  final String initialValue;
  final Function(String value) onChange;
  const SettingIntput({super.key, required this.initialValue, required this.onChange});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide()),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
      ),
      onChanged: onChange,
    );
  }
}
