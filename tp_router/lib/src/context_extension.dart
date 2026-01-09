import 'package:flutter/widgets.dart';
import 'package:tp_router/tp_router.dart';

extension TpRouterContextExtension on BuildContext {
  /// Access the TpRouter context helper.
  TpRouterContext get tpRouter => TpRouterContext(this);
}

/// Helper class for accessing TpRouter methods with proper context.
class TpRouterContext {
  final BuildContext context;

  const TpRouterContext(this.context);

  /// Pop routes until the first route in the stack.
  void popToInitial() {
    TpRouter.instance.popToInitial(
      context: context,
    );
  }

  /// Pop until the specified route is found.
  void popTo(TpRouteData route) {
    TpRouter.instance.popTo(
      route,
      context: context,
    );
  }

  /// Pop until predicate is satisfied.
  void popUntil(
      bool Function(Route<dynamic> route, TpRouteData? data) predicate) {
    TpRouter.instance.popUntil(
      predicate,
      context: context,
    );
  }

  TpRouteData get location {
    return TpRouter.instance.location(
      context: context,
    );
  }
}
