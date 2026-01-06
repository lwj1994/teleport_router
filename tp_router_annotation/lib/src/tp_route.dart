/// Annotation to mark a widget class as a route.
///
/// This annotation is processed by the build_runner to
/// automatically generate route table entries.
///
/// Example:
/// ```dart
/// @TpRoute(path: '/home')
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///   // ...
/// }
/// ```
class TpRoute {
  /// The URL path for this route.
  ///
  /// Example: '/home', '/user/:id', '/settings'
  final String path;

  /// Optional name for the route.
  ///
  /// If not provided, the class name will be used.
  final String? name;

  /// Whether this route is the initial/default route.
  ///
  /// Only one route should be marked as initial.
  final bool isInitial;

  /// Creates a [TpRoute] annotation.
  ///
  /// [path] is required and specifies the URL path.
  /// [name] is optional, defaults to class name.
  /// [isInitial] marks this as the initial route.
  const TpRoute({
    required this.path,
    this.name,
    this.isInitial = false,
  });
}

/// Annotation to mark a widget class as a shell route.
///
/// A shell route wraps other routes with a common UI (like a bottom navigation bar).
///
/// Example:
/// ```dart
/// @TpShellRoute(
///   children: [HomePage, SettingsPage],
/// )
/// class MainShell extends StatelessWidget { ... }
/// ```
class TpShellRoute {
  /// The list of child page types that this shell wraps.
  final List<Type> children;

  /// Whether to use StatefulShellRoute.indexedStack.
  ///
  /// If true, the generated code will use `StatefulShellRoute.indexedStack`
  /// and each child in [children] will be placed in its own Branch.
  final bool isIndexedStack;

  /// Creates a [TpShellRoute] annotation.
  const TpShellRoute({
    required this.children,
    this.isIndexedStack = false,
  });
}

/// Annotation to mark a parameter as coming from URL path.
///
/// Example:
/// ```dart
/// @TpRoute(path: '/user/:userId')
/// class UserPage extends StatelessWidget {
///   @Path('userId')  // Maps path param 'userId' to 'id'
///   final int id;
///
///   const UserPage({required this.id, super.key});
/// }
/// ```
class Path {
  /// Custom parameter name in the path.
  ///
  /// If not provided, uses the field/parameter name.
  final String? name;

  /// Creates a [Path] annotation.
  const Path([this.name]);
}

/// Annotation to mark a parameter as coming from query string.
///
/// Example:
/// ```dart
/// @TpRoute(path: '/search')
/// class SearchPage extends StatelessWidget {
///   @Query()
///   final String keyword;
///
///   @Query('page_size')  // Maps query param 'page_size' to 'pageSize'
///   final int? pageSize;
///
///   const SearchPage({required this.keyword, this.pageSize, super.key});
/// }
/// ```
class Query {
  /// Custom parameter name in the query string.
  ///
  /// If not provided, uses the field/parameter name.
  final String? name;

  /// Creates a [Query] annotation.
  const Query([this.name]);
}
