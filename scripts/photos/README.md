# Récolte de portraits (v60)
- `recolte-wikipedia.js` : à exécuter dans le navigateur de Martin (origine du site, pour accéder à Supabase et à l'API
  Wikipédia). Il lit les membres sans photo, cherche la page Wikipédia (fr puis en), ne garde l'image que si le résumé cite
  l'année de naissance ou de mort. Résultat dans `window.__P`. Un tri a ensuite écarté blasons, sceaux, monnaies, cartes et
  homonymes évidents.
- `portraits-v60.txt` : les 209 portraits retenus (`id|lien`, `~` = début `https://upload.wikimedia.org/wikipedia/commons/`),
  d'où est tiré `supabase/schema_v60.sql`.
Pour une nouvelle vague : relancer le script, trier, puis écrire une migration `arbres_vN.sql` du même modèle que v60
(`update … where photo_url is null`, jamais d'écrasement).
