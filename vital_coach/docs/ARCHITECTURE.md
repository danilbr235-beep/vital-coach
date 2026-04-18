# Architecture (v1)

## High-level

- **Client**: Flutter (`vital_coach/`) — Android + Windows
- **Local-first**: SharedPreferences now; later Drift/SQLite for real entities + offline queue
- **Backend**: Supabase (Auth, Postgres, Storage, Edge Functions)
- **AI**: LLM calls only via Edge Functions (no keys in client)

## Client layers (target)

- `features/<feature>/` — UI + state + domain models
- `app/storage/` — local persistence helpers
- `app/` — navigation shell, theme

## Data flow

1. User interacts with UI → Riverpod notifier updates local state
2. Persist to local store
3. Sync queue to Supabase when online
4. Today rule-engine consumes snapshots → produces Today DTO

## Privacy posture

- Sensitive categories are “vault”: sexual logs, partner notes, appearance photos.
- Default to local-only until user explicitly enables cloud sync.
- RLS on all user-owned tables when enabled.

