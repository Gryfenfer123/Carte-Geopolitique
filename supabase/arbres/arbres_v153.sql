-- arbres_v153.sql — Nigeria (Oba du Bénin)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Oba du Bénin » (Nigeria) : 3 personnes seulement. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Page « Eweka dynasty » : Uwakhuahen et Ehenmihen sont fils d'Eweka I ; les dates dépendent de la chronologie d'Egharevba (naissance d'Eweka I vers 1171, couronnement vers 1200 ; l'historien Roese propose vers 1320). Les autres Oba (Ewuare, Esigie, Ozolua…) n'ont pas de parenté ni de date sur la page : non ajoutés. Dynastie traditionnelle, dates très incertaines.
-- À lancer UNE fois dans Supabase -> SQL Editor -> Run. Le script s'arrête sans rien écrire si une vérification échoue.
-- Ensuite, sur le site, ouvre chaque arbre créé et vérifie ; « Organiser par dates » remet l'ordre si tu déplaces des cartes.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  cat_id constant uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  top uuid;
  sec uuid;
  k int;
  ext uuid;
begin
  if exists (select 1 from public.genealogy_members where id = '602f9127-a1c2-5a91-a843-de8d038f792a') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Oba du Bénin » (NGA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'NGA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour NGA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Oba du Bénin';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('981de00c-edc0-5932-b492-69ac53d9552a', cat_id, 'country', 'NGA', top, 'Oba du Bénin', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '981de00c-edc0-5932-b492-69ac53d9552a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('470a5129-9f47-547a-b546-4f34353f17cd', 'country', 'NGA', 'genealogy', 'Oba du Bénin', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('602f9127-a1c2-5a91-a843-de8d038f792a', 'entry', '470a5129-9f47-547a-b546-4f34353f17cd', 'Eweka I', null, 1171, null, 'Premier Oba de la dynastie d''Edo (couronné vers 1200)', 'Oba du Bénin', 'Sources : https://en.wikipedia.org/wiki/Eweka_dynasty - naissance vers 1171 selon la chronologie d''Egharevba ; père traditionnel : Oranmiyan', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ad0d939a-231b-50dc-9190-8b192227aa35', 'entry', '470a5129-9f47-547a-b546-4f34353f17cd', 'Uwakhuahen', null, null, null, 'Oba du Bénin (vers 1230)', 'Oba du Bénin', 'Sources : https://en.wikipedia.org/wiki/Eweka_dynasty - fils aîné d''Eweka I', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1d30a1ae-1eb1-552c-b443-d544f8ec82fc', 'entry', '470a5129-9f47-547a-b546-4f34353f17cd', 'Ehenmihen', null, null, null, 'Oba du Bénin', 'Oba du Bénin', 'Sources : https://en.wikipedia.org/wiki/Eweka_dynasty - autre fils d''Eweka I ; succède à Uwakhuahen', 0, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('602f9127-a1c2-5a91-a843-de8d038f792a', 'ad0d939a-231b-50dc-9190-8b192227aa35', 'parent');
  perform pg_temp.rel('602f9127-a1c2-5a91-a843-de8d038f792a', '1d30a1ae-1eb1-552c-b443-d544f8ec82fc', 'parent');
  raise notice 'schema_v153 : % membres ajoutés.', 3;
end $$;
