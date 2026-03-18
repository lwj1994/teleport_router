# AGENTS.md

See `../AGENTS.md` for repository-wide rules.

## Scope
This directory is the publishable Flutter runtime package.

## Focus Areas
- Core runtime and navigation APIs live under `lib/`.
- Package regression tests live under `test/`.
- The example app in `example/` is the fastest way to verify user-facing behavior.

## Change Guidance
- Keep public API changes backward compatible unless the task explicitly allows a breaking change.
- When changing navigation behavior, check tests around observers, navigator keys, route data, and router initialization.
- If docs or examples rely on changed APIs, update `README.md` and `README_zh.md` when needed.

## Validation
- `flutter test`
- If the change touches generated route behavior or annotations, also validate `example/` with `dart run build_runner build --delete-conflicting-outputs` and `flutter test`.
