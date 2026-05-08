import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';

Future<List<T>?> showAsyncOptionsDialog<T extends SelectOption>(
  BuildContext context, {
  required Future<List<T>> Function() getOptions,
  List<String> initialSelection = const [],
  bool allowMultipleSelection = false,
  bool searchInput = false,
  String? title,
  String? acceptText,
  String? cancelText,
  bool useMaxHeight = false,
}) async {
  acceptText ??= strings.acceptButtonText;
  cancelText ??= strings.cancelButtonText;
  var options = await showAsyncProgressKDialog(
    context,
    doProcess: getOptions,
  );

  if (!context.mounted) return null;

  return await showBasicOptionsKDialog(
    context,
    options: options ?? [],
    initialSelection: initialSelection,
    allowMultipleSelection: allowMultipleSelection,
    searchInput: searchInput,
    title: title,
    acceptText: acceptText,
    cancelText: cancelText,
    useMaxHeight: useMaxHeight,
  );
}
