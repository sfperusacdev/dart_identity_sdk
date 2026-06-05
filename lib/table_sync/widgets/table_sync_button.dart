import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableSyncButton extends StatelessWidget {
  final List<String> groupIDs;
  final VoidCallback? onRefresh;
  final Color? color;

  const TableSyncButton({
    super.key,
    required this.groupIDs,
    this.onRefresh,
    this.color,
  }) : assert(groupIDs.length > 0, 'groupIDs cannot be empty');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableSyncBloc, TableSyncState>(
      builder: (context, state) {
        final syncing = groupIDs.any((groupID) => state.group(groupID).syncing);
        final hasError =
            groupIDs.any((groupID) => state.group(groupID).hasError);
        final iconColor = color ?? Theme.of(context).colorScheme.secondary;

        return IconButton(
          onPressed: () async {
            final syncBloc = context.read<TableSyncBloc>();
            for (final groupID in groupIDs) {
              await syncBloc.syncGroup(groupID);
            }
            onRefresh?.call();
          },
          icon: syncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: iconColor),
                )
              : Icon(
                  Icons.sync,
                  color: hasError ? Colors.red : iconColor,
                ),
        );
      },
    );
  }
}
