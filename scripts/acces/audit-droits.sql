-- Audit des droits (LECTURE SEULE : ne modifie rien). À coller dans Supabase -> SQL Editor -> Run.
-- Chaque bloc donne un tableau : copie-colle les résultats (ou une capture d'écran) dans la conversation.

-- 1) Quelles tables ont la sécurité par lignes (RLS) activée ?
select c.relname as table, c.relrowsecurity as rls_active
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
order by c.relname;

-- 2) Toutes les règles d'accès (qui peut lire / écrire quoi)
select tablename as table, policyname as regle, cmd as action, roles, qual as condition_lecture, with_check as condition_ecriture
from pg_policies where schemaname in ('public','storage')
order by tablename, cmd, policyname;

-- 3) Les comptes existants et leur rôle (sans e-mail)
select role, count(*) as nombre from public.profiles group by role order by role;

-- 4) La fonction qui décide qui est administrateur
select pg_get_functiondef('public.is_admin()'::regprocedure);
