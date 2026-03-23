import 'package:test/test.dart';
import 'package:teleport_router_generator/src/models/route_data.dart';
import 'package:teleport_router_generator/src/writers/route_writer.dart';

void main() {
  group('Shell generation', () {
    late RouteWriter writer;

    setUp(() {
      writer = RouteWriter();
    });

    test('indexed stack first branch routes omit shell navigator parent key',
        () {
      final shell = ShellRouteData(
        className: 'MainShellPage',
        routeClassName: 'MainShellRoute',
        navigatorKey: 'MainNavKey',
        isIndexedStack: true,
        branchKeys: ['HomeNavKey'],
      );

      final route = RouteData(
        className: 'HomePage',
        routeClassName: 'HomeRoute',
        path: '/home',
        originalPath: '/home',
        parentNavigatorKey: 'MainNavKey',
        isInitial: true,
        params: [],
      );

      final output = writer.generateFile([shell, route], {});

      expect(output, contains('branchNavigatorKeys: [HomeNavKey(), ],'));
      expect(output,
          isNot(contains('parentNavigatorKey: const MainNavKey().globalKey')));
    });

    test('stateful shell emits parent navigator key and page type', () {
      final shell = ShellRouteData(
        className: 'NestedShellPage',
        routeClassName: 'NestedShellRoute',
        navigatorKey: 'NestedNavKey',
        parentNavigatorKey: 'RootNavKey',
        isIndexedStack: true,
        pageType: 'TeleportPageType.swipeBack',
      );

      final output = writer.generateFile([shell], {});

      expect(output, contains('parentNavigatorKey: RootNavKey(),'));
      expect(output, contains('type: TeleportPageType.swipeBack,'));
    });

    test('stateless shell emits parent navigator key', () {
      final shell = ShellRouteData(
        className: 'NestedShellPage',
        routeClassName: 'NestedShellRoute',
        navigatorKey: 'NestedNavKey',
        parentNavigatorKey: 'RootNavKey',
        isIndexedStack: false,
      );

      final output = writer.generateFile([shell], {});

      expect(output, contains('parentNavigatorKey: RootNavKey(),'));
    });
  });
}
