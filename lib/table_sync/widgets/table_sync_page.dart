import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_state.dart';
import 'package:dart_identity_sdk/table_sync/widgets/table_sync_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableSyncPage extends StatelessWidget {
  static const path = '/syncronizar';
  final String title;
  final bool syncOnInit;
  final EdgeInsetsGeometry padding;

  const TableSyncPage({
    super.key,
    this.title = 'Sincronizacion',
    this.syncOnInit = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          BlocBuilder<TableSyncBloc, TableSyncState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () => context.read<TableSyncBloc>().syncAll(),
                icon: state.syncingAll
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
              );
            },
          ),
        ],
      ),
      body: TableSyncStatusView(syncOnInit: syncOnInit, padding: padding),
    );
  }
}
