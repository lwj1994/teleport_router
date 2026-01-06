import 'package:flutter/widgets.dart';
import 'tp_route_info.dart';
import 'tp_router.dart';

/// Base class for all generated route classes.
///
/// Provides common navigation methods.
abstract class BaseRoute implements TpRouteObject {
  const BaseRoute();

  /// The full path of the route including query parameters.
  @override
  String get fullPath;

  /// Extra data to be passed to the route.
  @override
  Map<String, dynamic> get extra => const {};

  /// Navigate to this route.
  ///
  /// [clearHistory]: If true, uses `go()` (clears navigation history).
  /// [replacement]: If true, uses `pushReplacement()` (replaces current route).
  ///
  /// Returns a Future if using push methods, or null if using `go`.
  Future<Object?>? tp(
    BuildContext context, {
    bool clearHistory = false,
    bool replacement = false,
  }) {
    if (clearHistory) {
      context.tpRouter.go(this);
      return null;
    }
    if (replacement) {
      return context.tpRouter.pushReplacement(this);
    }
    return context.tpRouter.push(this);
  }

  /// Shortcut for [tp] with replacement = true.
  Future<Object?>? tpReplace(BuildContext context) {
    return tp(context, replacement: true);
  }
}
