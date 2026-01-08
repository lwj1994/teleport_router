import 'package:tp_router/tp_router.dart';

/// Navigator key for the main shell (bottom navigation).
class MainNavKey extends TpNavKey {
  const MainNavKey() : super('main');
}

/// Navigator key for the dashboard shell.
class DashboardNavKey extends TpNavKey {
  const DashboardNavKey() : super('dashboard');
}
