-- ============================================================
-- Atlas Géopolitique — frises_v5 (2026-11-12) : catégories de points PERTINENTES (nature de l'événement)
--
-- Demande de Martin (2026-11-12) : les catégories de points (Conflit, Dynastie, Religion, Institution politique, Crise...)
-- recoupaient les grandes catégories thématiques du site ; un point doit dire CE QU'IL EST concrètement (bataille ? traité ?
-- révolution ? mort d'un souverain ?...), chaque catégorie gardant sa couleur.
--
-- Nouvelle liste (11 natures d'événement, une couleur chacune) :
--   Guerre et bataille · Traité et accord · Révolte, révolution, coup d'État · Conquête et territoire ·
--   Naissance, avènement, mort · Fondation d'un État ou d'une institution · Loi, réforme, constitution ·
--   Élection et changement de régime · Religion, idées et culture · Science, technique et économie ·
--   Crise, catastrophe, épidémie
--
-- NON DESTRUCTIF : les catégories existantes sont RENOMMÉES (même identifiant, donc les points déjà classés gardent leur catégorie),
-- 2 catégories sont ajoutées. Aucune ligne supprimée. Au 2026-11-12 seuls 11 points de TEST utilisaient une catégorie.
--   Conflit -> Guerre et bataille · Traité -> Traité et accord · Crise -> Révolte, révolution, coup d'État ·
--   Territoire -> Conquête et territoire · Dynastie -> Naissance, avènement, mort ·
--   Institution politique -> Fondation d'un État ou d'une institution · Religion -> Religion, idées et culture ·
--   Économie et société -> Science, technique et économie · Relations avec le monde -> Crise, catastrophe, épidémie
--   + nouvelles : Loi, réforme, constitution · Élection et changement de régime
-- Les noms et couleurs restent modifiables ensuite depuis la frise (bouton « Catégories »).
--
-- Prérequis : schema_v31 (table timeline_categories). Idempotent : une 2e exécution ne change plus rien.
-- Exécuté par Claude via le connecteur Supabase (décision de Martin, 2026-11-02).
-- Retour arrière : renommer à la main depuis « Catégories » (aucune donnée perdue).
-- ============================================================

do $$
declare
  r record;
begin
  -- 1. Renommages (par ancien nom ; ignoré si le nouveau nom existe déjà)
  for r in
    select * from (values
      ('Conflit',                'Guerre et bataille',                         '#c0392b', 0),
      ('Traité',                 'Traité et accord',                           '#2980b9', 1),
      ('Crise',                  'Révolte, révolution, coup d''État',          '#e67e22', 2),
      ('Territoire',             'Conquête et territoire',                     '#a04000', 3),
      ('Dynastie',               'Naissance, avènement, mort',                 '#8e44ad', 4),
      ('Institution politique',  'Fondation d''un État ou d''une institution', '#16a085', 5),
      ('Religion',               'Religion, idées et culture',                 '#d4ac0d', 8),
      ('Économie et société',    'Science, technique et économie',             '#27ae60', 9),
      ('Relations avec le monde','Crise, catastrophe, épidémie',               '#5d6d7e', 10)
    ) as t(old_name, new_name, color, pos)
  loop
    if exists (select 1 from public.timeline_categories where lower(name) = lower(r.old_name))
       and not exists (select 1 from public.timeline_categories where lower(name) = lower(r.new_name)) then
      update public.timeline_categories set name = r.new_name, color = r.color, position = r.pos
      where lower(name) = lower(r.old_name);
    end if;
  end loop;

  -- 2. Catégories ajoutées
  insert into public.timeline_categories (name, color, position) values
    ('Loi, réforme, constitution',       '#7d8c2f', 6),
    ('Élection et changement de régime', '#c0568c', 7)
  on conflict do nothing;

  -- 3. Ordre et couleurs de la liste finale (au cas où une catégorie existait déjà sous son nouveau nom)
  update public.timeline_categories c set color = t.color, position = t.pos
  from (values
    ('Guerre et bataille', '#c0392b', 0), ('Traité et accord', '#2980b9', 1), ('Révolte, révolution, coup d''État', '#e67e22', 2),
    ('Conquête et territoire', '#a04000', 3), ('Naissance, avènement, mort', '#8e44ad', 4),
    ('Fondation d''un État ou d''une institution', '#16a085', 5), ('Loi, réforme, constitution', '#7d8c2f', 6),
    ('Élection et changement de régime', '#c0568c', 7), ('Religion, idées et culture', '#d4ac0d', 8),
    ('Science, technique et économie', '#27ae60', 9), ('Crise, catastrophe, épidémie', '#5d6d7e', 10)
  ) as t(name, color, pos)
  where lower(c.name) = lower(t.name);
end $$;
