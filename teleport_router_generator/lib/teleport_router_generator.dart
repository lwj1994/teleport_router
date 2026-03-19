/// Code generation library for teleport_router.
///
/// This library provides the [TeleportRouterBuilder] that processes
/// `@TeleportRoute` and `@TeleportShellRoute` annotations to generate
/// type-safe routing code for Flutter applications.
///
/// Shell routes configured with `@TeleportShellRoute(isIndexedStack: true)`
/// are emitted as stateful shell route info in the generated output.
///
/// ## Usage
///
/// This package is designed to be used with [build_runner]. Add the runtime
/// packages to `dependencies` and the generator to `dev_dependencies`:
///
/// ```yaml
/// dependencies:
///   teleport_router: ^0.8.5
///   teleport_router_annotation: ^0.8.5
///
/// dev_dependencies:
///   build_runner: 2.10.4
///   teleport_router_generator: ^0.8.5
/// ```
///
/// Then run:
///
/// ```bash
/// dart run build_runner build
/// ```
///
/// For more information and complete examples, see the
/// [teleport_router](https://pub.dev/packages/teleport_router) package documentation.
library teleport_router_generator;

export 'src/teleport_route_generator.dart';
