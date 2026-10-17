-- Subdivisions administratives par pays (demande de Martin, 2026-10-16) :
-- "Est-ce que c'est possible de rajouter des subdivisions dans les pays en
-- fonction du niveau de zoom ? [...] la possibilité d'afficher la
-- subdivision depuis la fiche pays (activé ou non) et pour les pays qui en
-- ont plusieurs, la possibilité de choisir (ex en france, région,
-- département..)"
--
-- show_subdivisions : bascule par pays, cochée dans la fiche pays
-- (renderFicheLinksWidget, src/links.ts) — n'affiche les limites que si
-- le pays a aussi des données de subdivision disponibles côté front
-- (voir SUBDIVISION_AVAILABLE_TYPES dans src/links.ts).
-- subdivision_type : pour un pays qui propose plusieurs découpages
-- (ex. FRA: "region" ou "departement"), le type actuellement choisi.
-- NULL = type par défaut/unique disponible pour ce pays.
alter table public.countries
  add column if not exists show_subdivisions boolean not null default false,
  add column if not exists subdivision_type text;

comment on column public.countries.show_subdivisions is
  'Afficher les subdivisions administratives de ce pays sur la carte à partir d''un certain niveau de zoom (bascule dans la fiche pays).';
comment on column public.countries.subdivision_type is
  'Type de subdivision choisi pour ce pays quand show_subdivisions=true et que plusieurs découpages existent (ex. FRA: "region"/"departement"). NULL = type par défaut/unique disponible.';
