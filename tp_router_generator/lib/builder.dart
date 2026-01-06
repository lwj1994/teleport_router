import 'package:build/build.dart';
import 'src/tp_route_generator.dart';

/// Builder factory for tp_router_generator.
///
/// This creates a single tp_router.g.dart file with all routes.
Builder tpRouterBuilder(BuilderOptions options) => TpRouterBuilder();
