# AGENTS.md

See `../AGENTS.md` and `../../AGENTS.md` for broader repository rules.

## Scope
This directory is the example app for the runtime package.

## Focus Areas
- App entrypoint and annotated routes live under `lib/`.
- Generator configuration lives in `build.yaml`.
- Example tests live under `test/`.

## Change Guidance
- Prefer editing source annotations and widgets instead of generated `*.gr.dart` files.
- Keep the example representative of supported public APIs rather than experimental internals.
- If runtime APIs change, update the example to remain a working reference implementation.

## Validation
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test`
- `flutter run`
