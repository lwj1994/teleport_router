import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

@TpShellRoute(
  navigatorKey: 'dashboard',
  parentNavigatorKey: 'main',
  branchIndex: 2,
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
