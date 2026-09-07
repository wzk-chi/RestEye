# Repository Guidelines

## Project Structure

This repository contains one Flutter package. `lib/main.dart` only starts bootstrap. Shared composition and navigation live in `lib/app/`; stable primitives in `lib/core/`; Drift schema and migrations in `lib/infrastructure/database/`; feature slices (`timer`, `settings`, `statistics`, `about`) in `lib/features/`; native adapters in `lib/platform/`; and ARB/localization helpers in `lib/l10n/`. Android, Windows, and macOS host code stays under their platform directories. Read [requirements](docs/requirements.md) for product behavior and [architecture](docs/architecture.md) before coding; the architecture document is the normative guide for layers, dependencies, contracts, and extension boundaries.

## Product Naming

Use `RestEye` as the product name in user-facing copy, documentation, task descriptions, build instructions, and release artifact labels. Do not refer to the product generically as “app”. Preserve technical identifiers required by the platform or existing build contracts, such as the Flutter package name, Android `applicationId`, and native executable filenames, unless an explicit migration is requested.

For GitHub direct-download Android releases, use `tool/build_resteye_android.ps1` as the canonical entry point. It builds and publishes only the `arm64-v8a` APK with a `RestEye-<version>-android-arm64-v8a.apk` release label. Do not build or publish universal, `armeabi-v7a`, or `x86_64` APKs unless explicitly requested.

For local Android debug installation, use `tool/build_resteye_android_debug.ps1`. Debug uses the distinct package id `dev.resteye.app.debug`, version suffix `-debug`, and artifact label `RestEye-<version>-android-arm64-v8a-debug.apk`, so it can coexist with the release package `dev.resteye.app`. Do not use a debug artifact as a GitHub release unless explicitly requested.

For GitHub Windows releases, use `tool/build_resteye_windows.ps1` as the canonical entry point. It builds the x64 Release directory and packages the complete directory with Inno Setup as `RestEye-<version>-windows-x64-setup.exe`. Do not publish only `rest_eye.exe`; the installer must include all sibling DLLs and the `data` directory. Do not launch RestEye during packaging.

## Architecture Rules

Keep dependencies pointed inward: presentation calls application, application depends on domain ports, and data implements domain repositories. Feature code must not import `app/bootstrap`, databases, or plugin types. Use feature-owned Riverpod providers; bootstrap only composes concrete implementations. All timer mutations pass through the serialized dispatcher. Persist UTC timestamps, stable enum names, and immutable snapshots through Drift. Keep notification, screen-state, lifecycle, and window behavior behind application ports. The desktop tray/menu preference is `minimizeToTrayOnClose`, defaults to `true`, and must be applied through `WindowBehaviorGateway`; Win32 code stays in `windows/runner/`, AppKit code in `macos/Runner/`.

Treat `ScreenState.unknown` as an unavailable signal, never as `off`: it may degrade capability status but must not close an open screen-activity interval or change timer state. When supported, `ScreenState.off` means the device is locked; a display turning off by itself must not be treated as a lock. Platform adapters must preserve the shared channel contract on Android, Windows, and macOS; unsupported capabilities should degrade explicitly rather than silently changing user data. Desktop menu labels and action ids use the shared `dev.resteye/window_behavior` and `dev.resteye/window_behavior/events` contract; native menu actions must return to `TimerController`.

The Android orientation preference is fixed portrait when enabled (default on). The lock-pause preference is named `pauseWhenLocked`; Android derives its state from `KeyguardManager` and the unlock broadcast, not only from display interactivity. Keep settings cards visually uniform by omitting decorative leading icons from every setting row; retain only functional controls such as switches, arrows, and selection indicators.

Route every settings mutation through `SettingsController`. Valid changes auto-save through its debounced, serialized pipeline; invalid drafts never replace the last persisted settings. Theme and locale preferences use stable `system`/explicit enum codes. Duration changes stop the active timer (the UI confirms before saving) and apply from the next cycle; an active cycle's config snapshot is never mutated by settings.

## Development and Verification

Run commands from the directory containing `pubspec.yaml`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs # schema changes
flutter gen-l10n                                      # ARB changes
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter build apk --debug
flutter build windows --release # only when a Windows build check is requested
```

On a macOS host, use `flutter build macos`; on Windows, macOS builds are deferred. Windows UI launch and smoke verification belong to the user; do not launch or inspect that UI unless explicitly requested. This project intentionally has no unit, widget, or integration tests and no coverage gate. Do not add test files unless the product constraint changes. Use static analysis and platform builds for code verification; runtime smoke checks are performed by the user.

## Style and Naming

Use Dart format, two-space indentation, `snake_case.dart` files, `UpperCamelCase` types, `lowerCamelCase` members, `const`/`final`, immutable state, and exhaustive switches. Prefer `package:rest_eye/...` imports. Keep widgets, orchestration, persistence, and platform code in focused files; do not create generic `utils.dart` or `helpers.dart`. Never edit generated Drift or localization files manually.

## Changes and Reviews

Update the detailed docs when changing state semantics, schema, ports, localization, or platform behavior. For Windows tray changes, record the manual result separately; do not launch or inspect the Windows UI unless the user asks. Include commands run, tested platforms, deferred macOS status, and UI evidence in review descriptions. No Git history is available in this checkout; when commits are applicable elsewhere, use concise Conventional Commit messages such as `feat: add timer state machine` or `refactor: split app bootstrap`.
