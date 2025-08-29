import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

String _dosDigitos(int numero) {
  return numero.toString().padLeft(2, '0');
}

String obtenerFechaActual() {
  final DateTime ahora = DateTime.now();
  String fechaFormateada =
      '${ahora.year}/${_dosDigitos(ahora.month)}/${_dosDigitos(ahora.day)} '
      '${_dosDigitos(ahora.hour)}:${_dosDigitos(ahora.minute)}:${_dosDigitos(ahora.second)}';
  return fechaFormateada;
}

class LOG {
  static int _logPort = 0;
  static late sqflite.Database _connecion;
  static bool _isopenDB = false;
  
  static get logPort => _logPort;
  
  static Future<void> init({int logPort = 30069}) async {
    _logPort = logPort;
    if (_isopenDB) return;
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        _connecion = await databaseFactoryFfi.openDatabase(":memory:");
        await _connecion.execute("create table logs(value text)");
      } else {
        _connecion = await sqflite.openDatabase(
          ":memory:",
          version: 1,
          onCreate: (db, _) async {
            await db.execute("create table logs(value text)");
          },
        );
      }
      _isopenDB = true;
      final server = await shelf_io.serve(_handle, "0.0.0.0", logPort);
      debugPrint('Serving at http://${server.address.host}:${server.port}');
      return;
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  static Future<Response> _handle(Request request) async {
    var response = "";
    final lines = await _listLogLines();
    for (var line in lines) {
      response += "$line\n";
    }
    return Response.ok(response,
        headers: {"Content-Type": "text/plain; charset=UTF-8"});
  }

  static Future<List<String>> _listLogLines() async {
    if (!_isopenDB) return [];
    const qry = "select value from logs";
    final result = await _connecion.rawQuery(qry);
    return result.map((e) => e["value"] as String).toList();
  }

  static void _print(String tag, Object object) {
    var line = "";
    if (object is List<Object>) {
      line = "${obtenerFechaActual()} $tag ${object.join(" ")}";
      if (kDebugMode) {
        print("${obtenerFechaActual()} $tag ${object.join(" ")}\n");
      }
    } else {
      line = "${obtenerFechaActual()} ${tag.toUpperCase()} $object";
      if (kDebugMode) print("$tag: $object\n");
    }
    if (_isopenDB) {
      try {
        const qry = "insert into logs(value) values (?)";
        _connecion.rawInsert(qry, [line]);
      } catch (err) {
        final qry = "insert into logs(value) values ('${err.toString()}')";
        _connecion.execute(qry);
      }
    }
  }

  static void printInfo(Object object) {
    _print("INFO", object);
  }

  static void printWarn(Object object) {
    _print("WARN", object);
  }

  static void printError(Object object) {
    _print("ERRO", object);
  }
}
