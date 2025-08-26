import 'package:dart_identity_sdk/widgets/scaffold/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_identity_sdk/widgets/scaffold/query_manager.dart';
import 'package:dart_identity_sdk/widgets/scaffold/state.dart';

class SingleScaffold<T> extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final PreferredSizeWidget Function(BuildContext context)? appBarBuilder;
  final Widget? floatingActionButton;
  final Future<T> Function() query;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;
  final Widget Function(String errorMessage)? errorBuilder;

  const SingleScaffold({
    super.key,
    required this.query,
    required this.builder,
    this.appBar,
    this.appBarBuilder,
    this.floatingActionButton,
    this.loading,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (this.appBar != null) {
      appBar = appBar;
    } else if (this.appBarBuilder != null) {
      appBar = AppBarBuilder(builder: this.appBarBuilder!);
    }
    return BlocProvider(
      create: (context) => QueryManager<T>(query: query)..refresh(),
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: BlocBuilder<QueryManager<T>, QueryState<T>>(
          builder: (context, state) {
            if (state.isLoading && state.rawdata == null) {
              return loading ??
                  const Center(
                    child: CircularProgressIndicator(),
                  );
            }

            if (state.hasError && state.rawdata == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    errorBuilder?.call(state.errorMessage) ??
                        Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.read<QueryManager<T>>().fetch(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return builder(context, state.rawdata as T);
          },
        ),
      ),
    );
  }
}
