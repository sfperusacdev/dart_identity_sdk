import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';

class CustomTimeFormField extends StatelessWidget {
  final TextEditingCController? controller;
  final String? label;
  final void Function(TimeOfDay? time)? onChange;
  final bool required;

  const CustomTimeFormField({
    super.key,
    this.controller,
    this.label,
    this.required = false,
    this.onChange,
  });

  bool _sameTime(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      readonly: true,
      required: required,
      suffixIcon: Icons.access_time,
      onSuffixIconLogTab: (txt) {
        final current = txt.getTimeOrNull();
        if (current != null) {
          txt.setTime(null);
          onChange?.call(null);
        }
      },
      onSuffixIconTab: (txt) async {
        final current = txt.getTimeOrNull();
        final initial = current ?? TimeOfDay.now();

        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );

        final actual = txt.getTimeOrNull();

        if (picked != null && (actual == null || !_sameTime(picked, actual))) {
          txt.setTime(picked);
          onChange?.call(picked);
        }
      },
    );
  }
}
