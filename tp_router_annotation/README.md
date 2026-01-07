# tp_router_annotation

Annotations for [tp_router](https://pub.dev/packages/tp_router), to enable type-safe route generation.

This package defines the annotations used to configure routes, shell routes, and redirection logic.

## Annotations

*   `@TpRoute`: Define a route.
*   `@TpShellRoute`: Define a shell route (wrapper).
*   `@TpStatefulShellRoute`: Define a stateful shell route (e.g. IndexedStack).
*   `@Path`: Explicitly map a constructor parameter to a path parameter.
*   `@Query`: Explicitly map a constructor parameter to a query parameter.
