import 'package:flutter/material.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_bottom_alert.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_confirmation.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_loadings.dart';
import 'package:dart_identity_sdk/kdialogs/src/strings.dart';

SnackBar _snackBar({String? message}) {
  message ??= 'Operation completed successfully';
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 1500),
    content: Text(message),
  );
}

Future<void Function()> _showLoading(
  BuildContext context, {
  String? loadingMessage,
}) {
  if (loadingMessage == null) {
    return showKDialogWithLoadingIndicator(context);
  }

  return showKDialogWithLoadingMessage(context, message: loadingMessage);
}

Future<T?> showAsyncProgressKDialog<T>(
  BuildContext context, {
  Future<void> Function()? validateBeforeProcess,
  required Future<T> Function() doProcess,
  void Function(T value)? onSuccess,
  void Function(String errMessage)? onError,
  bool retryable = false,
  bool confirmationRequired = false,
  String? confirmationTitle,
  String? confirmationMessage,
  bool showSuccessSnackBar = false,
  String? successMessage,
  String? errorAcceptText,
  String? errorRetryText,
  String? loadingMessage,
  String? bottomErrorAlertTitle,
  String? validationErrorTitle,
  String? validationConfirmText,
  String? validationCancelText,
}) async {
  confirmationMessage ??= strings.confirmationMessage;
  errorAcceptText ??= strings.acceptButtonText;
  errorRetryText ??= strings.errorRetryText;
  validationConfirmText ??= strings.confirmButtonText;
  validationCancelText ??= strings.cancelButtonText;

  if (confirmationRequired) {
    final confirmed = await showConfirmationKDialog(
      context,
      title: confirmationTitle,
      message: confirmationMessage,
    );
    if (!confirmed) return null;
  }

  if (validateBeforeProcess != null) {
    if (!context.mounted) return null;

    final closeloader = await _showLoading(
      context,
      loadingMessage: loadingMessage,
    );

    Object? validationError;
    try {
      await validateBeforeProcess();
    } catch (err) {
      validationError = err;
    } finally {
      closeloader();
    }

    if (validationError != null) {
      if (!context.mounted) return null;

      final confirmed = await showConfirmationKDialog(
        context,
        title: validationErrorTitle,
        message: validationError.toString(),
        acceptText: validationConfirmText,
        cancelText: validationCancelText,
      );
      if (!confirmed) return null;
    }
  }

  if (context.mounted) {
    final closeloader = await _showLoading(
      context,
      loadingMessage: loadingMessage,
    );
    T? results;
    Object? processError;
    try {
      results = await doProcess();
    } catch (err) {
      processError = err;
    } finally {
      closeloader();
    }

    if (processError == null) {
      if (onSuccess != null && results != null) onSuccess(results);

      if (context.mounted && (showSuccessSnackBar || successMessage != null)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snackBar(message: successMessage));
      }
    } else {
      bool? retry;
      if (context.mounted) {
        retry = await showBottomAlertKDialog(
          title: bottomErrorAlertTitle,
          context,
          message: processError.toString(),
          retryable: retryable,
          acceptText: errorAcceptText,
          retryText: errorRetryText,
          errorSound: true,
        );
      }

      if ((retry ?? false) && context.mounted) {
        return await showAsyncProgressKDialog(
          context,
          doProcess: doProcess,
          onError: onError,
          onSuccess: onSuccess,
          retryable: retryable,
          showSuccessSnackBar: showSuccessSnackBar,
          successMessage: successMessage,
          errorAcceptText: errorAcceptText,
          errorRetryText: errorRetryText,
          loadingMessage: loadingMessage,
          bottomErrorAlertTitle: bottomErrorAlertTitle,
        );
      }

      if (onError != null) onError(processError.toString());
    }
    return results;
  }

  return null;
}
