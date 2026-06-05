import 'dart:async';

import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:dart_identity_sdk/src/managers/application_preferences.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_config.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_group.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_service.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableSyncBloc extends Cubit<TableSyncState> {
  final TableSyncConfig config;
  final Map<String, Timer> _timers = {};
  final Set<String> _runningGroups = {};

  TableSyncBloc(this.config) : super(_initialState(config));

  List<String> get groupIDs => config.groups.keys.toList(growable: false);

  List<String> get visibleGroupIDs => groupIDs;

  TableSyncGroup group(String groupID) {
    final group = config.groups[groupID];
    if (group == null) {
      throw ArgumentError('Unknown table sync group: `$groupID`.');
    }
    return group;
  }

  Duration every(String groupID) {
    final stored = AppPreferences.private.getInt(_everyKey(groupID));
    if (stored != null && stored > 0) return Duration(milliseconds: stored);
    return group(groupID).every;
  }

  String titleOf(String groupID) => group(groupID).title ?? groupID;

  bool isSyncing(String groupID) => state.group(groupID).syncing;

  bool hasError(String groupID) => state.group(groupID).hasError;

  String errorMessage(String groupID) => state.group(groupID).errorMessage;

  DateTime? lastRun(String groupID) => state.group(groupID).lastRun;

  bool isAutoSyncEnabled(String groupID) {
    return state.group(groupID).autoSyncEnabled;
  }

  Future<void> syncAll() async {
    LOG.printInfo(['TABLE_SYNC', 'syncAll requested', groupIDs.join(',')]);
    if (state.syncingAll) {
      LOG.printWarn(['TABLE_SYNC', 'syncAll ignored', 'already running']);
      return;
    }
    emit(state.copyWith(syncingAll: true));
    try {
      final batches = _buildParallelSyncBatches();
      for (var index = 0; index < batches.length; index++) {
        final batch = batches[index];
        LOG.printInfo([
          'TABLE_SYNC',
          'syncAll batch',
          '${index + 1}/${batches.length}',
          batch.join(','),
        ]);
        await Future.wait(batch.map(syncGroup));
      }
    } finally {
      if (!isClosed) emit(state.copyWith(syncingAll: false));
      LOG.printInfo(['TABLE_SYNC', 'syncAll finished']);
    }
  }

  Future<void> syncGroup(String groupID) async {
    LOG.printInfo(['TABLE_SYNC', groupID, 'manual sync requested']);
    if (_runningGroups.contains(groupID)) {
      LOG.printWarn(['TABLE_SYNC', groupID, 'ignored', 'already running']);
      return;
    }

    final startedAt = DateTime.now();
    final groupConfig = group(groupID);
    _runningGroups.add(groupID);
    _emitGroup(
      groupID,
      state.group(groupID).copyWith(
            syncing: true,
            hasError: false,
            errorMessage: '',
          ),
    );

    try {
      LOG.printInfo([
        'TABLE_SYNC',
        groupID,
        'started',
        'tables=${groupConfig.tables.join(',')}',
      ]);
      await TableSyncService(
        serviceID: groupConfig.serviceID ?? config.defaultServiceID,
      ).syncGroup(groupConfig);
      final now = DateTime.now();
      await AppPreferences.private
          .setString(_lastRunKey(groupID), now.toIso8601String());
      await _keepVisible(startedAt);
      _emitGroup(
        groupID,
        state.group(groupID).copyWith(
              syncing: false,
              hasError: false,
              errorMessage: '',
              lastRun: now,
            ),
      );
      LOG.printInfo(['TABLE_SYNC', groupID, 'finished']);
    } catch (error) {
      await _keepVisible(startedAt);
      LOG.printError(['TABLE_SYNC', groupID, 'error', error.toString()]);
      _emitGroup(
        groupID,
        state.group(groupID).copyWith(
              syncing: false,
              hasError: true,
              errorMessage: error.toString(),
            ),
      );
    } finally {
      _runningGroups.remove(groupID);
    }
  }

  Future<void> _keepVisible(DateTime startedAt) async {
    const minimumVisible = Duration(milliseconds: 450);
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimumVisible) {
      await Future<void>.delayed(minimumVisible - elapsed);
    }
  }

  List<List<String>> _buildParallelSyncBatches() {
    final batches = <List<String>>[];

    for (final groupID in groupIDs) {
      final groupTables = group(groupID).tables.toSet();
      var added = false;

      for (final batch in batches) {
        final hasCollision = batch.any((existingGroupID) {
          final existingTables = group(existingGroupID).tables.toSet();
          return existingTables.intersection(groupTables).isNotEmpty;
        });

        if (!hasCollision) {
          batch.add(groupID);
          added = true;
          break;
        }
      }

      if (!added) batches.add([groupID]);
    }

    return batches;
  }

  Future<void> startAll({bool syncOnStart = false}) async {
    for (final groupID in groupIDs) {
      await startGroup(groupID, syncOnStart: syncOnStart);
    }
  }

  Future<void> startConfiguredGroups() async {
    for (final entry in config.groups.entries) {
      if (state.group(entry.key).autoSyncEnabled) {
        await startGroup(entry.key, syncOnStart: entry.value.syncOnStart);
      } else if (entry.value.syncOnStart) {
        await syncGroup(entry.key);
      }
    }
  }

  Future<void> syncStartupGroups() async {
    for (final entry in config.groups.entries) {
      if (entry.value.syncOnStart) await syncGroup(entry.key);
    }
  }

  Future<void> startGroup(String groupID, {bool syncOnStart = false}) async {
    final groupState = state.group(groupID);
    if (!groupState.autoSyncEnabled) return;
    if (_timers[groupID] != null) {
      if (syncOnStart) await syncGroup(groupID);
      return;
    }

    _timers[groupID] =
        Timer.periodic(every(groupID), (_) => syncGroup(groupID));
    LOG.printInfo('$groupID: table sync timer started');
    if (syncOnStart) await syncGroup(groupID);
  }

  Future<void> stopAll() async {
    for (final groupID in groupIDs) {
      await stopGroup(groupID);
    }
  }

  Future<void> stopGroup(String groupID) async {
    _timers.remove(groupID)?.cancel();
  }

  Future<void> disableGroup(String groupID) async {
    await AppPreferences.private.setBool(_enabledKey(groupID), false);
    await stopGroup(groupID);
    _emitGroup(
      groupID,
      state.group(groupID).copyWith(autoSyncEnabled: false),
    );
  }

  Future<void> enableGroup(String groupID, {bool start = true}) async {
    await AppPreferences.private.setBool(_enabledKey(groupID), true);
    _emitGroup(
      groupID,
      state.group(groupID).copyWith(autoSyncEnabled: true),
    );
    if (start) await startGroup(groupID);
  }

  Future<void> updateGroupInterval(String groupID, Duration duration) async {
    final safeDuration =
        duration.inMilliseconds < 1 ? const Duration(minutes: 1) : duration;
    await AppPreferences.private
        .setInt(_everyKey(groupID), safeDuration.inMilliseconds);
    await stopGroup(groupID);
    await enableGroup(groupID);
  }

  void _emitGroup(String groupID, TableSyncGroupState groupState) {
    if (isClosed) return;
    emit(state.updateGroup(groupID, (_) => groupState));
  }

  @override
  Future<void> close() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    return super.close();
  }

  static TableSyncState _initialState(TableSyncConfig config) {
    return TableSyncState(
      groups: {
        for (final entry in config.groups.entries)
          entry.key: TableSyncGroupState(
            lastRun: _readLastRun(entry.key),
            autoSyncEnabled: _readEnabled(entry.key, entry.value),
          ),
      },
    );
  }

  static DateTime? _readLastRun(String groupID) {
    final stored = AppPreferences.private.getString(_lastRunKey(groupID));
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }

  static bool _readEnabled(String groupID, TableSyncGroup group) {
    return AppPreferences.private.getBool(_enabledKey(groupID)) ??
        group.autoSync;
  }

  static String _lastRunKey(String groupID) => 'table_sync_${groupID}_last_run';
  static String _enabledKey(String groupID) => 'table_sync_${groupID}_enabled';
  static String _everyKey(String groupID) => 'table_sync_${groupID}_every_ms';
}
