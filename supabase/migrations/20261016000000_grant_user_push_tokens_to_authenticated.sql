-- 165.42-C: limit push-token access to authenticated owners via RLS.
-- Keep RLS policies as the row-level security boundary.
REVOKE ALL PRIVILEGES ON TABLE public.user_push_tokens FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_push_tokens TO authenticated;
-- Rollback: REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_push_tokens FROM authenticated;
