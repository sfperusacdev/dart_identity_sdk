class SyncPayloadRequest {
  final String tableName;
  final int syncAt;
  final List<Map<String, Object?>> payload;

  const SyncPayloadRequest({
    required this.tableName,
    required this.syncAt,
    this.payload = const [],
  });

  Map<String, Object?> toMap() {
    return {
      'table_name': tableName,
      'sync_at': syncAt,
      'payload': payload,
    };
  }
}
