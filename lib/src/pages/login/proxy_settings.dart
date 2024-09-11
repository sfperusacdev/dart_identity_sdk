import 'package:dart_identity_sdk/src/bases/storage/system_storage_manager.dart';
import 'package:dart_identity_sdk/src/security/settings/server_sertting_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class ProxySettingsPage extends StatefulWidget {
  static const path = "/proxy_settings_page";

  const ProxySettingsPage({super.key});

  @override
  State<ProxySettingsPage> createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  final TextEditingController ipController = TextEditingController();

  final TextEditingController portController = TextEditingController();

  var connectivityStatus = "Sin probar";
  final settings = SystemStorageManager().instance<ServerSettingsSorage>();

  @override
  void initState() {
    var values = settings.getValue() ?? ServerSettings.defaultValues();
    if (values.proxyURL != null) {
      var value = values.proxyURL ?? "";
      var parts = value.split(":");

      if (parts.length > 1) ipController.text = parts[1].split("/").last;
      if (parts.length > 2) portController.text = parts.last;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Proxy")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: "Dirección IP del Proxy",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: "Puerto del Proxy",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => testConnection(context),
              child: const Text("Probar Conectividad"),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                String ip = ipController.text.trim();
                String port = portController.text.trim();
                var values = settings.getValue() ?? ServerSettings.defaultValues();
                if (ip.isNotEmpty && port.isNotEmpty) {
                  var newObj = values.copyWith(proxyURL: "http://$ip:$port");
                  settings.setValue(newObj);
                } else {
                  var newObj = values.copyWith(proxyURL: null);
                  settings.setValue(newObj);
                }
                context.pop();
              },
              child: const Text("Guardar Configuración"),
            ),
            const SizedBox(height: 16),
            Text("Estado de la conectividad: $connectivityStatus"),
          ],
        ),
      ),
    );
  }

  Future<void> testConnection(BuildContext context) async {
    final notifier = ScaffoldMessenger.of(context);
    String ip = ipController.text.trim();
    String port = portController.text.trim();
    if (ip.isNotEmpty && port.isNotEmpty) {
      try {
        var response = await http.get(Uri.parse('http://$ip:$port/status'));
        if (response.statusCode == 200) {
          notifier.showSnackBar(
            const SnackBar(content: Text("Conectividad exitosa!")),
          );
        } else {
          notifier.showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode}")),
          );
        }
      } catch (e) {
        notifier.showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    } else {
      notifier.showSnackBar(
        const SnackBar(content: Text("Por favor, completa la IP y el puerto")),
      );
    }
  }
}
