import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_router/tp_router.dart';

void main() {
  group('TpRouteSettings', () {
    test('parses basic parameters correctly', () {
      final settings = TpRouteSettings(
        pathParams: {'id': '123'},
        queryParams: {'name': 'test', 'active': 'true'},
        extra: {'obj': 'value'},
      );

      expect(settings.getString('id'), '123');
      expect(settings.getInt('id'), 123);
      expect(settings.getString('name'), 'test');
      expect(settings.getBool('active'), true);
      expect(settings.getExtra<String>('obj'), 'value');
    });

    test('validates required parameters', () {
      final settings = TpRouteSettings(pathParams: {}, queryParams: {});
      expect(() => settings.getStringRequired('id'), throwsArgumentError);
    });
  });

  group('TpRouter', () {
    // Define reusable routes for testing
    final homeRoute = TpRouteInfo(
      path: '/home',
      isInitial: true,
      builder: (s) => const Text('Home Page'),
    );

    final userRoute = TpRouteInfo(
      path: '/user/:id',
      name: 'user', // Named route
      builder: (s) => Text('User ${s.getInt('id')}'),
    );

    testWidgets('initializes and navigates with pushPath', (tester) async {
      final router = TpRouter(routes: [homeRoute, userRoute]);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      expect(find.text('Home Page'), findsOneWidget);

      await router.pushPath('/user/42');
      await tester.pumpAndSettle();

      expect(find.text('User 42'), findsOneWidget);
    });

    testWidgets('supports redirect', (tester) async {
      final router = TpRouter(
        routes: [homeRoute, userRoute],
        redirect: (context, state) {
          if (state.uri.path == '/home') {
            return '/user/99';
          }
          return null;
        },
      );

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      // Should be redirected from /home to /user/99
      expect(find.text('User 99'), findsOneWidget);
    });

    testWidgets('supports observers', (tester) async {
      final log = <String>[];
      final observer = TestNavigatorObserver(log);

      final router = TpRouter(
        routes: [homeRoute, userRoute],
        observers: [observer],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      // Initial route /home
      expect(log, contains(matches(r'didPush .*home')));

      await router.pushPath('/user/100');
      await tester.pumpAndSettle();

      // Pushed /user/100 (matches /user/:id)
      expect(log, contains(matches(r'didPush .*user')));
    });

    testWidgets('BaseRoute.tp navigates correctly (push, go, replacement)',
        (tester) async {
      final router = TpRouter(routes: [homeRoute, userRoute]);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      expect(find.text('Home Page'), findsOneWidget);

      // 1. Test push (default) via BaseRoute.tp
      // MockRoute('/user/1') corresponds to userRoute with id=1
      const MockRoute('/user/1').tp(tester.element(find.text('Home Page')));
      await tester.pumpAndSettle();
      expect(find.text('User 1'), findsOneWidget);

      // Verify stack: Home -> User 1.
      // We can verify this by popping.
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Home Page'), findsOneWidget);

      // 2. Test replace usage
      // Re-navigate to User 1
      await router.pushPath('/user/1');
      await tester.pumpAndSettle();
      expect(find.text('User 1'), findsOneWidget);

      // Now replace with User 2
      const MockRoute('/user/2')
          .tp(tester.element(find.text('User 1')), replacement: true);
      await tester.pumpAndSettle();
      expect(find.text('User 2'), findsOneWidget);

      // Pop should go back to Home (User 1 was replaced)
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Home Page'), findsOneWidget);

      // 3. Test go (clearHistory)
      // Push User 1 again
      await router.pushPath('/user/1');
      await tester.pumpAndSettle();

      // Go to User 3 (clears history)
      const MockRoute('/user/3')
          .tp(tester.element(find.text('User 1')), clearHistory: true);
      await tester.pumpAndSettle();
      expect(find.text('User 3'), findsOneWidget);
    });

    testWidgets('push returns value from pop', (tester) async {
      final returnRoute = TpRouteInfo(
        path: '/return',
        builder: (s) => const Text('Return Page'),
      );

      final router = TpRouter(routes: [homeRoute, returnRoute]);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      final future = router.pushPath<String>('/return');
      await tester.pumpAndSettle();
      expect(find.text('Return Page'), findsOneWidget);

      router.pop('Success!');
      await tester.pumpAndSettle();

      expect(await future, 'Success!');
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('StatefulShellRoute preserves state in IndexedStack',
        (tester) async {
      final tab1 = TpRouteInfo(
        path: '/tab1',
        isInitial: true,
        builder: (s) => const CounterWidget(),
      );
      final tab2 = TpRouteInfo(
        path: '/tab2',
        builder: (s) => const Text('Tab 2 Content'),
      );

      final shellRoute = TpStatefulShellRouteInfo(
        builder: (c, shell) => Column(
          children: [
            Expanded(child: shell),
            Row(
              children: [
                GestureDetector(
                    onTap: () => shell.goBranch(0), child: const Text('Btn1')),
                GestureDetector(
                    onTap: () => shell.goBranch(1), child: const Text('Btn2')),
              ],
            )
          ],
        ),
        branches: [
          [tab1],
          [tab2],
        ],
      );

      final router = TpRouter(routes: [shellRoute]);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.routerConfig,
      ));

      // 1. Initial State: Tab 1, Count 0
      expect(find.text('Count: 0'), findsOneWidget);

      // 2. Increment Count
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);

      // 3. Switch to Tab 2
      await tester.tap(find.text('Btn2'));
      await tester.pumpAndSettle();
      expect(find.text('Tab 2 Content'), findsOneWidget);
      // Tab 1 should be hidden (IndexedStack) but alive.

      // 4. Switch back to Tab 1
      await tester.tap(find.text('Btn1'));
      await tester.pumpAndSettle();

      // State Key Verification: Count should still be 1
      expect(find.text('Count: 1'), findsOneWidget);
    });
  });
}

// Helper Classes

class TestNavigatorObserver extends NavigatorObserver {
  final List<String> log;
  TestNavigatorObserver(this.log);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      log.add('didPush ${route.settings.name}');
    } else {
      // Fallback for unnamed routes (often matched path logic in GoRouter)
      log.add('didPush ${route.settings.toString()}');
    }
  }
}

class MockRoute extends BaseRoute {
  @override
  final String fullPath;
  @override
  final Map<String, dynamic> extra;

  const MockRoute(this.fullPath, {this.extra = const {}});
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
