import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/src/pages/login/login_page.dart';
import 'package:go_router/go_router.dart';

abstract class IdentityRoutes {
  List<RouteBase> routes();
}

GoRouter? _router;
List<RouteBase>? _last;

class ApplicationRouterManager {
  final IdentityRoutes _routes;
  const ApplicationRouterManager(this._routes);

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
    _router = GoRouter(
      initialLocation: _getInitialRoute(),
      routes: routes,
    );
    return _router!;
  }

  String _getInitialRoute() {
    final hasValidSession = SessionManagerSDK.hasValidSession();
    if (hasValidSession) {
      final empresa = SessionManagerSDK.getCompanyCode();
      AppPreferences.setUpDomain(empresa);
      return "/home";
    }
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
      var homefound = false;
      for (var r in routes) {
        if (r is GoRoute && r.path == "/home") homefound = true;
      }
      return homefound;
    }(), "the /home path is requiered");
  }
}
