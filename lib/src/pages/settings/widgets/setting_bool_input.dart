import 'package:flutter/material.dart';

class SettingBoolInput extends StatefulWidget {
  final String title;
  final String? subTitle;
  final bool value;
  final bool disable;
  final void Function(bool value)? onChanged;
  const SettingBoolInput({
    super.key,
    required this.title,
    this.subTitle,
    required this.value,
    this.disable = false,
    this.onChanged,
  });

  @override
  State<SettingBoolInput> createState() => _SettingBoolInputState();
}

class _SettingBoolInputState extends State<SettingBoolInput> {
  bool value = false;
  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SettingBoolInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (value && widget.disable) {
      setState(() => value = false);
      if (widget.onChanged != null) widget.onChanged!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: widget.disable ? const TextStyle(color: Colors.grey) : null,
      ),
      subtitle: widget.subTitle != null
          ? Text(
              widget.subTitle!,
              style: widget.disable ? const TextStyle(color: Colors.grey) : null,
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: (value) {
          if (widget.disable) return;
          if (widget.onChanged != null) widget.onChanged!(value);
          setState(() => value = value);
        },
      ),
    );
  }
}
