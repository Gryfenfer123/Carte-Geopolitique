-- arbres_v91.sql — Empire byzantin — dynasties macédonienne, Doukas, Comnène, Ange, Laskaris et Paléologue (867-1453)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Empire byzantin » (aucun n'existait). Rien n'est supprimé.
-- Source : Wikipédia en anglais, « List of Byzantine emperors » (noms, naissances et liens imprimés) ; morts : connues par ailleurs, la page ne les donne pas. Naissances non imprimées = vides.
-- Les successions par adoption, gendre ou neveu sont reliées par un lien « famille » (pas par une filiation). Début : Basile Ier (867) ; la période avant 867 n'est pas faite.
-- Non fait : épouses autres que Zoé/Théodora et leurs maris, co-empereurs qui n'ont jamais régné seuls, princes non empereurs.
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
  if exists (select 1 from public.genealogy_members where id = 'b0e457c7-62f1-51b4-b04a-3977ebf0de45') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Empire byzantin » (GRC)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GRC' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GRC : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Empire byzantin';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('ac83518a-8089-563a-81aa-aa8d5aa640cf', cat_id, 'country', 'GRC', top, 'Empire byzantin', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'ac83518a-8089-563a-81aa-aa8d5aa640cf';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('b3fbbb92-926c-5829-b55f-f9813604d018', 'country', 'GRC', 'genealogy', 'Empire byzantin', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b0e457c7-62f1-51b4-b04a-3977ebf0de45', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Basile Ier', null, 811, 886, 'Empereur byzantin', 'Macédonienne', 975, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf02116b-7ce5-5bfd-b61b-490fa22b3b37', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Léon VI', null, 866, 912, 'Empereur byzantin', 'Macédonienne', 1225, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('521b8ec7-ca53-5a39-bbfe-e176d608c68d', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexandre', null, 870, 913, 'Empereur byzantin', 'Macédonienne', 725, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ad5778d8-6593-580a-ab5f-e14ff0e58e51', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Constantin VII Porphyrogénète', null, 905, 959, 'Empereur byzantin', 'Macédonienne', 1225, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6247fa62-f88f-5ce1-a548-32ff61245022', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Romain Ier Lécapène', null, null, 948, 'Empereur byzantin', 'Macédonienne', 19440, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3951bb06-7e64-55dd-86f9-e7c8cba03498', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Romain II', null, 938, 963, 'Empereur byzantin', 'Macédonienne', 1225, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a6d5f4da-e59d-520e-ae27-590f3288759c', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Nicéphore II Phocas', null, 912, 969, 'Empereur byzantin', 'Macédonienne', 10440, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('96ffef2c-2a32-5ca0-bed1-0d69d4c00ed0', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean Ier Tzimiskès', null, 925, 976, 'Empereur byzantin', 'Macédonienne', 11440, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f9fc3660-fdb2-5187-8543-54a9662cdc06', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Basile II', null, 958, 1025, 'Empereur byzantin', 'Macédonienne', 975, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('df0f37d8-35fc-5afa-8ec5-e2245d798950', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Constantin VIII', null, 960, 1028, 'Empereur byzantin', 'Macédonienne', 1475, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8bd16c09-2efa-5e75-a7b0-c90340f74af1', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Romain III Argyre', null, 968, 1034, 'Empereur byzantin', 'Macédonienne', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5da4451b-ff41-5de0-af47-9cbc2b37d01b', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel IV le Paphlagonien', null, 1010, 1041, 'Empereur byzantin', 'Macédonienne', 490, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('729c38c4-bffc-5fe7-b06f-43103979b5b0', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel V Calaphate', null, 1015, 1042, 'Empereur byzantin', 'Macédonienne', 14440, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6c5be58b-788e-5a91-ae4c-a6498c1f659f', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Constantin IX Monomaque', null, 1000, 1055, 'Empereur byzantin', 'Macédonienne', 1470, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dfbf5c5a-cbba-5d9d-b6aa-3c33558cab91', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel VI Stratiotikos', null, null, null, 'Empereur byzantin', 'Macédonienne', 20440, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3d896278-26b6-5ce0-bf88-2c3da8370004', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Isaac Ier Comnène', null, 1005, 1061, 'Empereur byzantin', 'Comnène', 13440, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cfff8cbd-4f2e-58f7-b2ae-e3157a4507ee', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Constantin X Doukas', null, 1006, 1067, 'Empereur byzantin', 'Doukas', 6460, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('56719fce-5494-5e17-90b6-1a0f94628ace', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Romain IV Diogène', null, 1032, 1072, 'Empereur byzantin', 'Doukas', 7440, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4d8ea4ff-49ba-5c46-bd0b-8c11b8864001', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel VII Doukas', null, 1050, 1090, 'Empereur byzantin', 'Doukas', 6460, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2ce9af56-61e7-5ce8-9505-b9bb0f84b2d8', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Nicéphore III Botaniatès', null, 1001, 1081, 'Empereur byzantin', 'Doukas', 12440, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('00d742cb-902e-51ee-835a-8610daf5d072', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexis Ier Comnène', null, 1056, 1118, 'Empereur byzantin', 'Comnène', 8440, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6f0e73ad-ed84-532d-bc04-22a37578e3e4', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean II Comnène', null, 1087, 1143, 'Empereur byzantin', 'Comnène', 8440, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f7db7760-75bf-5691-907d-7ef999604057', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Manuel Ier Comnène', null, 1118, 1180, 'Empereur byzantin', 'Comnène', 8440, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6d9dc4fb-a394-5905-b0cd-8c81623ee131', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexis II Comnène', null, 1169, 1183, 'Empereur byzantin', 'Comnène', 8440, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7f04927c-98f4-555d-9535-7a8192954864', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Andronic Ier Comnène', null, 1118, 1185, 'Empereur byzantin', 'Comnène', 15440, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4f23604e-039b-58b3-9a3e-3efc5c32383f', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Isaac II Ange', null, 1156, 1204, 'Empereur byzantin', 'Ange', 9440, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('60c5b18e-1736-5971-bef3-594a1c6ed417', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexis III Ange', null, 1153, 1211, 'Empereur byzantin', 'Ange', 17440, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0154c256-4162-5560-94af-a58cc5aa2497', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexis IV Ange', null, 1182, 1204, 'Empereur byzantin', 'Ange', 9440, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aee27906-4e76-52de-99c2-f9c1365ec974', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Alexis V Doukas', null, 1140, 1204, 'Empereur byzantin', 'Ange', 16440, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('67e86759-af8a-5284-999c-12c4b6ddb483', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Théodore Ier Lascaris', null, 1174, 1221, 'Empereur byzantin', 'Laskaris', 4970, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ac141afe-60db-5794-893c-5d5d9459dbf7', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean III Vatatzès', null, 1192, 1254, 'Empereur byzantin', 'Laskaris', 5460, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7d9a38fd-0a33-5a8c-a42d-2b2028cd4d5d', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Théodore II Lascaris', null, 1221, 1258, 'Empereur byzantin', 'Laskaris', 5460, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a5156f30-e68a-5039-a18d-89ff4fdd0014', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean IV Lascaris', null, 1250, 1305, 'Empereur byzantin', 'Laskaris', 5460, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5a494b4a-080d-52fa-85fa-a73176c8f719', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel VIII Paléologue', null, 1223, 1282, 'Empereur byzantin', 'Paléologue', 3324, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('303f3172-d740-5b59-a8a7-dd4d1ba27d9d', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Andronic II Paléologue', null, 1259, 1332, 'Empereur byzantin', 'Paléologue', 3324, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c1acb5ac-f7e7-5c19-af96-fdf69eacf153', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Michel IX Paléologue', null, 1277, 1320, 'Empereur byzantin', 'Paléologue', 3324, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8513a0be-2e0d-51ca-ad25-dafde7c2f0a7', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Andronic III Paléologue', null, 1297, 1341, 'Empereur byzantin', 'Paléologue', 3324, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('72e522c8-5c09-584c-adc9-b677572b160c', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean V Paléologue', null, 1332, 1391, 'Empereur byzantin', 'Paléologue', 3324, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7bbef145-6aa5-509e-b832-e68a71e0e91f', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean VI Cantacuzène', null, 1292, 1383, 'Empereur byzantin', 'Cantacuzène', 18440, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('343ffe50-a68e-5078-91b5-d42db35680ca', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Andronic IV Paléologue', null, 1348, 1385, 'Empereur byzantin', 'Paléologue', 2970, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4075d6d2-4bf1-59de-ae67-7275d5fb0256', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean VII Paléologue', null, 1370, 1408, 'Empereur byzantin', 'Paléologue', 2970, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('704db582-5e45-5c09-87ba-647a7cbe5382', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Manuel II Paléologue', null, 1350, 1425, 'Empereur byzantin', 'Paléologue', 3572, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0fc88c3e-e8d4-5659-8047-6eb8b60fcdb8', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Jean VIII Paléologue', null, 1392, 1448, 'Empereur byzantin', 'Paléologue', 3470, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('961697f9-2e55-54fe-b777-a20da31ce0d0', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Constantin XI Paléologue', null, 1405, 1453, 'Empereur byzantin', 'Paléologue', 3970, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6725da33-25d5-5f02-8f09-53b36aceb19d', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Zoé Porphyrogénète', null, 978, 1050, 'Impératrice byzantine', 'Macédonienne', 980, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a501d1db-b999-524b-8eca-803689f66a20', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Théodora Porphyrogénète', null, 984, 1056, 'Impératrice byzantine', 'Macédonienne', 1970, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('406e6488-f945-5af5-ae86-dce7d8dcad25', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Eudocie Macrembolitissa', null, 1021, 1096, 'Impératrice byzantine, régente', 'Doukas', 6950, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('17a586e0-c869-5249-8cf5-d81b0e21d0b4', 'entry', 'b3fbbb92-926c-5829-b55f-f9813604d018', 'Irène Lascaris', null, 1196, 1239, 'Impératrice de Nicée, épouse de Jean III', 'Laskaris', 4970, 7680, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('b0e457c7-62f1-51b4-b04a-3977ebf0de45', 'bf02116b-7ce5-5bfd-b61b-490fa22b3b37', 'parent');
  perform pg_temp.rel('b0e457c7-62f1-51b4-b04a-3977ebf0de45', '521b8ec7-ca53-5a39-bbfe-e176d608c68d', 'parent');
  perform pg_temp.rel('bf02116b-7ce5-5bfd-b61b-490fa22b3b37', 'ad5778d8-6593-580a-ab5f-e14ff0e58e51', 'parent');
  perform pg_temp.rel('ad5778d8-6593-580a-ab5f-e14ff0e58e51', '3951bb06-7e64-55dd-86f9-e7c8cba03498', 'parent');
  perform pg_temp.rel('3951bb06-7e64-55dd-86f9-e7c8cba03498', 'f9fc3660-fdb2-5187-8543-54a9662cdc06', 'parent');
  perform pg_temp.rel('3951bb06-7e64-55dd-86f9-e7c8cba03498', 'df0f37d8-35fc-5afa-8ec5-e2245d798950', 'parent');
  perform pg_temp.rel('df0f37d8-35fc-5afa-8ec5-e2245d798950', '6725da33-25d5-5f02-8f09-53b36aceb19d', 'parent');
  perform pg_temp.rel('df0f37d8-35fc-5afa-8ec5-e2245d798950', 'a501d1db-b999-524b-8eca-803689f66a20', 'parent');
  perform pg_temp.rel('cfff8cbd-4f2e-58f7-b2ae-e3157a4507ee', '4d8ea4ff-49ba-5c46-bd0b-8c11b8864001', 'parent');
  perform pg_temp.rel('00d742cb-902e-51ee-835a-8610daf5d072', '6f0e73ad-ed84-532d-bc04-22a37578e3e4', 'parent');
  perform pg_temp.rel('6f0e73ad-ed84-532d-bc04-22a37578e3e4', 'f7db7760-75bf-5691-907d-7ef999604057', 'parent');
  perform pg_temp.rel('f7db7760-75bf-5691-907d-7ef999604057', '6d9dc4fb-a394-5905-b0cd-8c81623ee131', 'parent');
  perform pg_temp.rel('4f23604e-039b-58b3-9a3e-3efc5c32383f', '0154c256-4162-5560-94af-a58cc5aa2497', 'parent');
  perform pg_temp.rel('67e86759-af8a-5284-999c-12c4b6ddb483', '17a586e0-c869-5249-8cf5-d81b0e21d0b4', 'parent');
  perform pg_temp.rel('ac141afe-60db-5794-893c-5d5d9459dbf7', '7d9a38fd-0a33-5a8c-a42d-2b2028cd4d5d', 'parent');
  perform pg_temp.rel('7d9a38fd-0a33-5a8c-a42d-2b2028cd4d5d', 'a5156f30-e68a-5039-a18d-89ff4fdd0014', 'parent');
  perform pg_temp.rel('5a494b4a-080d-52fa-85fa-a73176c8f719', '303f3172-d740-5b59-a8a7-dd4d1ba27d9d', 'parent');
  perform pg_temp.rel('303f3172-d740-5b59-a8a7-dd4d1ba27d9d', 'c1acb5ac-f7e7-5c19-af96-fdf69eacf153', 'parent');
  perform pg_temp.rel('c1acb5ac-f7e7-5c19-af96-fdf69eacf153', '8513a0be-2e0d-51ca-ad25-dafde7c2f0a7', 'parent');
  perform pg_temp.rel('8513a0be-2e0d-51ca-ad25-dafde7c2f0a7', '72e522c8-5c09-584c-adc9-b677572b160c', 'parent');
  perform pg_temp.rel('72e522c8-5c09-584c-adc9-b677572b160c', '343ffe50-a68e-5078-91b5-d42db35680ca', 'parent');
  perform pg_temp.rel('72e522c8-5c09-584c-adc9-b677572b160c', '704db582-5e45-5c09-87ba-647a7cbe5382', 'parent');
  perform pg_temp.rel('343ffe50-a68e-5078-91b5-d42db35680ca', '4075d6d2-4bf1-59de-ae67-7275d5fb0256', 'parent');
  perform pg_temp.rel('704db582-5e45-5c09-87ba-647a7cbe5382', '0fc88c3e-e8d4-5659-8047-6eb8b60fcdb8', 'parent');
  perform pg_temp.rel('704db582-5e45-5c09-87ba-647a7cbe5382', '961697f9-2e55-54fe-b777-a20da31ce0d0', 'parent');
  perform pg_temp.rel('6725da33-25d5-5f02-8f09-53b36aceb19d', '8bd16c09-2efa-5e75-a7b0-c90340f74af1', 'spouse');
  perform pg_temp.rel('6725da33-25d5-5f02-8f09-53b36aceb19d', '5da4451b-ff41-5de0-af47-9cbc2b37d01b', 'spouse');
  perform pg_temp.rel('6725da33-25d5-5f02-8f09-53b36aceb19d', '6c5be58b-788e-5a91-ae4c-a6498c1f659f', 'spouse');
  perform pg_temp.rel('cfff8cbd-4f2e-58f7-b2ae-e3157a4507ee', '406e6488-f945-5af5-ae86-dce7d8dcad25', 'spouse');
  perform pg_temp.rel('406e6488-f945-5af5-ae86-dce7d8dcad25', '56719fce-5494-5e17-90b6-1a0f94628ace', 'spouse');
  perform pg_temp.rel('ac141afe-60db-5794-893c-5d5d9459dbf7', '17a586e0-c869-5249-8cf5-d81b0e21d0b4', 'spouse');
  perform pg_temp.rel('a6d5f4da-e59d-520e-ae27-590f3288759c', '96ffef2c-2a32-5ca0-bed1-0d69d4c00ed0', 'family');
  perform pg_temp.rel('5da4451b-ff41-5de0-af47-9cbc2b37d01b', '729c38c4-bffc-5fe7-b06f-43103979b5b0', 'family');
  perform pg_temp.rel('3d896278-26b6-5ce0-bf88-2c3da8370004', '00d742cb-902e-51ee-835a-8610daf5d072', 'family');
  perform pg_temp.rel('6f0e73ad-ed84-532d-bc04-22a37578e3e4', '7f04927c-98f4-555d-9535-7a8192954864', 'family');
  perform pg_temp.rel('4f23604e-039b-58b3-9a3e-3efc5c32383f', '60c5b18e-1736-5971-bef3-594a1c6ed417', 'family');
  perform pg_temp.rel('60c5b18e-1736-5971-bef3-594a1c6ed417', 'aee27906-4e76-52de-99c2-f9c1365ec974', 'family');
  perform pg_temp.rel('60c5b18e-1736-5971-bef3-594a1c6ed417', '67e86759-af8a-5284-999c-12c4b6ddb483', 'family');
  perform pg_temp.rel('60c5b18e-1736-5971-bef3-594a1c6ed417', '5a494b4a-080d-52fa-85fa-a73176c8f719', 'family');
  perform pg_temp.rel('a501d1db-b999-524b-8eca-803689f66a20', 'dfbf5c5a-cbba-5d9d-b6aa-3c33558cab91', 'family');
  perform pg_temp.rel('3d896278-26b6-5ce0-bf88-2c3da8370004', 'cfff8cbd-4f2e-58f7-b2ae-e3157a4507ee', 'family');
  perform pg_temp.rel('6247fa62-f88f-5ce1-a548-32ff61245022', 'ad5778d8-6593-580a-ab5f-e14ff0e58e51', 'family');
  perform pg_temp.rel('4d8ea4ff-49ba-5c46-bd0b-8c11b8864001', '2ce9af56-61e7-5ce8-9505-b9bb0f84b2d8', 'family');
  perform pg_temp.rel('a6d5f4da-e59d-520e-ae27-590f3288759c', '6725da33-25d5-5f02-8f09-53b36aceb19d', 'family');
  perform pg_temp.rel('72e522c8-5c09-584c-adc9-b677572b160c', '7bbef145-6aa5-509e-b832-e68a71e0e91f', 'family');
  raise notice 'schema_v91 : % membres ajoutés.', 48;
end $$;
