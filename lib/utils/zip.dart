import 'dart:io';
import 'package:archive/archive.dart';

Future<File> zipFiles(
  List<String> paths, {
  String name = 'archive.zip',
}) async {
  if (paths.isEmpty) {
    throw Exception('No hay archivos para zippear');
  }

  final tmpDir = Directory.systemTemp;
  final zipPath = '${tmpDir.path}/$name';

  final zipFile = File(zipPath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final archive = Archive();

  for (final p in paths) {
    final file = File(p);
    if (!file.existsSync()) continue;

    final bytes = file.readAsBytesSync();
    final entryName = p.split(Platform.pathSeparator).last;
    archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
  }

  final zipBytes = ZipEncoder().encode(archive);
  return zipFile..writeAsBytesSync(zipBytes);
}
