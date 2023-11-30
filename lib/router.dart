import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/pages/login/login_page.dart';
import 'package:dart_identity_sdk/pages/settings/server_settings_page.dart';
import 'package:go_router/go_router.dart';

abstract class IdentityRoutes {
  List<RouteBase> routes();
}

class ApplicationRouterManager {
  final IdentityRoutes _routes;
  const ApplicationRouterManager(this._routes);

  GoRouter router() {
    final routes = _routes.routes();
    asserts(routes);
    routes.add(
      GoRoute(
        path: LoginPage.path,
        builder: (context, state) => const LoginPage(),
      ),
    );
    routes.add(
      GoRoute(
        path: ServerSettingsPage.path,
        builder: (context, state) => const ServerSettingsPage(),
      ),
    );
    return GoRouter(
      initialLocation: getInitialRoute(),
      routes: routes,
    );
  }

  String getInitialRoute() {
    final manager = SessionManagerSDK();
    if (manager.isLoginActive()) return "/home";
    return LoginPage.path;
  }

  void asserts(List<RouteBase> routes) {
    assert(() {
      for (var r in routes) {
        if (r is GoRoute && r.path == LoginPage.path) return false;
      }
      return true;
    }(), "the path ${LoginPage.path} are reserved");
    assert(() {
      for (var r in routes) {
        if (r is GoRoute && r.path == ServerSettingsPage.path) return false;
      }
      return true;
    }(), "the path ${ServerSettingsPage.path} are reserved");
    assert(() {
      var homefound = false;
      for (var r in routes) {
        if (r is GoRoute && r.path == "/home") homefound = true;
      }
      return homefound;
    }(), "the /home path is requiered");
  }
}
