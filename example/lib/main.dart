import 'dart:convert';

import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/info/preferences_dialog.dart';
import 'package:dart_identity_sdk/utils/date_picker.dart';
import 'package:example/appbar.dart';
import 'package:example/configs/theme.dart';
import 'package:example/home2.dart';
import 'package:example/inputs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeIdentityDependencies(
    logPort: 30069,
    appID: "tareo.app",
    appName: "Tareo SF",
    minimumRequiredServices: [
      "com.sfperusac.tareoapp",
      "com.sfperusac.syncdata",
    ],
    minimumRequiredPermissions: ["login.tareoapp.application"],
  );
  runApp(const MyApp());
}

class AppRoutes extends IdentityRoutes {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: "/home",
        builder: (context, state) {
          return MainHome();
        },
      ),
      GoRoute(
        path: "/dialogs",
        builder: (context, state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: "/inputs",
        builder: (context, state) {
          return const InputsPage();
        },
      ),
      GoRoute(
        path: "/appbar",
        builder: (context, state) {
          return const AppbarPage();
        },
      ),
    ];
  }
}

final routes = ApplicationRouterManager(AppRoutes()).router();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: MaterialApp.router(routerConfig: routes, theme: appTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String claims() {
    final token = SessionManagerSDK.getToken() ?? "";
    const encoder = JsonEncoder.withIndent("  ");
    final parts = token.split(".");
    if (parts.length != 3) return "";

    String claimsData = parts[1];

    // Normalizar padding para que la longitud sea múltiplo de 4
    while (claimsData.length % 4 != 0) {
      claimsData += "=";
    }

    return encoder.convert(
      jsonDecode(utf8.decode(base64Url.decode(claimsData))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(getSelectedBranch() ?? "no-ne"),
            Padding(padding: const EdgeInsets.all(24.0), child: Text(claims())),
            const SizedBox(height: 20.0),
            FilledButton(
              onPressed: () async => await SessionManagerSDK.logout(context),
              child: const Text("Go Out"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                SoundService.cameraSound();
              },
              child: const Text("Sonido QR"),
            ),
            FilledButton(
              onPressed: () async {
                SoundService.errorSound();
              },
              child: const Text("Sonido Error"),
            ),
            FilledButton(
              onPressed: () async {
                await SessionManagerSDK.refreshToken();
                setState(() {});
              },
              child: const Text("Refresh Session"),
            ),
            FilledButton.icon(
              onPressed: () async {
                await showDomainPreferencesDialog(context);
              },
              icon: Icon(Icons.settings),
              label: Text("Preferences"),
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.push("/appbar");
              },
              icon: Icon(Icons.input),
              label: Text("Appbar"),
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.push("/inputs");
              },
              icon: Icon(Icons.input),
              label: Text("Inputs"),
            ),
            FilledButton.icon(
              onPressed: () async {
                await showAllowedDatesPicker(
                  context: context,
                  allowedDates: [
                    DateTime(2025, 1, 10),
                    DateTime(2025, 1, 15),
                    DateTime(2025, 1, 20),
                  ],
                  initialDate: DateTime(2025, 1, 12),
                  helpText: "Pick a valid date",
                  cancelText: "Close",
                  confirmText: "Select",
                );
              },
              icon: Icon(Icons.calendar_month),
              label: Text("DatePicker"),
            ),
          ],
        ),
      ),
    );
  }
}
