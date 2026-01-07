import 'package:flutter/widgets.dart';

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
///
/// // With custom transition:
/// @TpRoute(path: '/details', transitionsBuilder: TpFadeTransition())
/// class DetailsPage extends StatelessWidget { ... }
/// ```
class TpRoute {
  /// The URL path for this route.
  ///
  /// Example: '/home', '/user/:id', '/settings'
  /// The URL path for this route.
  ///
  /// Example: '/home', '/user/:id', '/settings'
  ///
  /// If null or empty, it will be auto-generated from the class name.
  final String? path;

  /// Optional name for the route.
  ///
  /// If not provided, the class name will be used.
  final String? name;

  /// Whether this route is the initial/default route.
  ///
  /// Only one route should be marked as initial.
  final bool isInitial;

  /// Custom transition builder for this route.
  ///
  /// Should be a const instance of a class that extends [TpTransitionsBuilder].
  /// Built-in options (from tp_router): TpFadeTransition, TpSlideTransition, TpNoTransition.
  ///
  /// Example:
  /// ```dart
  /// @TpRoute(path: '/fade', transition: TpFadeTransition())
  /// class FadePage extends StatelessWidget { ... }
  /// ```
  final TpTransitionsBuilder? transition;

  /// Transition duration. Defaults to 300ms.
  final Duration transitionDuration;

  /// Reverse transition duration. Defaults to 300ms.
  final Duration reverseTransitionDuration;

  /// A top-level function or static method to handle redirection.
  ///
  /// Signature: `FutureOr<TpRouteData?> redirect(BuildContext context, TpRouteData state)`
  ///
  /// Example:
  /// ```dart
  /// @TpRoute(path: '/protected', redirect: authRedirect)
  /// class ProtectedPage extends StatelessWidget { ... }
  /// ```
  final dynamic redirect;

  /// Creates a [TpRoute] annotation.
  const TpRoute({
    this.path,
    this.name,
    this.isInitial = false,
    this.redirect,
    this.transition,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
  });
}

/// Abstract base class for custom page transitions.
///
/// Extend this class to create custom page transition animations.
/// Built-in implementations are provided in `tp_router` package.
///
/// Example:
/// ```dart
/// class MySlideTransition extends TpTransitionsBuilder {
///   const MySlideTransition();
///
///   @override
///   Widget buildTransitions(
///     BuildContext context,
///     Animation<double> animation,
///     Animation<double> secondaryAnimation,
///     Widget child,
///   ) {
///     return SlideTransition(
///       position: Tween<Offset>(
///         begin: const Offset(1.0, 0.0),
///         end: Offset.zero,
///       ).animate(animation),
///       child: child,
///     );
///   }
/// }
/// ```
abstract class TpTransitionsBuilder {
  const TpTransitionsBuilder();

  /// Build the transition animation for the page.
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );
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
  final bool isIndexedStack;

  /// Creates a [TpShellRoute] annotation.
  const TpShellRoute({
    required this.children,
    this.isIndexedStack = false,
  });
}

/// Annotation to mark a parameter as coming from URL path.
class Path {
  /// Custom parameter name in the path.
  final String? name;

  /// Creates a [Path] annotation.
  const Path([this.name]);
}

/// Annotation to mark a parameter as coming from query string.
class Query {
  /// Custom parameter name in the query string.
  final String? name;

  /// Creates a [Query] annotation.
  const Query([this.name]);
}
