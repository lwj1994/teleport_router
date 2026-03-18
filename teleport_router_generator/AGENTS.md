# AGENTS.md

See `../AGENTS.md` for repository-wide rules.

## Scope
This directory contains the `build_runner` generator package.

## Focus Areas
- Generator entrypoints and analyzers live under `lib/`.
- Route writers, parsers, and data models live under `lib/src/`.
- Regression coverage for generated output lives under `test/`.

## Change Guidance
- Prefer changing generator logic and tests in the same task.
- When output format changes, update the narrowest possible tests instead of broad snapshots.
- If generated code shape changes, verify the example package still builds with `build_runner`.

## Validation
- `dart test`
- If generation output changes, also run `cd example && dart run build_runner build --delete-conflicting-outputs`.
