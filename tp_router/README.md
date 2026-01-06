# TpRouter

A simplified, type-safe routing library built on top of `go_router` for Flutter. Integrate routing with just a single annotation!

## Features

- 🎯 **One-Line Annotation**: Mark your widget with `@TpRoute(path: '/xxx')`.
- 🔄 **Auto Type Conversion**: Automatically convert parameters from String to `int`, `double`, `bool`, etc.
- 🧩 **Smart Parameter Extraction**:
  - Explicitly map to Path (`@Path`) or Query (`@Query`) parameters.
  - **Fallback Logic**: Unannotated fields default to `extra`, but fallback to `path` or `query` automatically for simple types.
- �️ **Transition Support**: Built-in Cupertino and Material transitions, plus support for custom transitions.
- 🌍 **Global Configuration**: Set default transitions and durations globally.
- 📦 **Single File Output**: All routes generated into a single `tp_router.g.dart` file.
- 🔌 **Context Extensions**: Easy navigation via `context.tpPush('/path')`.
- 🌐 **go_router Compatible**: Full access to underlying `go_router` features.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  tp_router: ^0.0.1
  tp_router_annotation: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
  tp_router_generator: ^0.0.1
```

## Getting Started

### 1. Define a Route

Annotate your widget class. Parameters in the constructor are automatically handled.

```dart
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

@TpRoute(path: '/user/:id', name: 'user')
class UserPage extends StatelessWidget {
  // Explicitly from Path: /user/:id
  @Path('id')
  final int userId;

  // Implicitly from Extra with Fallback to Query: ?name=John
  final String name;

  const UserPage({
    required this.userId,
    this.name = 'Guest',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User $name')),
      body: Center(child: Text('ID: $userId')),
    );
  }
}
```

### 2. Run Build Runner

Generate the routing code:

```bash
dart run build_runner build
```

This creates `lib/tp_router.g.dart`.

### 3. Initialize Router

Initialize `TpRouter` in your `main.dart` using the generated routes.

```dart
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';
import 'tp_router.g.dart'; // Generated file

void main() {
  // Initialize with generated routes
  final router = TpRouter(
    routes: tpRoutes,
    // Global transition defaults (Optional)
    defaultTransition: const TpMaterialPageTransition(),
    defaultTransitionDuration: const Duration(milliseconds: 300),
  );

  runApp(MaterialApp.router(
    routerConfig: router.routerConfig,
  ));
}
```

## Parameter Extraction Rules

TpRouter employs a smart strategy to populate your widget fields:

1.  **Explicit Annotations**:
    *   `@Path('paramName')`: Strictly fetches from path parameters.
    *   `@Query('paramName')`: Strictly fetches from query parameters.

2.  **Implicit (No Annotation)**:
    *   **Complex Types** (Objects, Lists): Fetched strictly from `extra` map.
    *   **Simple Types** (`int`, `String`, `bool`, `double`):
        1.  Checks `extra` map first.
        2.  **Fallback**: If not found in `extra`, attempts to find key in `path` parameters.
        3.  **Fallback**: Finally checks `query` parameters.

This allows you to be flexible: pass data via arguments (cleaner) or via URL (deep linkable), and the widget receives it seamlessly.

## Transitions

You can configure page transitions at the route level or globally.

### Route Level
Override the default transition for a specific page:

```dart
@TpRoute(
  path: '/details',
  transition: TpCupertinoPageTransition(), // iOS style slide
  // Or: TpMaterialPageTransition(),      // Fade/Zoom up
)
class DetailsPage extends StatelessWidget { ... }
```

### Custom Transitions
Extend `TpTransitionsBuilder` to create your own effects:

```dart
class MyFadeTransition extends TpTransitionsBuilder {
  const MyFadeTransition();
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, 
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
```

## Navigation

Use the context extensions for easy navigation:

```dart
## Navigation

### Type-Safe Navigation (Recommended)
Use the generated route classes:

```dart
// Push a new route
HomeRoute().tp(context);

// Pass parameters (Constructor arguments)
UserRoute(userId: 42, name: 'Alice').tp(context);

// Replace current route
SettingsRoute().tp(context, replacement: true);

// Clear history (like .go)
LoginRoute().tp(context, clearHistory: true);
```

### Dynamic Navigation
Use `TpRouteData.fromPath`:

```dart
// Push by path
TpRouteData.fromPath('/user/42?name=Alice').tp(context);

// Pass complex data (extra)
TpRouteData.fromPath('/details', extra: {'item': myItem}).tp(context);
```

### Context API
Access via `context.tpRouter`:

```dart
context.tpRouter.pop();
final location = context.tpRouter.currentFullPath;
```


## License

MIT License
