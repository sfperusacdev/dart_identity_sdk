import 'package:dart_identity_sdk/table_sync/table_sync_bloc.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_state.dart';
import 'package:dart_identity_sdk/table_sync/widgets/table_sync_settings_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TableSyncItem extends StatefulWidget {
  final String groupID;
  final bool syncOnInit;

  const TableSyncItem({
    super.key,
    required this.groupID,
    this.syncOnInit = false,
  });

  @override
  State<TableSyncItem> createState() => _TableSyncItemState();
}

class _TableSyncItemState extends State<TableSyncItem> {
  @override
  void initState() {
    super.initState();
    if (widget.syncOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<TableSyncBloc>().syncGroup(widget.groupID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableSyncBloc, TableSyncState>(
      builder: (context, state) {
        final bloc = context.read<TableSyncBloc>();
        final groupState = state.group(widget.groupID);
        final color = groupState.autoSyncEnabled
            ? Colors.white
            : const Color.fromARGB(255, 255, 220, 218);

        return Card(
          color: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(bloc.titleOf(widget.groupID))),
                    InkWell(
                      onTap: () => _showSettings(context, bloc),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.settings, size: 16),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupState.autoSyncEnabled
                          ? 'sync cada ${_formatDuration(bloc.every(widget.groupID))}'
                          : 'auto sync off',
                    ),
                    if (groupState.syncing) const Text('sincronizando...'),
                    if (groupState.lastRun != null)
                      Text(_formatDate(groupState.lastRun!)),
                  ],
                ),
                trailing: IconButton(
                  icon: groupState.syncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  onPressed: () =>
                      context.read<TableSyncBloc>().syncGroup(widget.groupID),
                ),
              ),
              if (groupState.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    groupState.errorMessage,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                  ),
                ),
              if (groupState.syncing)
                LinearProgressIndicator(
                  color: Colors.blue,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSettings(BuildContext context, TableSyncBloc bloc) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Sincronizar ${bloc.titleOf(widget.groupID)}'),
          content: TableSyncSettingsBox(
            every: bloc.every(widget.groupID),
            autoSync: bloc.isAutoSyncEnabled(widget.groupID),
            onSave: (autoSync, every) async {
              if (autoSync) {
                await bloc.updateGroupInterval(widget.groupID, every);
              } else {
                await bloc.disableGroup(widget.groupID);
              }
            },
          ),
        );
      },
    );
  }
}

String _formatDate(DateTime value) {
  return '${DateFormat.yMd().format(value)} ${DateFormat.jm().format(value)}';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) return '$minutes minuto${minutes == 1 ? '' : 's'}';
  final hours = minutes ~/ 60;
  if (minutes % 60 == 0 && hours < 24) {
    return '$hours hora${hours == 1 ? '' : 's'}';
  }
  if (minutes % 1440 == 0) {
    final days = minutes ~/ 1440;
    return '$days dia${days == 1 ? '' : 's'}';
  }
  return '$minutes minutos';
}
