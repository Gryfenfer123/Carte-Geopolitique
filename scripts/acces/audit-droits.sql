-- Audit des droits (LECTURE SEULE : ne modifie rien). À coller dans Supabase -> SQL Editor -> Run.
-- Une seule requête, un seul résultat : copie la cellule « audit » et colle-la dans la conversation.
-- (L'éditeur de Supabase n'affiche que le résultat de la DERNIÈRE requête : c'est pourquoi tout est regroupé ici.)

select json_build_object(
  'tables_rls', (
    select json_agg(json_build_object('table', c.relname, 'rls', c.relrowsecurity) order by c.relname)
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r'
  ),
  'regles', (
    select json_agg(json_build_object('table', tablename, 'regle', policyname, 'action', cmd, 'roles', roles,
                                      'lecture', qual, 'ecriture', with_check) order by tablename, cmd, policyname)
    from pg_policies where schemaname in ('public', 'storage')
  ),
  'comptes_par_role', (
    select json_agg(json_build_object('role', role, 'nombre', n))
    from (select role, count(*) as n from public.profiles group by role) t
  )
) as audit;
