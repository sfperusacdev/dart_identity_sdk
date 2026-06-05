import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableSyncProvider extends StatelessWidget {
  final TableSyncConfig config;
  final Widget child;

  const TableSyncProvider({
    super.key,
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TableSyncBloc>(
      create: (_) => TableSyncBloc(config),
      child: child,
    );
  }
}
