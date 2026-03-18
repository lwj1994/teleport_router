import 'models/route_data.dart';

Map<String, String> buildShellBasePaths(List<BaseRouteData> routes) {
  final shellBasePaths = <String, String>{};
  final shellsByKey = <String, ShellRouteData>{};

  for (final route in routes) {
    if (route is! ShellRouteData) continue;
    shellsByKey[route.navigatorKey] = route;
    for (final branchKey in route.branchKeys) {
      shellsByKey[branchKey] = route;
    }
  }

  for (final route in routes) {
    if (route is! ShellRouteData) continue;
    final basePath = _resolveShellBasePath(
      route,
      shellsByKey,
      shellBasePaths,
      <String>{},
    );
    shellBasePaths[route.navigatorKey] = basePath;
    for (final branchKey in route.branchKeys) {
      shellBasePaths[branchKey] = basePath;
    }
  }

  return shellBasePaths;
}

String _resolveShellBasePath(
  ShellRouteData route,
  Map<String, ShellRouteData> shellsByKey,
  Map<String, String> resolvedPaths,
  Set<String> visiting,
) {
  final cached = resolvedPaths[route.navigatorKey];
  if (cached != null) {
    return cached;
  }

  if (!visiting.add(route.navigatorKey)) {
    return _normalizeBasePath(route.basePath);
  }

  final rawBasePath = route.basePath;
  final parentBasePath = _resolveParentBasePath(
    route.parentNavigatorKey,
    shellsByKey,
    resolvedPaths,
    visiting,
  );

  final resolvedBasePath = switch (rawBasePath) {
    null || '' => parentBasePath ?? '/',
    final absolute when absolute.startsWith('/') =>
      _normalizeBasePath(absolute),
    final relative => _joinPaths(parentBasePath ?? '/', relative),
  };

  visiting.remove(route.navigatorKey);
  return resolvedBasePath;
}

String? _resolveParentBasePath(
  String? parentNavigatorKey,
  Map<String, ShellRouteData> shellsByKey,
  Map<String, String> resolvedPaths,
  Set<String> visiting,
) {
  if (parentNavigatorKey == null) {
    return null;
  }

  final cached = resolvedPaths[parentNavigatorKey];
  if (cached != null) {
    return cached;
  }

  final parentShell = shellsByKey[parentNavigatorKey];
  if (parentShell == null) {
    return null;
  }

  final resolvedBasePath = _resolveShellBasePath(
    parentShell,
    shellsByKey,
    resolvedPaths,
    visiting,
  );
  resolvedPaths[parentShell.navigatorKey] = resolvedBasePath;
  for (final branchKey in parentShell.branchKeys) {
    resolvedPaths[branchKey] = resolvedBasePath;
  }
  return resolvedBasePath;
}

String _normalizeBasePath(String? basePath) {
  if (basePath == null || basePath.isEmpty || basePath == '/') {
    return '/';
  }

  var normalized = basePath;
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

String _joinPaths(String basePath, String childPath) {
  final normalizedBase = _normalizeBasePath(basePath);
  final normalizedChild =
      childPath.startsWith('/') ? _normalizeBasePath(childPath) : childPath;

  if (normalizedChild.startsWith('/')) {
    return normalizedChild;
  }

  if (normalizedBase == '/') {
    return '/$normalizedChild';
  }

  return '$normalizedBase/$normalizedChild';
}

String resolveRoutePath(
  RouteData route,
  Map<String, String> shellBasePaths,
) {
  if (!route.path.startsWith('/') && route.parentNavigatorKey != null) {
    final basePath = shellBasePaths[route.parentNavigatorKey];
    if (basePath != null) {
      return _joinPaths(basePath, route.path);
    }
  }

  return route.path;
}

List<String> findMissingIndexedStackBranchKeys(
  ShellRouteData shell,
  List<BaseRouteData> routes,
) {
  if (!shell.isIndexedStack || shell.branchKeys.isEmpty) {
    return const [];
  }

  final missingBranchKeys = <String>[];
  for (var index = 0; index < shell.branchKeys.length; index++) {
    final allowedParentKeys = <String>{
      if (index == 0) shell.navigatorKey,
      shell.branchKeys[index],
    };
    if (!_hasLeafRouteForParentKeys(allowedParentKeys, routes, <String>{})) {
      missingBranchKeys.add(shell.branchKeys[index]);
    }
  }

  return missingBranchKeys;
}

bool _hasLeafRouteForParentKeys(
  Set<String> parentKeys,
  List<BaseRouteData> routes,
  Set<String> visitingShells,
) {
  for (final route in routes) {
    String? parentNavigatorKey;
    if (route is RouteData) {
      parentNavigatorKey = route.parentNavigatorKey;
    } else if (route is ShellRouteData) {
      parentNavigatorKey = route.parentNavigatorKey;
    }

    if (parentNavigatorKey == null ||
        !parentKeys.contains(parentNavigatorKey)) {
      continue;
    }

    if (route is RouteData) {
      return true;
    }

    if (_shellContainsLeafRoute(
        route as ShellRouteData, routes, visitingShells)) {
      return true;
    }
  }

  return false;
}

bool _shellContainsLeafRoute(
  ShellRouteData shell,
  List<BaseRouteData> routes,
  Set<String> visitingShells,
) {
  if (!visitingShells.add(shell.navigatorKey)) {
    return false;
  }

  final childParentKeys = <String>{
    shell.navigatorKey,
    ...shell.branchKeys,
  };
  final hasLeafRoute =
      _hasLeafRouteForParentKeys(childParentKeys, routes, visitingShells);

  visitingShells.remove(shell.navigatorKey);
  return hasLeafRoute;
}
