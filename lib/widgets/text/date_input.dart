import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';

class CustomDateFormField extends StatelessWidget {
  final TextEditingCController? controller;
  final String? label;
  final void Function(DateTime? date)? onChange;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateFormField({
    super.key,
    this.controller,
    this.label,
    this.required = false,
    this.onChange,
    this.firstDate,
    this.lastDate,
  });

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      readonly: true,
      required: required,
      suffixIcon: Icons.calendar_month,
      onSuffixIconLogTab: (txt) {
        final current = txt.getDatetimeOrNull();
        if (current != null) {
          txt.setDatetime(null);
          onChange?.call(null);
        }
      },
      onSuffixIconTab: (txt) async {
        final now = DateTime.now();
        final minDate = firstDate ?? DateTime(now.year - 100);
        final maxDate = lastDate ?? DateTime(now.year + 10);
        var initialDate = txt.getDatetimeOrNull() ?? now;

        if (initialDate.isBefore(minDate)) {
          initialDate = minDate;
        } else if (initialDate.isAfter(maxDate)) {
          initialDate = maxDate;
        }

        final picked = await showDatePicker(
          context: context,
          firstDate: minDate,
          lastDate: maxDate,
          initialDate: initialDate,
        );

        final current = txt.getDatetimeOrNull();

        if (picked != null &&
            (current == null || !_sameDate(picked, current))) {
          txt.setDatetime(picked);
          onChange?.call(picked);
        }
      },
    );
  }
}
