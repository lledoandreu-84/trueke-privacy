# Security hardening

This block hardens trade offers and account-scoped state.

- Trade-offer creation is validated server-side and executed transactionally.
- Recipients can change only the offer status through the response RPC.
- Chat messages are included in the `supabase_realtime` publication.
- User-scoped Riverpod state is recreated when the authenticated user changes.
- Chat detail pages unsubscribe their realtime channel when disposed.
