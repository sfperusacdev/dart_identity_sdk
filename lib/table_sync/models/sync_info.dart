class SyncInfo {
  final String tableName;
  final int syncAt;
  final int? retentionDays;
  final bool readOnly;
  final bool writeOnly;

  const SyncInfo({
    required this.tableName,
    required this.syncAt,
    this.retentionDays,
    this.readOnly = false,
    this.writeOnly = false,
  });

  factory SyncInfo.fromMap(Map<String, Object?> json) {
    return SyncInfo(
      tableName: json['table_name'] as String,
      syncAt: (json['sync_at'] as num?)?.toInt() ?? 0,
      retentionDays: (json['retention_days'] as num?)?.toInt(),
      readOnly: _readBool(json['read_only']),
      writeOnly: _readBool(json['write_only']),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'table_name': tableName,
      'sync_at': syncAt,
      'retention_days': retentionDays,
      'read_only': readOnly ? 1 : 0,
      'write_only': writeOnly ? 1 : 0,
    };
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
