import 'package:dart_identity_sdk/src/managers/application_preferences.dart';
import 'package:flutter/material.dart';
import 'package:kdialogs/kdialogs.dart';

class _Content extends StatelessWidget {
  final Map<String, String> values;
  const _Content(this.values);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in values.entries) ...[
          Text(entry.key,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            "Value: ${entry.value}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          const Divider(height: 16),
        ],
      ],
    );
  }
}

Future<void> showDomainPreferencesDialog(BuildContext context) async {
  final domain = AppPreferences.private.domain;

  bool isWrapped(String key) => key.startsWith("$domain.");
  String unwrap(String key) => key.replaceFirst("$domain.", "");

  final keys = AppPreferences.global.getKeys().toList();
  keys.sort();
  final values = <String, String>{
    for (final key in keys)
      if (isWrapped(key))
        unwrap(key): AppPreferences.global.get(key)?.toString() ?? ""
  };

  await showKDialogContent(
    context,
    title: "Preferencias",
    builder: (context) => _Content(values),
  );
}
