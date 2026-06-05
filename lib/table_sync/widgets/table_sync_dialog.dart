import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/widgets/table_sync_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showTableSyncDialog(
  BuildContext context, {
  String title = 'Sincronizacion',
  bool syncOnInit = true,
  bool closeOnOutsideTap = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: closeOnOutsideTap,
    builder: (dialogContext) {
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          color: Theme.of(dialogContext).primaryColor,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => context.read<TableSyncBloc>().syncAll(),
                icon: const Icon(Icons.sync, color: Colors.white),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(dialogContext).size.width * 0.8,
          height: MediaQuery.of(dialogContext).size.height * 0.6,
          child: TableSyncStatusView(syncOnInit: syncOnInit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
