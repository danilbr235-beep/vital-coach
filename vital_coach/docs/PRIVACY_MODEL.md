# Privacy model (v1)

## Principles

- The app is **private by default**.
- Sensitive data is treated as **vault data**.
- No explicit content in notifications.
- Cloud sync is opt-in; when enabled, all access is controlled by **RLS**.

## Data classes

- **Class A (Vault)**: sexual activity logs, partner notes, appearance photos, mental notes
- **Class B (Sensitive)**: labs, medications, supplements, symptoms
- **Class C (General health)**: sleep, steps, weight, recovery metrics
- **Class D (Non-sensitive)**: UI preferences, language

## Storage policy (MVP)

- Vault data: local-only (later: encrypted local DB + optional encrypted cloud blobs).
- Sensitive: local-first; cloud sync only when enabled.
- General: local-first; cloud sync optional.

## Keys

- LLM keys must never ship in the Flutter app bundle.
- Only server-side (Edge Function) holds secrets.

