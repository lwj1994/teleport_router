# AGENTS.md

See `../AGENTS.md` and `../../AGENTS.md` for broader repository rules.

## Scope
This directory is the example app for `teleport_router_generator`.

## Focus Areas
- Example source lives under `lib/`.
- Generator configuration lives in `build.yaml`.
- This package is primarily used to verify that generator output compiles and remains usable.

## Change Guidance
- Prefer changing annotated source files and rebuilding generated output rather than editing generated files directly.
- Keep the example small and focused on generation behavior.
- If writer or parser changes alter generated code shape, regenerate here and confirm the example still builds.

## Validation
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
