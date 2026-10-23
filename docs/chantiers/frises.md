# Chantier « frises » — journal

Spécification de référence : [`../specs/frises-chronologiques.md`](../specs/frises-chronologiques.md).

- **Fait** : modèle (périodes = sous-catégories, bornes partagées, trous de transition, sous-frises),
  interface (glisser/zoom, couleurs, légende, recherche, durées, export PDF/image, fiches multi-pays) — migrations
  `schema_v27` à `schema_v31`.
- **Reste** (d'après la spec §7bis et §8) : rendu en tiges/branches colorées pour les événements à la même date,
  placements multiples, remontée d'événements sur la frise parente, placement automatique des fiches créées à la main.
- Prochaine migration de ce chantier : **frises_v1** (`supabase/frises/frises_v1.sql`).
