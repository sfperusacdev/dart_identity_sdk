import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';

class ControlledText extends StatefulWidget {
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
  State<ControlledText> createState() => _ControlledTextState();
}

class _ControlledTextState extends State<ControlledText> {
  String text = "";
  late TextEditingCController _controller;

  void _syncText() {
    setState(() => text = _controller.text);
  }

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  void _setupController() {
    _controller = widget.controller ?? TextEditingCController();
    text = _controller.text;
    _controller.addListener(_syncText);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconButton? suffixIcon;
    if (widget.onSuffixIconTab != null) {
      suffixIcon = IconButton(
        onPressed: () => widget.onSuffixIconTab?.call(_controller),
        icon: Icon(widget.suffixIcon ?? Icons.select_all),
      );
    }
    final hasLabel = widget.label != null;
    return InputDecorator(
      decoration: InputDecoration(
        label: hasLabel ? Text(widget.label!) : null,
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
        suffixIcon: suffixIcon,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}
