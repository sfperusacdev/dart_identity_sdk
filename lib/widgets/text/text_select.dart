import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/widgets/text/text_edit.dart';
import 'package:kdialogs/kdialogs.dart';

class CustomSelectFormField<T extends SelectOption> extends StatelessWidget {
  final bool showSearchInput;
  final Future<List<T>> Function() getOptions;
  final TextEditingCController? controller;
  final String? label;
  final void Function(SelectOptionOnChangeEventData<T> event)? onChange;
  final bool required;

  const CustomSelectFormField({
    super.key,
    required this.getOptions,
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
      required: required,
      onSuffixIconTab: (txt) async {
        final prevVal = txt.getValue();
        late final List<T> options;
        final selecteds = await showAsyncOptionsDialog<T>(
          context,
          searchInput: showSearchInput,
          getOptions: () async {
            options = await getOptions();
            return options;
          },
          initialSelection: [txt.getValue()],
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
