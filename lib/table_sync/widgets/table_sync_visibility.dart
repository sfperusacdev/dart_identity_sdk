import 'package:dart_identity_sdk/table_sync/table_sync_provider_lookup.dart';
import 'package:flutter/widgets.dart';

class TableSyncVisibility extends StatelessWidget {
  final Widget child;
  final Widget replacement;

  const TableSyncVisibility({
    super.key,
    required this.child,
    this.replacement = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return hasTableSyncProvider(context) ? child : replacement;
  }
}
