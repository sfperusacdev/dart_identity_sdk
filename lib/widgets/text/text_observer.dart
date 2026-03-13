import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';

class CustomTextControllerObserver extends StatefulWidget {
  final TextEditingCController? controller;
  final Widget Function(String value) builder;

  const CustomTextControllerObserver({
    super.key,
    this.controller,
    required this.builder,
  });

  @override
  State<CustomTextControllerObserver> createState() =>
      _CustomTextControllerObserverState();
}

class _CustomTextControllerObserverState
    extends State<CustomTextControllerObserver> {
  late TextEditingCController _controller;
  String _value = "";

  void _handleChange() {
    setState(() => _value = _controller.text);
  }

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingCController();
    _value = _controller.text;
    _controller.addListener(_handleChange);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_value);
  }
}
