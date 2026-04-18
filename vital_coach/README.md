# Vital Coach (Flutter)

Canonical **client** stack for the private health / life-OS product: **Flutter** targeting **Android** and **Windows** (same Dart codebase, offline-first later).

Any earlier mention of **React Native / Expo** in planning packs is **deprecated** for this repository: stay on Flutter unless you explicitly choose to migrate.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable (3.24+ recommended)
- Android SDK (device or emulator) and/or Windows desktop support enabled (`flutter config --enable-windows-desktop`)

## Run

```bash
cd vital_coach
flutter pub get
flutter run -d windows
# or
flutter run -d android
```

## Layout

- `lib/app/` — root widget, theme, navigation shell
- `lib/features/` — feature modules (today, coach, onboarding, …) — expand as you implement contracts from `docs/RORK_MASTER_PROMPT.md`

## Related

- Root of this repo still contains the older **Soft Goals** Node/Express demo; it is unrelated to Vital Coach.
