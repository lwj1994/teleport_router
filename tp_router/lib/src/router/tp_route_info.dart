import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Function type for building a page widget from route parameters.
///
/// [settings] contains all parsed and type-converted parameters.
typedef TpPageBuilder = Widget Function(TpRouteSettings settings);

/// Function type for building a shell widget (e.g. Scaffod with generic child).
typedef TpShellBuilder = Widget Function(BuildContext context, Widget child);

/// Holds parsed route parameters with type-safe access.
class TpRouteSettings {
  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  final Object? extra;
  final Map<String, dynamic> _typedParams;

  TpRouteSettings({
    required this.pathParams,
    required this.queryParams,
    this.extra,
    Map<String, dynamic>? typedParams,
  }) : _typedParams = typedParams ?? {};

  String? getString(String key, {String? defaultValue}) {
    return pathParams[key] ?? queryParams[key] ?? defaultValue;
  }

  String getStringRequired(String key) {
    final value = getString(key);
    if (value == null) {
      throw ArgumentError('Missing required String parameter: $key');
    }
    return value;
  }

  int? getInt(String key, {int? defaultValue}) {
    if (_typedParams.containsKey(key)) {
      final val = _typedParams[key];
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? defaultValue;
    }
    final raw = pathParams[key] ?? queryParams[key];
    if (raw == null) return defaultValue;
    return int.tryParse(raw) ?? defaultValue;
  }

  int getIntRequired(String key) {
    final value = getInt(key);
    if (value == null) {
      throw ArgumentError('Missing required int parameter: $key');
    }
    return value;
  }

  double? getDouble(String key, {double? defaultValue}) {
    if (_typedParams.containsKey(key)) {
      final val = _typedParams[key];
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultValue;
    }
    final raw = pathParams[key] ?? queryParams[key];
    if (raw == null) return defaultValue;
    return double.tryParse(raw) ?? defaultValue;
  }

  double getDoubleRequired(String key) {
    final value = getDouble(key);
    if (value == null) {
      throw ArgumentError('Missing required double parameter: $key');
    }
    return value;
  }

  bool? getBool(String key, {bool? defaultValue}) {
    if (_typedParams.containsKey(key)) {
      final val = _typedParams[key];
      if (val is bool) return val;
      if (val is String) return _parseBool(val) ?? defaultValue;
    }
    final raw = pathParams[key] ?? queryParams[key];
    if (raw == null) return defaultValue;
    return _parseBool(raw) ?? defaultValue;
  }

  bool getBoolRequired(String key) {
    final value = getBool(key);
    if (value == null) {
      throw ArgumentError('Missing required bool parameter: $key');
    }
    return value;
  }

  T? getExtra<T>(String key) {
    if (extra is Map) {
      final map = extra as Map;
      if (map.containsKey(key)) {
        return map[key] as T?;
      }
    }
    return null;
  }

  T? getExtraAs<T>() {
    if (extra is T) {
      return extra as T;
    }
    return null;
  }

  bool? _parseBool(String value) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') {
      return true;
    }
    if (lower == 'false' || lower == '0' || lower == 'no') {
      return false;
    }
    return null;
  }

  dynamic operator [](String key) {
    return _typedParams[key] ??
        pathParams[key] ??
        queryParams[key] ??
        getExtra(key);
  }
}

/// Abstract base class for defining route topology.
abstract class TpRouteBase {
  const TpRouteBase();

  /// Convert to GoRouter's RouteBase.
  RouteBase toGoRoute();
}

/// Represents a single route entry in the route table.
///
/// This class holds all information needed to create a GoRoute.
class TpRouteInfo extends TpRouteBase {
  /// The URL path pattern for this route.
  final String path;

  /// Optional route name for named navigation.
  final String? name;

  /// Builder function to create the page widget.
  final TpPageBuilder builder;

  /// Whether this is the initial/default route.
  final bool isInitial;

  /// Parameter metadata for documentation and validation.
  final List<TpParamInfo> params;

  /// Child routes.
  final List<TpRouteBase> children;

  /// Creates a [TpRouteInfo] instance.
  const TpRouteInfo({
    required this.path,
    required this.builder,
    this.name,
    this.isInitial = false,
    this.params = const [],
    this.children = const [],
  });

  @override
  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) {
        final settings = TpRouteSettings(
          pathParams: state.pathParameters,
          queryParams: state.uri.queryParameters,
          extra: state.extra,
        );
        return builder(settings);
      },
      routes: children.map((c) => c.toGoRoute()).toList(),
    );
  }
}

/// A shell route that wraps a child route with a shell UI.
///
/// This is typically used for Scaffolds with persistent bottom navigation.
class TpShellRouteInfo extends TpRouteBase {
  /// Builder for the shell UI.
  final TpShellBuilder builder;

  /// The list of routes that will be displayed within the shell.
  final List<TpRouteBase> routes;

  const TpShellRouteInfo({
    required this.builder,
    required this.routes,
  });

  @override
  RouteBase toGoRoute() {
    return ShellRoute(
      builder: (context, state, child) {
        // We wrap the GoRouter state away, exposing just context and child
        return builder(context, child);
      },
      routes: routes.map((r) => r.toGoRoute()).toList(),
    );
  }
}

/// Wrapper for StatefulNavigationShell to expose safe API.
class TpStatefulNavigationShell extends StatelessWidget {
  final StatefulNavigationShell _shell;
  const TpStatefulNavigationShell(this._shell, {super.key});

  /// The current branch index.
  int get currentIndex => _shell.currentIndex;

  /// Switch to a branch.
  void goBranch(int index, {bool initialLocation = false}) {
    _shell.goBranch(index, initialLocation: initialLocation);
  }

  @override
  Widget build(BuildContext context) => _shell;
}

/// Function type for building a stateful shell widget (uses navigationShell).
typedef TpStatefulShellBuilder = Widget Function(
  BuildContext context,
  TpStatefulNavigationShell navigationShell,
);

/// A stateful shell route using indexed stack.
class TpStatefulShellRouteInfo extends TpRouteBase {
  /// Builder for the shell UI.
  final TpStatefulShellBuilder builder;

  /// The branches (tabs), each containing a list of routes.
  final List<List<TpRouteBase>> branches;

  const TpStatefulShellRouteInfo({
    required this.builder,
    required this.branches,
  });

  @override
  RouteBase toGoRoute() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return builder(context, TpStatefulNavigationShell(navigationShell));
      },
      branches: branches.map((routes) {
        return StatefulShellBranch(
          routes: routes.map((r) => r.toGoRoute()).toList(),
        );
      }).toList(),
    );
  }
}

/// Metadata about a route parameter.
class TpParamInfo {
  final String name;
  final String urlName;
  final String type;
  final bool isRequired;
  final Object? defaultValue;
  final String source;

  const TpParamInfo({
    required this.name,
    required this.urlName,
    required this.type,
    required this.isRequired,
    this.defaultValue,
    this.source = 'auto',
  });
}

/// Interface for generated route objects.
abstract class TpRouteObject {
  /// The full path of the route including query parameters.
  String get fullPath;

  /// Extra data to be passed to the route.
  Map<String, dynamic> get extra;
}
