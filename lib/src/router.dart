import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/pages/login/login_page.dart';
import 'package:dart_identity_sdk/src/pages/login/proxy_settings.dart';
import 'package:dart_identity_sdk/src/pages/settings/server_settings_page.dart';
import 'package:go_router/go_router.dart';

abstract class IdentityRoutes {
  List<RouteBase> routes();
}

GoRouter? _router;
List<RouteBase>? _last;

class ApplicationRouterManager {
  final IdentityRoutes _routes;
  final bool Function(DateTime? sessionDate)? sessionValidationCriteria;
  const ApplicationRouterManager(this._routes, {this.sessionValidationCriteria});

  GoRouter router() {
    final routes = _routes.routes();
    if (routes == _last && _router != null) return _router!;
    _asserts(routes);
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
    routes.add(
      GoRoute(
        path: ProxySettingsPage.path,
        builder: (context, state) => ProxySettingsPage(),
      ),
    );
    _router = GoRouter(
      initialLocation: _getInitialRoute(),
      routes: routes,
    );
    return _router!;
  }

  String _getInitialRoute() {
    final manager = SessionManagerSDK();
    if (manager.hasValidSession(criteria: sessionValidationCriteria)) return "/home";
    return LoginPage.path;
  }

  void _asserts(List<RouteBase> routes) {
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
      for (var r in routes) {
        if (r is GoRoute && r.path == ProxySettingsPage.path) return false;
      }
      return true;
    }(), "the path ${ProxySettingsPage.path} are reserved");
    assert(() {
      var homefound = false;
      for (var r in routes) {
        if (r is GoRoute && r.path == "/home") homefound = true;
      }
      return homefound;
    }(), "the /home path is requiered");
  }
}
