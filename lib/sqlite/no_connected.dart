import 'package:sqflite/sqflite.dart' as sqlite;

class NullDatabaseConnection extends sqlite.Database {
  Exception _dbNotEnabled() => Exception(
      'Database is not enabled in this project. Please enable it in the project configuration.');

  @override
  sqlite.Batch batch() => throw _dbNotEnabled();

  @override
  sqlite.Database get database => throw _dbNotEnabled();

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      throw _dbNotEnabled();

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    sqlite.ConflictAlgorithm? conflictAlgorithm,
  }) =>
      throw _dbNotEnabled();

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) =>
      throw _dbNotEnabled();

  @override
  Future<sqlite.QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) =>
      throw _dbNotEnabled();

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<sqlite.QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) =>
      throw _dbNotEnabled();

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    sqlite.ConflictAlgorithm? conflictAlgorithm,
  }) =>
      throw _dbNotEnabled();

  @override
  Future<void> close() async {
    return;
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) =>
      throw _dbNotEnabled();

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
          [List<Object?>? arguments]) =>
      throw _dbNotEnabled();

  @override
  bool get isOpen => throw _dbNotEnabled();

  @override
  String get path => throw _dbNotEnabled();

  @override
  Future<T> readTransaction<T>(
          Future<T> Function(sqlite.Transaction txn) action) =>
      throw _dbNotEnabled();

  @override
  Future<T> transaction<T>(Future<T> Function(sqlite.Transaction txn) action,
          {bool? exclusive}) =>
      throw _dbNotEnabled();
}
