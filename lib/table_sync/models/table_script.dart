class TableScript {
  final String tableName;
  final String script;
  final int startSync;
  final int? retentionDays;
  final bool readOnly;
  final bool writeOnly;

  const TableScript({
    required this.tableName,
    required this.script,
    required this.startSync,
    this.retentionDays,
    this.readOnly = false,
    this.writeOnly = false,
  });

  factory TableScript.fromMap(Map<String, Object?> json) {
    return TableScript(
      tableName: json['table_name'] as String,
      script: (json['script'] as String?) ?? '',
      startSync: (json['start_sync'] as num?)?.toInt() ?? 0,
      retentionDays: (json['retention_days'] as num?)?.toInt(),
      readOnly: _readBool(json['read_only']),
      writeOnly: _readBool(json['write_only']),
    );
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
