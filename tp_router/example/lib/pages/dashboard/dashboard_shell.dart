import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';
import 'package:example/routes/nav_keys.dart';

@TpShellRoute(
  // This key identifies THIS shell. Child routes (like AnalyticsPage) use this
  // key (DashboardNavKey) as their parentNavigatorKey to attach themselves here.
  navigatorKey: DashboardNavKey,

  // This key tells TpRouter where to place THIS shell.
  // It says "I am a child of the Main Shell, located in branch 2".
  parentNavigatorKey: MainNavKey,
  branchIndex: 2,
  observers: [DashboardObserver],
)
class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: child,
    );
  }
}

class DashboardObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('DashboardObserver: didPush ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint('DashboardObserver: didReplace ${newRoute?.settings.name}');
  }
}
