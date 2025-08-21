import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';

class CustomBasicSelectFormField<T extends SelectOption>
    extends StatelessWidget {
  final bool showSearchInput;
  final List<T> options;
  final TextEditingCController? controller;
  final String? label;
  final void Function(SelectOptionOnChangeEventData<T> event)? onChange;
  final bool required;

  const CustomBasicSelectFormField({
    super.key,
    required this.options,
    this.controller,
    this.label,
    this.required = false,
    this.showSearchInput = true,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      readonly: true,
      onSuffixIconTab: (txt) async {
        final prevVal = txt.getValue();
        final selecteds = await showBasicOptionsKDialog<T>(
          context,
          searchInput: showSearchInput,
          options: options,
          initialSelection: [txt.getValue()],
          useMaxHeight: false,
        );
        if (selecteds == null) return;
        if (selecteds.isEmpty) {
          txt.setText("", internalID: null);
          onChange?.call(SelectOptionOnChangeEventData(txt, options));
          return;
        }
        final selected = selecteds.first;
        if (selected.getID() == prevVal) return;
        txt.setText(selected.getLabel(), internalID: selected.getID());
        onChange?.call(
          SelectOptionOnChangeEventData(txt, options, selected: selected),
        );
      },
    );
  }
}
