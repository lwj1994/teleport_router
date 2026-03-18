# AGENTS.md

## Scope
Applies to the whole `tp_router` repository. A deeper `AGENTS.md` in a child directory overrides or extends these rules.

## Repository Layout
- `teleport_router`: runtime router package.
- `teleport_router_annotation`: annotations consumed by the generator.
- `teleport_router_generator`: `build_runner` generator and code-writing logic.
- `teleport_router/example`: example app for the runtime package.
- `teleport_router_generator/example`: example app for generator usage.

## Working Rules
- Keep versions aligned across `teleport_router`, `teleport_router_annotation`, and `teleport_router_generator` when preparing a release.
- Do not change the `teleport_router_annotation` dependency version line unless the task explicitly requires it.
- Prefer editing source files under `lib/`, `test/`, and docs. Ignore `.dart_tool/`, `build/`, and `coverage/` unless the task is specifically about generated artifacts or tooling.
- If a change affects public annotations, generated route shape, or runtime APIs, verify the impacted sibling packages and examples.
- Do not hand-edit generated Dart outputs unless the task explicitly targets generated code snapshots.

## Validation
- Runtime package: `cd teleport_router && flutter test`
- Generator package: `cd teleport_router_generator && dart test`
- Runtime example: `cd teleport_router/example && dart run build_runner build --delete-conflicting-outputs && flutter test`
- Generator example: `cd teleport_router_generator/example && dart run build_runner build --delete-conflicting-outputs`

## Release Workflow
- Run router and generator tests before publishing.
- Update versions and changelogs together for the three publishable packages.
- Publish in this order: `teleport_router_annotation`, `teleport_router_generator`, `teleport_router`.
