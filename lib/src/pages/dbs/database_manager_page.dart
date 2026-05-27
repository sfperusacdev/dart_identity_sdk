import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_async_progress.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_kdialog_content.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:dart_identity_sdk/utils/zip.dart';
import 'package:dart_identity_sdk/widgets/query/query_controller.dart';
import 'package:dart_identity_sdk/widgets/query/query_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

class DatabaseManagerPage extends StatefulWidget {
  static const path = "/_/database/list";
  const DatabaseManagerPage({super.key});

  @override
  State<DatabaseManagerPage> createState() => _DatabaseManagerPageState();
}

class _DbEntry {
  final String name;
  final String path;
  _DbEntry(this.name, this.path);
}

enum _DbAction { export, exportSchema, delete }

enum _GlobalAction { importDb, clearAll }

class _DatabaseManagerPageState extends State<DatabaseManagerPage> {
  late final QueryController<List<_DbEntry>, void> queryController;

  String _normalizeDbFileNameFromDomain(String rawDomain) {
    final v = rawDomain.trim();
    if (v.isEmpty) throw Exception('Dominio inválido');
    final lower = v.toLowerCase();

    if (lower.endsWith('_db.db')) return v;
    if (lower.endsWith('_db')) return '$v.db';
    return '${v}_db.db';
  }

  String _inferDomainFromDbFileName(String dbFileName) {
    var name = dbFileName;
    if (name.endsWith('.db')) name = name.substring(0, name.length - 3);
    if (name.endsWith('_db')) name = name.substring(0, name.length - 3);
    return name;
  }

  String _safeBasename(String name) {
    // Avoid zip-slip and keep names consistent with how listFilePaths() works.
    final base = name.split('/').last.split('\\').last;
    if (base.contains('..')) throw Exception('ZIP inválido: nombre de archivo');
    return base;
  }

  @override
  void initState() {
    super.initState();
    queryController = QueryController(fetchCallback: (_) => listFilePaths());
  }

  Future<List<_DbEntry>> listFilePaths() async {
    final root = await LiteConnection.getDatabaseRootPath();
    final result = <_DbEntry>[];
    for (final e in Directory(root).listSync()) {
      if (e is File && e.path.endsWith("_db.db")) {
        result.add(_DbEntry(
          e.uri.pathSegments.last,
          e.path,
        ));
      }
    }
    return result;
  }

  Future<List<String>> getDbPaths(String dbName) async {
    final root = await LiteConnection.getDatabaseRootPath();
    final rgx = RegExp('^${RegExp.escape(dbName)}(?:-(journal|wal|shm))?\$');
    final result = <String>[];
    for (final e in Directory(root).listSync()) {
      if (e is File) {
        final name = e.uri.pathSegments.last;
        if (rgx.hasMatch(name)) result.add(e.path);
      }
    }
    return result;
  }

  Future<void> exportDatabase(BuildContext context, _DbEntry entry) async {
    final fecha =
        DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');

    final zipFile = await showAsyncProgressKDialog(
      context,
      doProcess: () async {
        final paths = await getDbPaths(entry.name);
        return zipFiles(
          paths,
          name: "${entry.name}_$fecha.zip",
        );
      },
    );
    if (zipFile == null) return;

    await SharePlus.instance.share(
      ShareParams(files: [XFile(zipFile.path)]),
    );
  }

  Future<void> exportSchema(BuildContext context, _DbEntry entry) async {
    final fecha =
        DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');

    final sqlFile = await showAsyncProgressKDialog(
      context,
      doProcess: () async {
        // Open directly from file path so we can export schema for any DB in the list,
        // not only the currently-connected domain.
        final db = await sqlite.openDatabase(
          entry.path,
          readOnly: true,
          singleInstance: false,
        );
        try {
          final rows = await db.rawQuery(
            "SELECT type, name, tbl_name, sql "
            "FROM sqlite_master "
            "WHERE sql IS NOT NULL AND type IN ('table','index','trigger','view') "
            "ORDER BY type, name",
          );

          final buf = StringBuffer();
          buf.writeln('-- Schema export for: ${entry.name}');
          buf.writeln('-- Generated at: ${DateTime.now().toIso8601String()}');
          buf.writeln('PRAGMA foreign_keys=OFF;');
          buf.writeln('BEGIN TRANSACTION;');

          for (final r in rows) {
            final sql = (r['sql'] as String?)?.trim();
            if (sql == null || sql.isEmpty) continue;
            buf.writeln(sql.endsWith(';') ? sql : '$sql;');
            buf.writeln();
          }

          buf.writeln('COMMIT;');

          final tmpDir = Directory.systemTemp;
          final path = '${tmpDir.path}/${entry.name}_schema_$fecha.sql';
          final f = File(path);
          if (await f.exists()) await f.delete();
          await f.writeAsString(buf.toString());
          return f;
        } finally {
          await db.close();
        }
      },
    );
    if (sqlFile == null) return;

    await SharePlus.instance.share(
      ShareParams(files: [XFile(sqlFile.path)]),
    );
  }

  Future<void> deleteDatabase(BuildContext context, _DbEntry entry) async {
    await showAsyncProgressKDialog(
      context,
      confirmationRequired: true,
      doProcess: () async {
        final paths = await getDbPaths(entry.name);
        for (final p in paths) {
          final f = File(p);
          if (f.existsSync()) f.deleteSync();
        }
        await queryController.refresh();
      },
    );
  }

  Future<void> deleteAllDatabases(BuildContext context) async {
    await showAsyncProgressKDialog(
      context,
      confirmationRequired: true,
      doProcess: () async {
        final root = await LiteConnection.getDatabaseRootPath();
        for (final e in Directory(root).listSync()) {
          if (e is File) e.deleteSync();
        }
        await queryController.refresh();
      },
    );
  }

  Future<String?> _askDomain(BuildContext context, {required String initial}) {
    final controller = TextEditingController(text: initial);
    return showKDialogContent<bool>(
      context,
      title: 'Importar base de datos',
      saveBtnText: 'Continuar',
      onSave: () async {
        final v = controller.text.trim();
        if (v.isEmpty) return false;
        return true;
      },
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dominio'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'empresa',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se importará como: <dominio>_db.db',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        );
      },
    ).then((ok) {
      if (ok == true) return controller.text.trim();
      return null;
    });
  }

  Future<void> importDatabaseZip(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return;

    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('No se pudo leer el archivo seleccionado');
    }

    // Pre-validate zip and infer a suggested domain before asking for confirmation.
    final archive = ZipDecoder().decodeBytes(bytes);
    final names = <String>[];
    for (final f in archive.files) {
      if (f.isFile) names.add(_safeBasename(f.name));
    }

    final dbNames = names.where((n) => n.endsWith('_db.db')).toList();
    if (dbNames.isEmpty) {
      throw Exception('ZIP inválido: no contiene un *_db.db');
    }
    if (dbNames.length > 1) {
      throw Exception('ZIP inválido: contiene múltiples bases de datos');
    }

    final zipDbName = dbNames.single;
    final allowed = <String>{
      zipDbName,
      '$zipDbName-wal',
      '$zipDbName-shm',
      '$zipDbName-journal',
    };
    final extra = names.where((n) => !allowed.contains(n)).toList();
    if (extra.isNotEmpty) {
      throw Exception(
        'ZIP inválido: contiene archivos inesperados: ${extra.join(', ')}',
      );
    }

    final suggestedDomain = _inferDomainFromDbFileName(zipDbName);
    if (!context.mounted) return;
    final domain = await _askDomain(context, initial: suggestedDomain);
    if (domain == null) return;
    final targetDbName = _normalizeDbFileNameFromDomain(domain);

    if (!context.mounted) return;
    await showAsyncProgressKDialog(
      context,
      confirmationRequired: true,
      confirmationTitle: 'Reemplazar base de datos',
      confirmationMessage:
          'Se reemplazará la base de datos "$targetDbName" (incluyendo -wal/-shm si existen).\n\n¿Continuar?',
      doProcess: () async {
        await LiteConnection.closeIfConnected();

        final root = await LiteConnection.getDatabaseRootPath();
        final existingPaths = await getDbPaths(targetDbName);
        for (final p in existingPaths) {
          final f = File(p);
          if (f.existsSync()) f.deleteSync();
        }

        final map = <String, List<int>>{};
        for (final f in archive.files) {
          if (!f.isFile) continue;
          final name = _safeBasename(f.name);
          if (!allowed.contains(name)) continue;
          map[name] = f.content as List<int>;
        }
        if (!map.containsKey(zipDbName)) {
          throw Exception('ZIP inválido: falta el archivo principal .db');
        }

        Future<void> writeAs(String srcName, String destName) async {
          final content = map[srcName];
          if (content == null) return;
          final out = File('$root/$destName');
          await out.writeAsBytes(content, flush: true);
        }

        await writeAs(zipDbName, targetDbName);
        await writeAs('$zipDbName-wal', '$targetDbName-wal');
        await writeAs('$zipDbName-shm', '$targetDbName-shm');
        await writeAs('$zipDbName-journal', '$targetDbName-journal');

        await queryController.refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Databases"),
        actions: [
          PopupMenuButton<_GlobalAction>(
            onSelected: (a) {
              if (a == _GlobalAction.importDb) {
                // Wrap in an async progress dialog so errors show consistently.
                showAsyncProgressKDialog(
                  context,
                  doProcess: () async => importDatabaseZip(context),
                );
                return;
              }
              if (a == _GlobalAction.clearAll) deleteAllDatabases(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _GlobalAction.importDb,
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('Importar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _GlobalAction.clearAll,
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text("Limpiar todo"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: QueryView(
        controller: queryController,
        builder: (context, filePaths) {
          return RefreshIndicator(
            onRefresh: queryController.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filePaths.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final entry = filePaths[i];
                return ListTile(
                  title: Text(entry.name),
                  subtitle: Text(entry.path),
                  trailing: PopupMenuButton<_DbAction>(
                    onSelected: (a) {
                      if (a == _DbAction.export) {
                        exportDatabase(context, entry);
                      } else if (a == _DbAction.exportSchema) {
                        exportSchema(context, entry);
                      } else {
                        deleteDatabase(context, entry);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _DbAction.export,
                        child: Row(
                          children: [
                            Icon(Icons.upload_file, size: 20),
                            SizedBox(width: 12),
                            Text("Exportar"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _DbAction.exportSchema,
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined, size: 20),
                            SizedBox(width: 12),
                            Text("Exportar schema (.sql)"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _DbAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text("Eliminar"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
