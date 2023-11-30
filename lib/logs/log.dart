import 'package:flutter/foundation.dart';

class LOG {
  static void _print(String tag, Object object) {
    if (!kDebugMode) return;
    if (object is List<Object>) {
      if (kDebugMode) {
        print("$tag: ${object.join(" ")}\n");
      }
      return;
    }
    if (kDebugMode) print("$tag: $object\n");
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
