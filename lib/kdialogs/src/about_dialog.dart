import 'package:dart_identity_sdk/src/device_info.dart';
import 'package:dart_identity_sdk/src/env/env.dart';
import 'package:flutter/material.dart';

void showCustomAboutDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Acerca de'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        EnvConfig.appName ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Versión: ${ApplicationInfo.appVersion}'),
                    ],
                  ),
                ),
                const Image(
                  image: AssetImage('assets/app/logo.png'),
                  width: 52,
                  height: 52,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Desarrollado por:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('SOLUCIONES INFORMATICAS SF PERU'),
            const Text('https://sfperusac.com'),
            const SizedBox(height: 16),
            const Text(
              'Correos de contacto:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('developer2@sfperusac.com'),
            const Text('ventas@sfperusac.com'),
            const Text('soporte@sfperusac.com'),
            const SizedBox(height: 16),
            const Text('© 2025 SF PERU S.A.C. Todos los derechos reservados'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
