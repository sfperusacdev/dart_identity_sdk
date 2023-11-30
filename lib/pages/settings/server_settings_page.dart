import 'package:dart_identity_sdk/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/pages/settings/widgets/setting_input.dart';
import 'package:dart_identity_sdk/security/settings/server_sertting_storage.dart';
import 'package:flutter/material.dart';

class ServerSettingsPage extends StatefulWidget {
  static const path = "/server_settings";
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  ServerSettings settings = ServerSettings.defaultValues();

  @override
  Widget build(BuildContext context) {
    settings = SystemStorageManager().instance<ServerSettingsSorage>().getValue() ?? settings;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              SystemStorageManager().instance<ServerSettingsSorage>().setValue(settings);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("Servidor de dominios"),
                subtitle: SettingIntput(
                  initialValue: settings.identityServiceAddress ?? '',
                  onChange: (value) => settings.identityServiceAddress = value,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
