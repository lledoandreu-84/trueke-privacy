-- 165.42-E: remove broad table privileges that bypass row-level policies.
-- Re-grant only operations required by the current client flows.

REVOKE ALL PRIVILEGES ON TABLE public.products FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.products TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.products TO authenticated;

REVOKE ALL PRIVILEGES ON TABLE public.profiles FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;

REVOKE ALL PRIVILEGES ON TABLE public.trade_offers FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.trade_offers TO authenticated;

REVOKE ALL PRIVILEGES ON TABLE public.favorites FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, DELETE ON TABLE public.favorites TO authenticated;
DROP POLICY IF EXISTS "Permitir lectura publica de favoritos" ON public.favorites;

REVOKE ALL PRIVILEGES ON TABLE public.user_reviews FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.user_reviews TO anon, authenticated;
-- Review INSERT remains disabled until completed-trade validation and the reputation trigger are repaired.

-- Rollback requires restoring the prior grants and favorite policy from the backup.
