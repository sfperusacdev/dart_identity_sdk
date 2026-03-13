import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:dart_identity_sdk/widgets/text/text_observer.dart';
import 'package:flutter/material.dart';

class ControlledText extends StatelessWidget {
  final TextEditingCController? controller;
  final String? label;
  final IconData? suffixIcon;
  final void Function(TextEditingCController txt)? onSuffixIconTab;

  const ControlledText({
    super.key,
    this.controller,
    this.label,
    this.suffixIcon,
    this.onSuffixIconTab,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? TextEditingCController();

    IconButton? suffix;
    if (onSuffixIconTab != null) {
      suffix = IconButton(
        onPressed: () => onSuffixIconTab?.call(ctrl),
        icon: Icon(suffixIcon ?? Icons.select_all),
      );
    }

    final hasLabel = label != null;

    return CustomTextControllerObserver(
      controller: ctrl,
      builder: (text) {
        return InputDecorator(
          decoration: InputDecoration(
            label: hasLabel ? Text(label!) : null,
            isDense: !hasLabel,
            contentPadding: !hasLabel ? EdgeInsets.zero : null,
            errorStyle: const TextStyle(fontSize: 9, color: Colors.redAccent),
            labelStyle: Theme.of(context).textTheme.titleMedium,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.5,
              ),
            ),
            suffixIcon: suffix,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        );
      },
    );
  }
}
