import 'package:flutter/widgets.dart';
import 'package:teleport_router/teleport_router.dart';

extension TeleportRouterContextExtension on BuildContext {
  /// Access the TeleportRouter context helper.
  TeleportRouterContext get teleportRouter => TeleportRouterContext(this);
}

/// Helper class for accessing TeleportRouter methods with proper context.
class TeleportRouterContext {
  final BuildContext context;

  const TeleportRouterContext(this.context);

  /// Pop routes until the first route in the stack.
  void popToInitial() {
    TeleportRouter.instance.popToInitial(
      context: context,
    );
  }

  /// Pop the current route from the navigation stack.
  ///
  /// Returns `true` if the pop was performed, `false` if already at root.
  bool pop<T extends Object?>({T? result}) {
    return TeleportRouter.instance.pop<T>(
      result: result,
      context: context,
    );
  }

  /// Pop until the specified route is found.
  void popTo(TeleportRouteData route) {
    TeleportRouter.instance.popTo(
      route,
      context: context,
    );
  }

  /// Pop until predicate is satisfied.
  void popUntil(
      bool Function(Route<dynamic> route, TeleportRouteData? data) predicate) {
    TeleportRouter.instance.popUntil(
      predicate,
      context: context,
    );
  }

  /// Navigate to a route.
  ///
  /// Delegates to [TeleportRouter.teleport].
  Future<T?> teleport<T extends Object?>(
    TeleportRouteData route, {
    bool isReplace = false,
    bool isClearHistory = false,
  }) {
    return TeleportRouter.instance.teleport<T>(
      route,
      isReplace: isReplace,
      isClearHistory: isClearHistory,
    );
  }

  /// Get the current route data from the navigation context.
  TeleportRouteData get currentRoute {
    return TeleportRouter.instance.currentRoute(
      context: context,
    );
  }
}
