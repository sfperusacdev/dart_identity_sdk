import 'package:dart_identity_sdk/widgets/scaffold/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_identity_sdk/widgets/scaffold/query_manager.dart';

class ListScaffold<T> extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final PreferredSizeWidget Function(BuildContext context)? appBarBuilder;
  final Future<List<T>> Function() query;
  final bool Function(T item, String filter)? filterPredicate;

  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? loading;
  final Widget? empty;
  final String? loadingMessage;
  final String? emptyMessage;
  final String? errorMessage;
  final Widget? floatingActionButton;

  const ListScaffold({
    super.key,
    required this.query,
    this.filterPredicate,
    required this.itemBuilder,
    this.appBar,
    this.appBarBuilder,
    this.loading,
    this.empty,
    this.floatingActionButton,
    this.loadingMessage = 'Cargando datos...',
    this.emptyMessage = 'No hay datos disponibles',
    this.errorMessage = 'Ocurrió un error al cargar los datos',
  });

  List<T> _filterCallback(List<T> items, String filter) {
    if (filterPredicate == null) return items;
    return items.where((itm) => filterPredicate!(itm, filter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (this.appBar != null) {
      appBar = appBar;
    } else if (this.appBarBuilder != null) {
      appBar = AppBarBuilder(builder: this.appBarBuilder!);
    }

    return BlocProvider(
      create: (context) => QueryManager<List<T>>(
        query: query,
        filterCallback: _filterCallback,
      )..refresh(),
      child: Scaffold(
        appBar: appBar,
        body: Builder(
          builder: (context) {
            final query = context.watch<QueryManager<List<T>>>();
            if (query.state.isLoading && query.state.rawdata == null) {
              return loading ??
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(loadingMessage ?? ""),
                        const SizedBox(height: 8),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
            }

            if (query.state.hasError && query.state.rawdata == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$errorMessage: ${query.state.errorMessage}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<QueryManager<List<T>>>().fetch(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if ((query.state.rawdata ?? []).isEmpty) {
              return empty ??
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emptyMessage ?? "No hay datos"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QueryManager<List<T>>>().fetch();
                          },
                          child: const Text('Refrescar'),
                        ),
                      ],
                    ),
                  );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<QueryManager<List<T>>>().refresh(silent: true),
              child: ListView.builder(
                itemCount: (query.data ?? []).length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, query.data![index]),
              ),
            );
          },
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
