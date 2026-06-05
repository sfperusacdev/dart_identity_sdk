import 'package:dart_identity_sdk/table_sync/table_sync_group.dart';

class TableSyncConfig {
  final String? defaultServiceID;
  final Map<String, TableSyncGroup> groups;

  TableSyncConfig({
    this.defaultServiceID,
    required Map<String, Object> groups,
  }) : groups = groups.map((key, value) => MapEntry(key, _parseGroup(value)));

  TableSyncConfig.fromGroups({
    this.defaultServiceID,
    required this.groups,
  });

  static TableSyncGroup _parseGroup(Object value) {
    if (value is TableSyncGroup) return value;
    if (value is List<String>) return TableSyncGroup(tables: value);
    if (value is List) return TableSyncGroup(tables: List<String>.from(value));
    throw ArgumentError('Invalid table sync group value: $value');
  }
}
