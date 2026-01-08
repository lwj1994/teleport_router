import 'package:flutter/widgets.dart';
import 'navi_key.dart';

/// Global registry for navigator keys.
///
/// This registry manages [GlobalKey<NavigatorState>] instances for named
/// navigators in your application. It provides a centralized way to access
/// navigators by their [TpNavKey].
///
/// ## How it works
///
/// The registry stores a mapping from [TpNavKey] to [GlobalKey<NavigatorState>].
/// When you define a [TpNavKey] and access its [globalKey] property, the key
/// is automatically registered here.
///
/// ## Usage
///
/// Typically you don't interact with this registry directly. Instead:
///
/// 1. Define your navigator keys:
/// ```dart
/// class DashboardNavKey extends TpNavKey {
///   const DashboardNavKey() : super('dashboard');
/// }
/// ```
///
/// 2. Access the GlobalKey via the TpNavKey:
/// ```dart
/// // Preferred way - use TpNavKey.globalKey
/// final key = const DashboardNavKey().globalKey;
///
/// // Or via registry (less common)
/// final key = TpNavigatorKeyRegistry.getOrCreate(const DashboardNavKey());
/// ```
///
/// ## Generated Code
///
/// The code generator creates GlobalKey references automatically:
/// ```dart
/// // In generated route.gr.dart:
/// class DashboardShellRoute {
///   static final navigatorGlobalKey = const DashboardNavKey().globalKey;
///   static const navigatorKey = DashboardNavKey();
///   // ...
/// }
/// ```
class TpNavigatorKeyRegistry {
  TpNavigatorKeyRegistry._();

  static GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// The global root navigator key.
  ///
  /// This is the key for the top-level Navigator in your app.
  static GlobalKey<NavigatorState> get rootKey => _rootKey;

  /// Update the global root navigator key.
  ///
  /// This is typically set by [TpRouter] during initialization.
  static set rootKey(GlobalKey<NavigatorState> value) => _rootKey = value;

  /// Internal storage for navigator keys.
  static final Map<TpNavKey, GlobalKey<NavigatorState>> _keys = {};

  /// Get or create a navigator key for the given [TpNavKey].
  ///
  /// If a GlobalKey for [naviKey] already exists, returns it.
  /// Otherwise, creates a new [GlobalKey<NavigatorState>] and registers it.
  ///
  /// Typically called via [TpNavKey.globalKey] rather than directly.
  static GlobalKey<NavigatorState> getOrCreate(TpNavKey naviKey) {
    return _keys.putIfAbsent(
      naviKey,
      () => GlobalKey<NavigatorState>(debugLabel: naviKey.toString()),
    );
  }

  /// Get a navigator key if it exists.
  ///
  /// Returns null if no GlobalKey has been registered for [naviKey].
  /// Use [getOrCreate] if you want to ensure a key is always returned.
  static GlobalKey<NavigatorState>? get(TpNavKey naviKey) => _keys[naviKey];

  /// Get all registered navigator keys.
  ///
  /// Returns an unmodifiable view of the internal key map.
  static Map<TpNavKey, GlobalKey<NavigatorState>> get all =>
      Map.unmodifiable(_keys);

  /// Clear all registered keys.
  ///
  /// **Warning**: This is mainly for testing purposes.
  /// Clearing keys in production may break navigation.
  static void clear() => _keys.clear();
}
