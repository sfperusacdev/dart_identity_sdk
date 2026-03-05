import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:args/args.dart';

Future<List<String>> _getDataArray(String baseUrl, {String? serviceId}) async {
  try {
    final cleanBaseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

    final uri = serviceId == null || serviceId.isEmpty
        ? Uri.parse('$cleanBaseUrl/v/preferences/keys')
        : Uri.parse('$cleanBaseUrl/v/preferences/keys')
            .replace(queryParameters: {'servicio_id': serviceId});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status code ${response.statusCode}',
      );
    }

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['data'] == null) {
      print('[WARN] Response JSON does not contain "data" field');
      return [];
    }

    final list = List<String>.from(jsonResponse['data']);

    return list;
  } catch (e) {
    print('[ERROR] Failed to fetch preferences keys');
    print('[ERROR] $e');
    rethrow;
  }
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
  if (numberMap.containsKey(first[0])) {
    first = '${numberMap[first[0]]}${first.substring(1)}';
    words[0] = first;
  }

  return words.join('_');
}

Future<String> _readPreferencesUrl(String path) async {
  try {
    final file = File(path);

    if (!await file.exists()) {
      throw FileSystemException('.env file not found', path);
    }

    final lines = await file.readAsLines();

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;

      final parts = trimmed.split('=');

      if (parts.first.trim() == 'PREFERENCES_SERVER_URL') {
        final value = parts.last.trim();
        print('[INFO] Preferences server URL found: $value');
        return value;
      }
    }

    throw const FormatException(
      'PREFERENCES_SERVER_URL not found in environment file',
    );
  } catch (e) {
    print('[ERROR] Failed to read preferences server URL from $path');
    print('[ERROR] $e');
    rethrow;
  }
}

Future<String> generatePreferencesKeysClass(String envPath,
    {String? serviceId}) async {
  try {
    final preferencesUrl = await _readPreferencesUrl(envPath);

    if (serviceId != null && serviceId.isNotEmpty) {
      print('[INFO] Using service id: $serviceId');
    }

    final values = await _getDataArray(preferencesUrl, serviceId: serviceId);

    final buffer = StringBuffer();
    buffer.writeln(
        '// ignore_for_file: constant_identifier_names\n\nclass PreferencesKeys {');

    for (final key in values) {
      final fieldName = _toConstantCase(key);
      buffer.writeln("  static const String $fieldName = '${key.trim()}';");
    }

    buffer.writeln('}');
    
    print('[INFO] Task completed successfully');
    return buffer.toString();
  } catch (e) {
    print('[ERROR] Failed to generate PreferencesKeys class');
    print('[ERROR] $e');
    rethrow;
  }
}

Future<void> main(List<String> args) async {
  try {
    final parser = ArgParser()
      ..addOption('env', abbr: 'e', defaultsTo: '.env')
      ..addOption(
        'output',
        abbr: 'o',
        defaultsTo: 'lib/constants/preferences_keys.dart',
      )
      ..addOption('service-id', abbr: 's', defaultsTo: '');

    final results = parser.parse(args);

    final envPath = results['env'];
    final outputPath = results['output'];
    final serviceId = results['service-id'];

    final content = await generatePreferencesKeysClass(
      envPath,
      serviceId: serviceId,
    );

    final outputFile = File(outputPath);

    await outputFile.parent.create(recursive: true);

    await outputFile.writeAsString(content);
  } catch (e) {
    print('[FATAL] Program terminated due to an unexpected error');
    print('[FATAL] $e');
    exit(1);
  }
}
