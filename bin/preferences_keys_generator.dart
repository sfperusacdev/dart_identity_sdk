import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<List<String>> _getDataArray(String baseUrl) async {
  final cleanBaseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final url = Uri.parse('$cleanBaseUrl/v/preferences/keys');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw HttpException('Error en la petición: ${response.statusCode}');
  }

  final jsonResponse = jsonDecode(response.body);
  return List<String>.from(jsonResponse['data']);
}

String _toConstantCase(String input) {
  final numberMap = {
    '0': 'ZERO',
    '1': 'ONE',
    '2': 'TWO',
    '3': 'THREE',
    '4': 'FOUR',
    '5': 'FIVE',
    '6': 'SIX',
    '7': 'SEVEN',
    '8': 'EIGHT',
    '9': 'NINE',
  };

  final words = input
      .trim()
      .toUpperCase()
      .split(RegExp(r'[^A-Z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  var first = words.first;
  if (first.isNotEmpty && numberMap.containsKey(first[0])) {
    first = '${numberMap[first[0]]}${first.substring(1)}';
    words[0] = first;
  }

  return words.join('_');
}

Future<String> _readPreferencesUrl(String path) async {
  final lines = await File(path).readAsLines();

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;

    final parts = trimmed.split('=');
    if (parts.first.trim() == 'PREFERENCES_SERVER_URL') {
      return parts.last.trim();
    }
  }

  throw FormatException('PREFERENCES_SERVER_URL no encontrada en $path');
}

Future<String> generatePreferencesKeysClass(String envPath) async {
  final preferencesUrl = await _readPreferencesUrl(envPath);
  final values = await _getDataArray(preferencesUrl);

  final buffer = StringBuffer();
  buffer.writeln(
      '// ignore_for_file: constant_identifier_names\n\nclass PreferencesKeys {');

  for (final key in values) {
    final fieldName = _toConstantCase(key);
    buffer.writeln("  static const String $fieldName = '$key';");
  }

  buffer.writeln('}');
  return buffer.toString();
}

Future<void> main(List<String> args) async {
  final envPath = args.isNotEmpty ? args[0] : '.env';
  final outputPath =
      args.length > 1 ? args[1] : 'lib/constants/preferences_keys.dart';

  final content = await generatePreferencesKeysClass(envPath);

  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(content);

  print('Archivo generado: $outputPath');
}
