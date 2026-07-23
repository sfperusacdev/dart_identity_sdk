import 'package:dart_identity_sdk/src/bases/services.dart';
import 'package:dart_identity_sdk/src/logs/log.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:dart_identity_sdk/table_sync/models/sync_info.dart';
import 'package:dart_identity_sdk/table_sync/models/sync_request.dart';
import 'package:dart_identity_sdk/table_sync/models/sync_response.dart';
import 'package:dart_identity_sdk/table_sync/models/table_script.dart';
import 'package:dart_identity_sdk/table_sync/table_sync_group.dart';
import 'package:dart_identity_sdk/utils/internet.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

const defaultTableSyncServiceID = 'com.sfperusac.tareoapp';

class TableSyncService {
  final String serviceID;

  const TableSyncService({String? serviceID})
      : serviceID = serviceID ?? defaultTableSyncServiceID;

  Future<void> syncGroup(TableSyncGroup group) async {
    LOG.printInfo([
      'TABLE_SYNC_SERVICE',
      'group started',
      'service=$serviceID',
      'tables=${group.tables.join(',')}',
    ]);
    final connected = await InternetService.hasInternet();
    if (!connected) {
      LOG.printWarn(['TABLE_SYNC_SERVICE', 'group skipped', 'no internet']);
      throw StateError('No hay conexión a internet.');
    }

    await ensureSyncInfoTable();
    await syncTableSchemas(group.tables);

    final syncInfo = await _readSyncInfo();
    for (final tableName in group.tables) {
      _validateSqlIdentifier(tableName, 'table');
      LOG.printInfo(['TABLE_SYNC_SERVICE', tableName, 'table requested']);
      final info = syncInfo[tableName];
      if (info == null) {
        LOG.printError(['TABLE_SYNC_SERVICE', tableName, 'missing sync_info']);
        throw StateError(
          'No sync info found for table `$tableName`. The table was not initialized.',
        );
      }
      await _syncTable(tableName, info);
    }
  }

  Future<void> ensureSyncInfoTable() async {
    final (conn, _) = await LiteConnection.getConnectionWithStatus();
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS sync_info (
        table_name      VARCHAR(100) PRIMARY KEY,
        sync_at         INTEGER,
        retention_days  INTEGER,
        read_only       INTEGER DEFAULT 0,
        write_only      INTEGER DEFAULT 0
      );
    ''');
    await _ensureSyncInfoColumn(conn, 'write_only', 'INTEGER DEFAULT 0');
    LOG.printInfo(['TABLE_SYNC_SERVICE', 'sync_info ensured']);
  }

  Future<void> syncTableSchemas(List<String> tables) async {
    for (final tableName in tables) {
      _validateSqlIdentifier(tableName, 'table');
    }

    LOG.printInfo([
      'TABLE_SYNC_SERVICE',
      'metadata request',
      'tables=${tables.join(',')}',
    ]);
    final scripts = await _getTablesQueries(tables);
    LOG.printInfo([
      'TABLE_SYNC_SERVICE',
      'metadata received',
      'count=${scripts.length}',
    ]);
    final (conn, _) = await LiteConnection.getConnectionWithStatus();

    for (final script in scripts) {
      _validateSqlIdentifier(script.tableName, 'table');
      LOG.printInfo([
        'TABLE_SYNC_SERVICE',
        script.tableName,
        'metadata',
        'readOnly=${script.readOnly}',
        'writeOnly=${script.writeOnly}',
        'retentionDays=${script.retentionDays}',
      ]);

      if (!await _existsTable(script.tableName)) {
        LOG.printInfo(
            ['TABLE_SYNC_SERVICE', script.tableName, 'creating table']);
        await _executeScript(conn, script.script);
      }

      final existingInfo = await conn.query(
        'sync_info',
        where: 'table_name = ?',
        whereArgs: [script.tableName],
        limit: 1,
      );
      if (existingInfo.isEmpty) {
        await conn.insert(
          'sync_info',
          SyncInfo(
            tableName: script.tableName,
            syncAt: script.startSync,
            retentionDays: script.retentionDays,
            readOnly: script.readOnly,
            writeOnly: script.writeOnly,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await conn.update(
          'sync_info',
          {
            'retention_days': script.retentionDays,
            'read_only': script.readOnly ? 1 : 0,
            'write_only': script.writeOnly ? 1 : 0,
          },
          where: 'table_name = ?',
          whereArgs: [script.tableName],
        );
      }

      LOG.printInfo(['table sync initialized:', script.tableName]);
    }
  }

  Future<List<TableScript>> _getTablesQueries(List<String> tables) async {
    final result = await ApiService.post(
      path: '/v1/sync_data/tabla_info',
      payload: tables,
      serviceID: serviceID,
    );
    return List<TableScript>.from(
      (result as Iterable).map(
        (json) => TableScript.fromMap(Map<String, Object?>.from(json as Map)),
      ),
    );
  }

  Future<bool> _existsTable(String tableName) async {
    final (conn, _) = await LiteConnection.getConnectionWithStatus();
    final result = await conn.query(
      'sqlite_master',
      columns: ['tbl_name'],
      where: 'tbl_name = ?',
      whereArgs: [tableName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> _executeScript(Database conn, String script) async {
    final parts = script.split(';');
    for (final query in parts) {
      final trimmed = query.trim();
      if (trimmed.isEmpty) continue;
      await conn.execute(trimmed);
    }
  }

  Future<void> _ensureSyncInfoColumn(
    Database conn,
    String columnName,
    String columnDefinition,
  ) async {
    final columns = await conn.rawQuery('PRAGMA table_info(sync_info)');
    final exists = columns.any((column) => column['name'] == columnName);
    if (!exists) {
      await conn.execute(
          'ALTER TABLE sync_info ADD COLUMN $columnName $columnDefinition');
    }
  }

  Future<Map<String, SyncInfo>> _readSyncInfo() async {
    final (conn, _) = await LiteConnection.getConnectionWithStatus();
    final info = await conn.query('sync_info');
    return {
      for (final item in info)
        SyncInfo.fromMap(item).tableName: SyncInfo.fromMap(item),
    };
  }

  Future<void> _syncTable(String tableName, SyncInfo info) async {
    final unixMill = DateTime.now().millisecondsSinceEpoch;
    final (conn, _) = await LiteConnection.getConnectionWithStatus();
    var localPayload = <Map<String, Object?>>[];

    LOG.printInfo([
      'TABLE_SYNC_SERVICE',
      tableName,
      'sync table started',
      'syncAt=${info.syncAt}',
      'readOnly=${info.readOnly}',
      'writeOnly=${info.writeOnly}',
    ]);

    if (!info.readOnly) {
      localPayload = await conn.query(
        tableName,
        where: 'sync_at > ? and sync_at <= ?',
        whereArgs: [info.syncAt, unixMill],
      );
    }
    LOG.printInfo(
        ['TABLE_SYNC_SERVICE', tableName, 'to send', localPayload.length]);

    final serverResponse = await _querySyncServer(
      SyncPayloadRequest(
        tableName: tableName,
        syncAt: info.syncAt,
        payload: localPayload,
      ),
    );
    LOG.printInfo([
      'TABLE_SYNC_SERVICE',
      tableName,
      'from server',
      serverResponse.payload.length,
      'identifiers=${serverResponse.identifiers.join(',')}',
    ]);

    final remotePayload = info.writeOnly
        ? <Map<String, Object?>>[]
        : serverResponse.payload.map(Map<String, Object?>.from).toList();

    if (remotePayload.isNotEmpty) {
      await _saveRemotePayload(
        conn,
        tableName,
        serverResponse.identifiers,
        remotePayload,
      );
    }

    await _applyRetentionPolicy(conn, tableName, info, unixMill);
    await _updateSyncInfo(tableName, unixMill);
    LOG.printInfo(
        ['TABLE_SYNC_SERVICE', tableName, 'sync table finished', unixMill]);
  }

  Future<SyncPayloadResponse> _querySyncServer(
      SyncPayloadRequest request) async {
    try {
      LOG.printInfo([
        'TABLE_SYNC_SERVICE',
        request.tableName,
        'api sync request',
        'payload=${request.payload.length}',
      ]);
      final response = await ApiService.post(
        path: '/v1/sync_data/sync',
        payload: request.toMap(),
        serviceID: serviceID,
      );
      return SyncPayloadResponse.fromMap(
        Map<String, Object?>.from(response as Map),
      );
    } catch (error) {
      LOG.printError(['_querySyncServer', error.toString()]);
      rethrow;
    }
  }

  Future<void> _saveRemotePayload(
    Database conn,
    String tableName,
    List<String> identifiers,
    List<Map<String, Object?>> payload,
  ) async {
    final countResult = await conn.rawQuery(
      'select count(*) from (select * from $tableName limit 1)',
    );
    final numRows = sqlite.Sqflite.firstIntValue(countResult) ?? 0;
    if (numRows == 0) {
      LOG.printInfo(
          ['TABLE_SYNC_SERVICE', tableName, 'insert batch', payload.length]);
      await _insertBatch(conn, tableName, payload);
      return;
    }

    if (identifiers.isEmpty) {
      throw StateError('No identifiers received for table `$tableName`.');
    }
    for (final identifier in identifiers) {
      _validateSqlIdentifier(identifier, 'identifier');
    }

    for (final item in payload) {
      await _insertUpdate(conn, tableName, identifiers, item);
    }
    LOG.printInfo(
        ['TABLE_SYNC_SERVICE', tableName, 'upsert finished', payload.length]);
  }

  Future<void> _updateSyncInfo(String tableName, int syncAt) async {
    final (conn, _) = await LiteConnection.getConnectionWithStatus();
    await conn.update(
      'sync_info',
      {'sync_at': syncAt},
      where: 'table_name = ?',
      whereArgs: [tableName],
    );
  }

  Future<void> _applyRetentionPolicy(
    Database conn,
    String tableName,
    SyncInfo info,
    int nowMillis,
  ) async {
    final retentionDays = info.retentionDays;
    if (retentionDays == null || retentionDays <= 0) return;
    if (!await _hasColumn(conn, tableName, 'sync_at')) return;

    final cutoff = nowMillis - Duration(days: retentionDays).inMilliseconds;
    final deleted = await conn.delete(
      tableName,
      where: 'sync_at < ?',
      whereArgs: [cutoff],
    );
    if (deleted > 0) {
      LOG.printInfo(['RETENTION', tableName, 'deleted', deleted]);
    }
  }

  Future<bool> _hasColumn(
    Database conn,
    String tableName,
    String columnName,
  ) async {
    _validateSqlIdentifier(tableName, 'table');
    _validateSqlIdentifier(columnName, 'column');
    final columns = await conn.rawQuery('PRAGMA table_info($tableName)');
    return columns.any((column) => column['name'] == columnName);
  }

  Future<void> _insertBatch(
    Database conn,
    String tableName,
    List<Map<String, Object?>> data,
  ) async {
    final batch = conn.batch();
    for (final item in data) {
      batch.insert(tableName, _sanitizeMap(item));
    }
    await batch.commit(noResult: true);
  }

  Future<void> _insertUpdate(
    Database conn,
    String tableName,
    List<String> identifiers,
    Map<String, Object?> data,
  ) async {
    final sanitizedData = _sanitizeMap(data);
    final where =
        identifiers.map((identifier) => '$identifier = ?').join(' and ');
    final whereArgs =
        identifiers.map((identifier) => sanitizedData[identifier]).toList();
    final existing =
        await conn.query(tableName, where: where, whereArgs: whereArgs);
    if (existing.isEmpty) {
      await conn.insert(
        tableName,
        sanitizedData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await conn.update(
        tableName,
        sanitizedData,
        where: where,
        whereArgs: whereArgs,
      );
    }
  }

  Map<String, Object?> _sanitizeMap(Map<String, Object?> values) {
    return values.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0);
      }

      return MapEntry(key, value);
    });
  }

  void _validateSqlIdentifier(String value, String label) {
    final validIdentifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
    if (!validIdentifier.hasMatch(value)) {
      throw ArgumentError('Invalid SQL $label: `$value`.');
    }
  }
}
