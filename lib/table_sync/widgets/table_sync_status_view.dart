import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/widgets/table_sync_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableSyncStatusView extends StatelessWidget {
  final bool syncOnInit;
  final EdgeInsetsGeometry padding;

  const TableSyncStatusView({
    super.key,
    this.syncOnInit = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<TableSyncBloc>();
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          for (final groupID in bloc.visibleGroupIDs)
            TableSyncItem(groupID: groupID, syncOnInit: syncOnInit),
        ],
      ),
    );
  }
}
