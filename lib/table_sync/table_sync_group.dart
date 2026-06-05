class TableSyncGroup {
  final String? title;
  final List<String> tables;
  final String? serviceID;
  final Duration every;
  final bool autoSync;
  final bool syncOnStart;

  const TableSyncGroup({
    this.title,
    required this.tables,
    this.serviceID,
    this.every = const Duration(minutes: 1),
    this.autoSync = true,
    this.syncOnStart = false,
  });
}
