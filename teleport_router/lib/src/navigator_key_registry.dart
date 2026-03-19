import 'package:flutter/widgets.dart';
import 'navi_key.dart';
import 'route_observer.dart';

/// Global registry for navigator keys and observers.
///
/// This registry manages [GlobalKey<NavigatorState>] instances and [TeleportRouteObserver]
/// for named navigators in your application. It provides a centralized way to access
/// navigators and their observers by their [TeleportNavKey].
///
/// ## How it works
///
/// The registry stores a mapping from [TeleportNavKey] to [GlobalKey<NavigatorState>]
/// and [TeleportRouteObserver]. When you define a [TeleportNavKey] and access its [globalKey]
/// or [observer] property, the key/observer is automatically registered here.
///
/// ## Usage
///
/// Typically you don't interact with this registry directly. Instead:
///
/// 1. Define your navigator keys:
/// ```dart
/// class MainDashboardNavKey extends TeleportNavKey {
///   const MainDashboardNavKey() : super('dashboard');
/// }
/// ```
///
/// 2. Access the GlobalKey via the TeleportNavKey:
/// ```dart
/// // Preferred way - use TeleportNavKey.globalKey
/// final key = const MainDashboardNavKey().globalKey;
///
/// // Or via registry (less common)
/// final key = TeleportNavigatorKeyRegistry.getOrCreate(const MainDashboardNavKey());
/// ```
///
/// 3. Access the observer for route stack manipulation:
/// ```dart
/// final observer = TeleportNavigatorKeyRegistry.getOrCreateObserver(const MainDashboardNavKey());
/// ```
class TeleportNavigatorKeyRegistry {
  TeleportNavigatorKeyRegistry._();

  static TeleportNavKey _rootKey =
      TeleportNavKey.value("${kTeleportRoutePrefix}root");

  /// The global root navigator key.
  static TeleportNavKey get rootKey => _rootKey;

  /// Update the global root navigator key.
  static set rootKey(TeleportNavKey value) => _rootKey = value;

  /// Internal storage for navigator keys.
  static final Map<TeleportNavKey, GlobalKey<NavigatorState>> _keys = {};

  /// Internal storage for observers.
  static final Map<TeleportNavKey, TeleportRouteObserver> _observers = {};

  /// Get or create a navigator key for the given [TeleportNavKey].
  static GlobalKey<NavigatorState> getOrCreate(TeleportNavKey naviKey) {
    return _keys.putIfAbsent(
      naviKey,
      () => GlobalKey<NavigatorState>(debugLabel: naviKey.toString()),
    );
  }

  /// Get or create a TeleportRouteObserver for the given [TeleportNavKey].
  ///
  /// This allows each navigation branch to have its own observer
  /// for route stack manipulation (e.g., removeRoute, popUntil).
  static TeleportRouteObserver getOrCreateObserver(TeleportNavKey naviKey) {
    return _observers.putIfAbsent(naviKey, () => TeleportRouteObserver());
  }

  /// Get a navigator key if it exists.
  static GlobalKey<NavigatorState>? get(TeleportNavKey naviKey) =>
      _keys[naviKey];

  /// Get an observer if it exists.
  static TeleportRouteObserver? getObserver(TeleportNavKey naviKey) =>
      _observers[naviKey];

  /// Get all registered navigator keys.
  static Map<TeleportNavKey, GlobalKey<NavigatorState>> get all =>
      Map.unmodifiable(_keys);

  /// Get all registered observers.
  static Map<TeleportNavKey, TeleportRouteObserver> get allObservers =>
      Map.unmodifiable(_observers);

  /// Clear all registered keys and observers.
  ///
  /// Called internally when [TeleportRouter] is re-initialized, and
  /// available for testing via `@visibleForTesting`.
  ///
  /// **Warning**: Do not call this manually in production. It is safe
  /// only during router re-initialization (which disposes the old router first)
  /// or in test teardown.
  @visibleForTesting
  static void clear() {
    _keys.clear();
    _observers.clear();
  }
}
