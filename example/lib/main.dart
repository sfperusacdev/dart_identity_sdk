import 'dart:convert';

import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeIdentityDependencies(appID: "usuario.app");
  runApp(const MyApp());
}

class AppRoutes extends IdentityRoutes {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: "/home",
        builder: (context, state) {
          return const HomePage();
        },
      )
    ];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ApplicationRouterManager(AppRoutes()).router(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final manager = SessionManagerSDK();

  String claims() {
    final token = manager.getToken() ?? "";
    const encoder = JsonEncoder.withIndent("  ");
    final parts = token.split(".");
    if (parts.length != 3) return "";
    final claimsData = parts[1];
    return encoder.convert(
      jsonDecode(utf8.decode(base64Url.decode(claimsData))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(claims()),
            ),
            const SizedBox(height: 20.0),
            FilledButton(
              onPressed: () async {
                await manager.goOut(context);
              },
              child: const Text("Go Out"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await manager.refreshToken();
                setState(() {});
              },
              child: const Text("Refresh Session"),
            ),
          ],
        ),
      ),
    );
  }
}
