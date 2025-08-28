import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/sqlite/no_connected.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqlite;

class LiteDatabaseConfig {
  final bool sqliteDisabled;

  final int version;
  final sqlite.OnDatabaseCreateFn? onCreate;

  /// Duration in which the connection is considered "locked" after last usage.
  final Duration lockDuration;

  const LiteDatabaseConfig({
    this.sqliteDisabled = false,
    this.version = 1,
    this.onCreate,
    this.lockDuration = const Duration(seconds: 5),
  });

  /// Returns a config with SQLite disabled — connection will be skipped.
  factory LiteDatabaseConfig.disabled() {
    return const LiteDatabaseConfig(sqliteDisabled: true);
  }
}

class LiteConnection {
  static Future<sqlite.Database>? _dbFuture;
  static DateTime? _lastUsedAt;
  static Duration _lockDuration = const Duration(seconds: 5);
  static LiteDatabaseConfig? _config;

  static void setDatabaseConfig(LiteDatabaseConfig config) {
    if (_config != null) {
      throw Exception("Database config already set. Cannot override");
    }
    _config = config;
  }

  static Future<sqlite.Database> connect(String domain) async {
    _config ??= const LiteDatabaseConfig();
    if (_config!.sqliteDisabled) {
      _dbFuture = Future(() => NullDatabaseConnection());
      return _dbFuture!;
    }
    await closeIfConnected();
    _lockDuration = _config!.lockDuration;
    _dbFuture = _openDatabase(
      domain,
      version: _config!.version,
      onCreate: _config!.onCreate,
    );
    LOG.printInfo("Database connection established");
    return _dbFuture!;
  }

  static Future<void> closeIfConnected() async {
    final db = await _dbFuture;
    if (db != null) {
      await db.close();
      _dbFuture = null;
      _lastUsedAt = null;
      LOG.printInfo("Database connection closed");
    }
  }

  static Future<sqlite.Database> _openDatabase(
    String domain, {
    required int version,
    sqlite.OnDatabaseCreateFn? onCreate,
  }) async {
    final dir = await pathprovider.getExternalStorageDirectory();
    final basePath = dir?.path ?? await sqlite.getDatabasesPath();
    final dbPath = p.join(basePath, "${domain}_db.db");
    LOG.printInfo("Database path: $dbPath");

    return sqlite.openDatabase(
      dbPath,
      version: version,
      onCreate: onCreate,
    );
  }

  static Future<sqlite.Database> getConnection() async {
    if (_dbFuture == null) {
      throw Exception("Database not connected. Call connect() first");
    }

    _lastUsedAt = DateTime.now();
    return _dbFuture!;
  }

  /// Returns the database instance along with its availability status.
  /// This should be used only for automated background tasks where access must not
  /// interfere with interactive or user-driven operations (e.g., sync jobs).
  static Future<(sqlite.Database, bool)> getConnectionWithStatus() async {
    if (_dbFuture == null) {
      throw Exception("Database not connected. Call connect() first");
    }

    final db = await _dbFuture!;
    final locked = _isLocked();
    return (db, !locked);
  }

  static bool _isLocked() {
    if (_lastUsedAt == null) return false;
    return DateTime.now().difference(_lastUsedAt!) < _lockDuration;
  }
}
