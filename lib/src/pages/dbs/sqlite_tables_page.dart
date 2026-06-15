import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:dart_identity_sdk/widgets/query/query_controller.dart';
import 'package:dart_identity_sdk/widgets/query/query_view.dart';
import 'package:flutter/material.dart';

class SqliteTablesPage extends StatelessWidget {
  static const path = '/_/database/tables';

  const SqliteTablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SqliteTablesView();
  }
}

class _SqliteTableInfo {
  final String name;
  final int rows;

  const _SqliteTableInfo({
    required this.name,
    required this.rows,
  });
}

class _SqliteTableData {
  final List<Map<String, Object?>> rows;
  final int totalRows;
  final int offset;
  final int limit;
  final _RecordIdentifier? identifier;

  const _SqliteTableData({
    required this.rows,
    required this.totalRows,
    required this.offset,
    required this.limit,
    required this.identifier,
  });
}

class _RecordIdentifier {
  final String column;
  final bool isRowId;

  const _RecordIdentifier({required this.column, required this.isRowId});
}

enum _SqliteTableAction { delete }

enum _SqliteRecordAction { delete }

const _rowIdAlias = '_sdk_rowid_';

class _SqliteTablesView extends StatefulWidget {
  const _SqliteTablesView();

  @override
  State<_SqliteTablesView> createState() => _SqliteTablesViewState();
}

class _SqliteTablesViewState extends State<_SqliteTablesView> {
  late final QueryController<List<_SqliteTableInfo>, void> _controller;

  @override
  void initState() {
    super.initState();
    _controller = QueryController(fetchCallback: (_) => _loadTables());
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<List<_SqliteTableInfo>> _loadTables() async {
    final db = await LiteConnection.getConnection();
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' "
      "AND name != 'android_metadata' "
      "ORDER BY name COLLATE NOCASE",
    );

    final result = <_SqliteTableInfo>[];
    for (final table in tables) {
      final name = table['name'] as String;
      final quotedName = _quoteIdentifier(name);
      final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $quotedName');
      result.add(
        _SqliteTableInfo(
          name: name,
          rows: (rows.first['total'] as int?) ?? 0,
        ),
      );
    }
    return result;
  }

  Future<void> _deleteTable(BuildContext context, _SqliteTableInfo table) async {
    final confirmed = await showConfirmationKDialog(
      context,
      title: 'Eliminar tabla',
      message:
          'Se eliminará la tabla "${table.name}" y todos sus registros. Esta acción no se puede deshacer.',
      acceptText: 'Eliminar',
    );
    if (!confirmed) return;

    final db = await LiteConnection.getConnection();
    await db.execute('DROP TABLE ${_quoteIdentifier(table.name)}');
    await _controller.refresh(silent: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablas SQLite'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => _controller.refresh(silent: false),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: QueryView(
        controller: _controller,
        emptyPlaceholderMessage: 'No hay tablas SQLite',
        builder: (context, tables) {
          return RefreshIndicator(
            onRefresh: () => _controller.refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tables.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final table = tables[index];
                return ListTile(
                  leading: const Icon(Icons.table_chart_outlined),
                  title: Text(table.name),
                  subtitle: Text('${table.rows} registros'),
                  trailing: PopupMenuButton<_SqliteTableAction>(
                    onSelected: (action) {
                      if (action == _SqliteTableAction.delete) {
                        _deleteTable(context, table);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _SqliteTableAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Eliminar tabla'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _SqliteTableDetailPage(
                          tableName: table.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SqliteTableDetailPage extends StatefulWidget {
  final String tableName;

  const _SqliteTableDetailPage({required this.tableName});

  @override
  State<_SqliteTableDetailPage> createState() => _SqliteTableDetailPageState();
}

class _SqliteTableDetailPageState extends State<_SqliteTableDetailPage> {
  static const _limit = 100;
  int _page = 0;
  late final QueryController<_SqliteTableData, void> _controller;

  @override
  void initState() {
    super.initState();
    _controller = QueryController(fetchCallback: (_) => _loadData());
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<_SqliteTableData> _loadData() async {
    final db = await LiteConnection.getConnection();
    final quotedName = _quoteIdentifier(widget.tableName);
    final offset = _page * _limit;
    final identifier = await _findRecordIdentifier(quotedName);
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $quotedName',
    );
    final rows = await _loadRows(quotedName, offset, identifier);
    return _SqliteTableData(
      rows: rows,
      totalRows: (countRows.first['total'] as int?) ?? 0,
      offset: offset,
      limit: _limit,
      identifier: rows.isEmpty ? identifier : _validIdentifier(rows, identifier),
    );
  }

  Future<_RecordIdentifier?> _findRecordIdentifier(String quotedName) async {
    final db = await LiteConnection.getConnection();
    final columns = await db.rawQuery('PRAGMA table_info($quotedName)');
    final pkColumns = columns.where((column) => column['pk'] != 0).toList();
    if (pkColumns.length == 1) {
      return _RecordIdentifier(
        column: pkColumns.first['name']?.toString() ?? '',
        isRowId: false,
      );
    }
    return const _RecordIdentifier(column: _rowIdAlias, isRowId: true);
  }

  Future<List<Map<String, Object?>>> _loadRows(
    String quotedName,
    int offset,
    _RecordIdentifier? identifier,
  ) async {
    final db = await LiteConnection.getConnection();
    final select = identifier?.isRowId == true ? 'rowid AS $_rowIdAlias, *' : '*';
    try {
      return db.rawQuery(
        'SELECT $select FROM $quotedName LIMIT $_limit OFFSET $offset',
      );
    } catch (_) {
      if (identifier?.isRowId != true) rethrow;
      return db.rawQuery('SELECT * FROM $quotedName LIMIT $_limit OFFSET $offset');
    }
  }

  _RecordIdentifier? _validIdentifier(
    List<Map<String, Object?>> rows,
    _RecordIdentifier? identifier,
  ) {
    if (identifier == null || rows.isEmpty) return identifier;
    return rows.first.containsKey(identifier.column) ? identifier : null;
  }

  void _goToPreviousPage() {
    if (_page == 0) return;
    setState(() => _page--);
    _controller.refresh(silent: false);
  }

  void _goToNextPage(_SqliteTableData data) {
    if (data.offset + data.rows.length >= data.totalRows) return;
    setState(() => _page++);
    _controller.refresh(silent: false);
  }

  Future<void> _deleteRecord(_SqliteTableData data, Map<String, Object?> row) async {
    final identifier = data.identifier;
    if (identifier == null) return;

    final confirmed = await showConfirmationKDialog(
      context,
      title: 'Eliminar registro',
      message: 'Se eliminará este registro. Esta acción no se puede deshacer.',
      acceptText: 'Eliminar',
    );
    if (!confirmed || !mounted) return;

    final db = await LiteConnection.getConnection();
    final whereColumn = identifier.isRowId ? 'rowid' : _quoteIdentifier(identifier.column);
    await db.rawDelete(
      'DELETE FROM ${_quoteIdentifier(widget.tableName)} WHERE $whereColumn = ?',
      [row[identifier.column]],
    );

    if (data.rows.length == 1 && _page > 0) {
      setState(() => _page--);
    }
    await _controller.refresh(silent: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => _controller.refresh(silent: false),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: QueryView(
        controller: _controller,
        showEmptyPlaceholder: false,
        builder: (context, data) {
          return RefreshIndicator(
            onRefresh: () => _controller.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Registros',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      _formatPageLabel(data),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (data.rows.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('La tabla no tiene registros'),
                    ),
                  )
                else
                  _RowsCard(
                    rows: data.rows,
                    canDelete: data.identifier != null,
                    onDelete: (row) => _deleteRecord(data, row),
                  ),
                const SizedBox(height: 8),
                _PaginationControls(
                  data: data,
                  onPrevious: _page == 0 ? null : _goToPreviousPage,
                  onNext: data.offset + data.rows.length >= data.totalRows
                      ? null
                      : () => _goToNextPage(data),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatPageLabel(_SqliteTableData data) {
    if (data.totalRows == 0) return '0 registros';
    final start = data.offset + 1;
    final end = data.offset + data.rows.length;
    return '$start - $end de ${data.totalRows}';
  }
}

class _PaginationControls extends StatelessWidget {
  final _SqliteTableData data;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationControls({
    required this.data,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = data.totalRows == 0 ? 0 : (data.offset ~/ data.limit) + 1;
    final totalPages = data.totalRows == 0
        ? 0
        : ((data.totalRows - 1) ~/ data.limit) + 1;

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Anterior'),
        ),
        Expanded(
          child: Text(
            'Pagina $currentPage de $totalPages',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Siguiente'),
        ),
      ],
    );
  }
}

class _RowsCard extends StatelessWidget {
  final List<Map<String, Object?>> rows;
  final bool canDelete;
  final void Function(Map<String, Object?> row) onDelete;

  const _RowsCard({
    required this.rows,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final keys = rows.first.keys.where((key) => key != _rowIdAlias).toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            if (canDelete) const DataColumn(label: Text('')),
            ...keys.map((key) => DataColumn(label: Text(key))),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                if (canDelete)
                  DataCell(
                    PopupMenuButton<_SqliteRecordAction>(
                      tooltip: 'Acciones',
                      onSelected: (action) {
                        if (action == _SqliteRecordAction.delete) {
                          onDelete(row);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _SqliteRecordAction.delete,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Eliminar registro'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ...keys.map((key) {
                  return DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        _formatValue(row[key]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return 'NULL';
    if (value is List<int>) return '<blob ${value.length} bytes>';
    return value.toString();
  }
}

String _quoteIdentifier(String value) {
  return '"${value.replaceAll('"', '""')}"';
}
