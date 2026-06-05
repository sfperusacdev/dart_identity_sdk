class TableSyncGroupState {
  final bool syncing;
  final bool hasError;
  final String errorMessage;
  final DateTime? lastRun;
  final bool autoSyncEnabled;

  const TableSyncGroupState({
    this.syncing = false,
    this.hasError = false,
    this.errorMessage = '',
    this.lastRun,
    this.autoSyncEnabled = true,
  });

  TableSyncGroupState copyWith({
    bool? syncing,
    bool? hasError,
    String? errorMessage,
    DateTime? lastRun,
    bool? autoSyncEnabled,
  }) {
    return TableSyncGroupState(
      syncing: syncing ?? this.syncing,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRun: lastRun ?? this.lastRun,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
    );
  }
}

class TableSyncState {
  final Map<String, TableSyncGroupState> groups;
  final bool syncingAll;

  const TableSyncState({
    this.groups = const {},
    this.syncingAll = false,
  });

  TableSyncState copyWith({
    Map<String, TableSyncGroupState>? groups,
    bool? syncingAll,
  }) {
    return TableSyncState(
      groups: groups ?? this.groups,
      syncingAll: syncingAll ?? this.syncingAll,
    );
  }

  TableSyncGroupState group(String groupID) {
    return groups[groupID] ?? const TableSyncGroupState();
  }

  TableSyncState updateGroup(
    String groupID,
    TableSyncGroupState Function(TableSyncGroupState current) update,
  ) {
    return copyWith(
      groups: {
        ...groups,
        groupID: update(group(groupID)),
      },
    );
  }
}
