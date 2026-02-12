import 'package:dart_identity_sdk/widgets/query/empty_placeholder.dart';
import 'package:dart_identity_sdk/widgets/query/query_controller.dart';
import 'package:dart_identity_sdk/widgets/scaffold/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueryView<T> extends StatelessWidget {
  final QueryController<T> controller;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;
  final Widget Function(BuildContext context, String error)? error;
  final bool showEmptyPlaceholder;
  final String emptyPlaceholderMessage;
  final Widget? emptyPlaceholder;

  const QueryView({
    super.key,
    required this.controller,
    required this.builder,
    this.loading,
    this.error,
    this.showEmptyPlaceholder = true,
    this.emptyPlaceholderMessage = "No hay ningún registro",
    this.emptyPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueryController<T>, QueryState<T>>(
      bloc: controller,
      builder: (context, state) {
        if (state.isLoading) {
          if (loading != null) {
            return loading!;
          }
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          if (error != null) {
            return error!(context, state.errorMessage);
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.refresh(silent: false),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            ),
          );
        }
        final rawdata = state.rawdata;
        if (showEmptyPlaceholder &&
            (rawdata == null || rawdata is List && rawdata.isEmpty)) {
          return emptyPlaceholder ??
              EmptyPlaceholder(
                message: emptyPlaceholderMessage,
                onRefresh: () => controller.refresh(silent: false),
              );
        }
        if (rawdata != null) {
          return builder(context, controller.data as T);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
