# AGENTS.md

See `../AGENTS.md` for repository-wide rules.

## Scope
This directory contains the annotation package shared by the runtime and generator packages.

## Focus Areas
- Public annotations are exported from `lib/teleport_router_annotation.dart`.
- Most annotation definitions live under `lib/src/`.
- Small schema changes here can cascade into generator parsing and runtime documentation.

## Change Guidance
- Keep annotation APIs minimal and source-compatible unless the task explicitly allows a breaking change.
- Prefer changing annotation definitions and documentation together.
- If an annotation shape changes, verify the generator and runtime packages that consume it.

## Validation
- `flutter analyze`
- If annotation fields or semantics change, also run `cd ../teleport_router_generator && dart test` and `cd ../teleport_router && flutter test`.
