import 'package:dart_identity_sdk/widgets/text/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dart_identity_sdk/widgets/text/qr_camera.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';

class CustomTextFormField extends StatefulWidget {
  final String? label;
  final TextEditingCController? controller;
  final String? initValue;
  final bool readonly;
  final bool obscureText;
  final bool scannable;
  final IconData? suffixIcon;
  final bool multiLine;
  final void Function(TextEditingCController txt)? onSubmit;
  final void Function(TextEditingCController txt)? onSuffixIconTab;

  final TextInputType? keyboardType;
  final void Function(String? value)? onSaved;
  final bool required;
  final String? Function(String value)? validator;

  final Function(String value)? onChanged;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.readonly = false,
    this.obscureText = false,
    this.initValue,
    this.label,
    this.onSubmit,
    this.scannable = false,
    this.suffixIcon,
    this.onSuffixIconTab,
    this.keyboardType,
    this.onSaved,
    this.required = false,
    this.validator,
    this.multiLine = false,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingCController _controller;

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  void _setupController() {
    _controller = widget.controller ?? TextEditingCController();
    if (widget.initValue != null) _controller.text = widget.initValue ?? "";
    if (_controller.labelState.state.isEmpty && widget.label != null) {
      _controller.updateLabel(widget.label ?? "");
    }
  }

  String? validator(String? value) {
    if (widget.required) {
      if (value == null || value.trim().isEmpty) {
        return "Campo requerido";
      }
    }
    if (widget.validator == null) return null;
    return widget.validator!(value ?? "");
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon;

    if (widget.scannable) {
      suffixIcon = IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        onPressed: () => openQrReader(context),
        color: Theme.of(context).colorScheme.surface,
        icon: const Icon(Icons.camera_alt),
      );
    } else if (widget.onSuffixIconTab != null) {
      suffixIcon = IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        onPressed: () => widget.onSuffixIconTab?.call(_controller),
        color: Theme.of(context).colorScheme.surface,
        icon: Icon(widget.suffixIcon ?? Icons.select_all),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _controller.labelState),
        BlocProvider.value(value: _controller.bottomLabelState),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 0,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  maxLines: widget.multiLine ? null : 1,
                  obscureText: widget.obscureText,
                  controller: _controller,
                  readOnly: widget.readonly,
                  focusNode: _controller.focus,
                  keyboardType: widget.keyboardType,
                  validator: validator,
                  onSaved: widget.onSaved,
                  onTap: () {
                    if (!widget.readonly) return;
                    widget.onSuffixIconTab?.call(_controller);
                  },
                  decoration: InputDecoration(
                    errorStyle:
                        const TextStyle(fontSize: 9, color: Colors.redAccent),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1.3,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    label: BlocBuilder<TextEditingLabelState, String>(
                      builder: (context, state) => Text(
                        state,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    handlePdaScan(value);
                    _controller.refreshWordsCount();
                  },
                  onFieldSubmitted: (_) => _secureOnSubmitCall(),
                ),
              ),
              if (suffixIcon != null)
                Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(360),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(child: suffixIcon),
                )
            ],
          ),
          BlocBuilder<TextEditingBottomLabelState, String>(
            builder: (context, state) {
              if (state.trim().isEmpty) return const SizedBox();
              return Text(
                state,
                style: const TextStyle(color: Colors.black54),
              );
            },
          ),
        ],
      ),
    );
  }

  void handlePdaScan(String inputValue) {
    if (widget.onSubmit == null) return;

    // inputValue is the input value, and _controller.wordCount is the current character count.
    // On manual typing, wordCount updates per keypress, but during fast scans, it may not update in time.
    if (inputValue.length - _controller.wordCount > 4) {
      final scannedText = inputValue.substring(_controller.wordCount).trim();
      _controller.text = scannedText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _secureOnSubmitCall();
    }
  }

  void openQrReader(BuildContext context) async {
    final scannedValue = await showKDialogContent<String>(
      context,
      hideTitleBar: true,
      closeOnOutsideTap: true,
      contentPadding: EdgeInsetsGeometry.zero,
      scrollPadding: EdgeInsetsGeometry.zero,
      titlePadding: EdgeInsetsGeometry.zero,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return QrCardReader(
          onScan: (code) {
            if (context.mounted) context.pop(code.trim());
          },
        );
      },
    );
    if (scannedValue == null || scannedValue.isEmpty) return;
    _controller.text = scannedValue;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _secureOnSubmitCall();
    _controller.refreshWordsCount();
  }

  bool _isSubmitting = false;
  void _secureOnSubmitCall() {
    if (_isSubmitting) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _isSubmitting = true;
    widget.onSubmit?.call(_controller);
    Future.delayed(const Duration(milliseconds: 5), () {
      _isSubmitting = false;
    });
  }
}
