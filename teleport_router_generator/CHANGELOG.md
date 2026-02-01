# 0.8.5

* Fix parameter extraction: use `operator []` on `TeleportRouteData` instead of direct `extra` Map access. This prevents errors when `extra` is not a `Map`.

# 0.8.4

* Allow nullable `@Query` parameters without explicit default value (null is implicit default).
* Improve build error handling: validation errors now properly surface in build output.

# 0.8.3

* Support updated `TeleportPageType`.
