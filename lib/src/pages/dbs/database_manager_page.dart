import 'dart:io';
import 'package:dart_identity_sdk/kdialogs/src/show_async_progress.dart';
import 'package:dart_identity_sdk/sqlite/connection.dart';
import 'package:dart_identity_sdk/utils/zip.dart';
import 'package:dart_identity_sdk/widgets/query/query_controller.dart';
import 'package:dart_identity_sdk/widgets/query/query_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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

enum _DbAction { export, delete }

enum _GlobalAction { clearAll }

class _DatabaseManagerPageState extends State<DatabaseManagerPage> {
  late final QueryController<List<_DbEntry>, void> queryController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Databases"),
        actions: [
          PopupMenuButton<_GlobalAction>(
            onSelected: (a) {
              if (a == _GlobalAction.clearAll) {
                deleteAllDatabases(context);
              }
            },
            itemBuilder: (_) => const [
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
