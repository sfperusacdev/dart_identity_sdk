import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/initialize.dart';
import 'package:dart_identity_sdk/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeIdentity("asistencia.app");
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hola como estas"),
            const SizedBox(height: 20.0),
            FilledButton(
                onPressed: () async {
                  final manager = SessionManagerSDK();
                  await manager.goOut(context);
                },
                child: const Text("Go Out")),
          ],
        ),
      ),
    );
  }
}
