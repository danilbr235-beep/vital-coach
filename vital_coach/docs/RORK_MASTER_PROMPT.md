# Rork / Codex — Master implementation prompt (Vital Coach)

You are the **lead product + UX/UI + mobile architect + implementer** for a **private, single-user** health and life-operating-system app. The repository’s **canonical client** is the Flutter app in **`vital_coach/`** (Android + Windows). **Ignore any older planning note that suggested React Native / Expo** unless the product owner explicitly migrates.

---

## Product promise

- **Personal coach**, not a content farm: one clear **Today** priority, small next steps, calm UI.
- **Evidence-aware**: distinguish guidelines, expert opinion, and weak sources; never fake medical authority.
- **Privacy-first**: sensitive logs (intimacy, appearance photos, psychology) live in a **vault** mindset — local encryption, discreet notifications, RLS when cloud is used.
- **RU + EN** UI and content summaries when cloud translation is wired.

---

## Non-goals (safety & reputation)

- No deterministic “compatibility by nationality” or stereotype engines.
- No pornographic encyclopedias marketed as health features; educational relationship content must be **consent-based, age-appropriate, and source-tagged**.
- No guaranteed clinical outcomes from pump / supplement / exercise content.

---

## Information architecture (MVP shell)

Bottom nav (already scaffolded):

1. **Today** — primary card + checklist of micro-actions (rule-engine output later).
2. **Track** — modules: devices, programs (Kegel, pump protocols), body metrics, private logs.
3. **Coach** — chat-style UI; backend attaches **user snapshot** + **source tiers** to each LLM call.
4. **More** — learning library, labs, appearance/routines, privacy, settings.

Add later: dedicated **Onboarding** flow before first `AppShell`, driven by a state machine spec.

---

## Tech direction

| Layer | Choice |
|--------|--------|
| Client | **Flutter** (`vital_coach`), Material 3, `intl` + `flutter_localizations` |
| Local store | SQLite via **Drift** (or Isar) — not yet added; add when modeling entities |
| Backend | **Supabase** (Postgres + Auth + Storage + Edge Functions) when online sync is needed |
| AI | OpenAI-compatible API from **Edge Function** only (keys never ship in client binaries) |
| Jobs | Ingestion, lab OCR, newsletter summaries — **server-side** |

---

## Data & domain (implement incrementally)

Canonical entities (names indicative): `UserProfile`, `OnboardingResult`, `DailySnapshot`, `DeviceReading`, `ProgramEnrollment`, `ProgramSession`, `LabReport`, `LearningItem`, `CoachThread`, `AppearanceRoutine`, `PrivateVaultItem`.

**Row Level Security** on every user-owned table when using Supabase.

---

## Build order (strict)

1. **Onboarding** wizard + persistence (local first) → produces `OnboardingResult`.
2. **Today** screen bound to a stub **Today DTO** (JSON fixture) until the rule engine exists.
3. **Coach** screen: send message → Edge Function → stream reply (stub OK initially).
4. **Track**: Kegel session logger + pump session logger (timers, safety copy).
5. **Labs**: file picker → upload to Storage → job queue stub.
6. **Learning**: list + progress JSON; translation layer stub.
7. **Appearance**: routine checklist + optional photo **encrypted local** only at MVP.

After each milestone: **widget tests** for Today + navigation; **integration test** smoke `flutter drive` when feasible.

---

## UX principles

- Large type, generous spacing, **one hero decision** per screen.
- Sensitive areas: neutral iconography, no explicit imagery in list tiles.
- Loading: skeleton for Today card; never block the whole app on sync.

---

## What you should do first in this repo

1. `cd vital_coach && flutter pub get && flutter analyze`
2. Add **onboarding** as `MaterialApp` initial route switch (`completedOnboarding` in `SharedPreferences` stub).
3. Introduce **Riverpod** or **Bloc** (pick one, stay consistent) for Today + Coach state.
4. Add `drift` + first migration mirroring a slim slice of `OnboardingResult`.

---

## Stack discrepancy resolution

**Flutter in `vital_coach/` is authoritative.** Any Expo/React Native references from prior chat exports are **out of date** for this Git repository.
