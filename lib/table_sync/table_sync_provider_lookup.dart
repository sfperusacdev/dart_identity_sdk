import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

TableSyncBloc? maybeTableSyncBloc(BuildContext context, {bool listen = false}) {
  try {
    return Provider.of<TableSyncBloc>(context, listen: listen);
  } on ProviderNotFoundException {
    return null;
  }
}

bool hasTableSyncProvider(BuildContext context, {bool listen = false}) {
  return maybeTableSyncBloc(context, listen: listen) != null;
}
