# Security hardening

The database exposes only the operations required by the Flutter client.

- Trade offers are mutated through `create_trade_offer` and `respond_to_trade_offer`.
- Direct `INSERT`, `UPDATE`, and `DELETE` privileges on `trade_offers` are revoked for `authenticated`.
- Profile access is limited to the authenticated owner through RLS and explicit grants.
- `SECURITY DEFINER` functions have an empty `search_path` and restricted EXECUTE privileges.
- Chat messages remain available through the existing Realtime publication.

The SQL assertions in `supabase/tests/security_privileges.test.sql` document the expected privilege boundary.
