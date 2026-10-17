# Security and reliability hardening

This block addresses findings identified by automated review around profiles, trade offers and chat realtime behavior.

## Changes

- Ensure a fresh Supabase database can create `products` before applying ownership policies.
- Provide the `profiles` table and owner-scoped RLS policies required by authentication.
- Validate trade-offer ownership and immutable fields in the database.
- Make offer creation and response operations transactional through database RPCs.
- Enable Postgres Changes for `messages` when necessary.
- Release chat realtime subscriptions when leaving a conversation detail page.

## Validation

Flutter formatting, analysis and tests must be run locally and in CI before merging this branch.
