import 'package:test/test.dart';
import 'package:teleport_router_generator/src/models/route_data.dart';
import 'package:teleport_router_generator/src/path_resolution.dart';

void main() {
  group('Indexed Stack Branch Validation', () {
    test('reports branch keys with no descendant routes', () {
      final shell = ShellRouteData(
        className: 'MainShell',
        routeClassName: 'MainShellRoute',
        navigatorKey: 'MainNavKey',
        isIndexedStack: true,
        branchKeys: ['HomeNavKey', 'SettingsNavKey'],
      );

      final homeRoute = RouteData(
        className: 'HomePage',
        routeClassName: 'HomeRoute',
        path: '/home',
        originalPath: '/home',
        parentNavigatorKey: 'HomeNavKey',
        isInitial: true,
        params: [],
      );

      expect(
        findMissingIndexedStackBranchKeys(shell, [shell, homeRoute]),
        ['SettingsNavKey'],
      );
    });

    test('treats shell navigator key as the first explicit branch', () {
      final shell = ShellRouteData(
        className: 'MainShell',
        routeClassName: 'MainShellRoute',
        navigatorKey: 'MainNavKey',
        isIndexedStack: true,
        branchKeys: ['HomeNavKey', 'SettingsNavKey'],
      );

      final homeRoute = RouteData(
        className: 'HomePage',
        routeClassName: 'HomeRoute',
        path: '/home',
        originalPath: '/home',
        parentNavigatorKey: 'MainNavKey',
        isInitial: true,
        params: [],
      );

      final settingsRoute = RouteData(
        className: 'SettingsPage',
        routeClassName: 'SettingsRoute',
        path: '/settings',
        originalPath: '/settings',
        parentNavigatorKey: 'SettingsNavKey',
        isInitial: false,
        params: [],
      );

      expect(
        findMissingIndexedStackBranchKeys(
          shell,
          [shell, homeRoute, settingsRoute],
        ),
        isEmpty,
      );
    });

    test('counts nested shell descendants toward a branch', () {
      final mainShell = ShellRouteData(
        className: 'MainShell',
        routeClassName: 'MainShellRoute',
        navigatorKey: 'MainNavKey',
        isIndexedStack: true,
        branchKeys: ['DashboardNavKey'],
      );

      final dashboardShell = ShellRouteData(
        className: 'DashboardShell',
        routeClassName: 'DashboardShellRoute',
        navigatorKey: 'DashboardInnerNavKey',
        parentNavigatorKey: 'DashboardNavKey',
        isIndexedStack: false,
      );

      final dashboardRoute = RouteData(
        className: 'DashboardPage',
        routeClassName: 'DashboardRoute',
        path: '/dashboard',
        originalPath: '/dashboard',
        parentNavigatorKey: 'DashboardInnerNavKey',
        isInitial: true,
        params: [],
      );

      expect(
        findMissingIndexedStackBranchKeys(
          mainShell,
          [mainShell, dashboardShell, dashboardRoute],
        ),
        isEmpty,
      );
    });
  });
}
