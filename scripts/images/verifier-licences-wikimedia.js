// Vérifie la licence de chaque image Wikimedia utilisée par les arbres (genealogy_members.photo_url).
// À exécuter dans le navigateur de Claude/Martin sur une page de l'origine https://<projet>.supabase.co/rest/v1/
// (pas depuis commons.wikimedia.org : sa politique de sécurité bloque Supabase). Clé « publishable » = publique.
// Résultat dans window.WRES : { nomDeFichier: { licence, artiste, credit, nonfree, restr, url } }.
// Utilisé le 2026-11-01 : 302 fichiers Commons, aucun non libre. Voir docs/sources/images.md.
(async () => {
  const K = "sb_publishable_9DsmJbmN8xY0puUJ_Uek7g_dWfVqvdL", B = "https://jitdrirhmvqlhrprdlhg.supabase.co/rest/v1/";
  let rows = [];
  for (let o = 0; ; o += 1000) {
    const j = await (await fetch(B + `genealogy_members?select=id,name,photo_url&photo_url=like.*wikimedia.org*&order=id&offset=${o}&limit=1000`, { headers: { apikey: K } })).json();
    rows = rows.concat(j); if (j.length < 1000) break;
  }
  const file = (u) => { const m = u.match(/wikipedia\/(commons|en)\/(?:thumb\/)?[0-9a-f]\/[0-9a-f]{2}\/([^\/]+)/); return m && { proj: m[1], file: decodeURIComponent(m[2]) }; };
  const files = [...new Set(rows.map((r) => file(r.photo_url)).filter((f) => f && f.proj === "commons").map((f) => f.file))];
  const strip = (h) => (h || "").replace(/<[^>]*>/g, "").replace(/&amp;/g, "&").replace(/\s+/g, " ").trim();
  const res = {};
  for (let i = 0; i < files.length; i += 40) {
    const titles = files.slice(i, i + 40).map((f) => "File:" + f).join("|");
    const u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&origin=*&prop=imageinfo&iiprop=extmetadata|url&iiextmetadatafilter=LicenseShortName|Artist|Credit|NonFree|Restrictions|AttributionRequired&titles=" + encodeURIComponent(titles);
    const j = await (await fetch(u)).json(); const norm = {}; (j.query.normalized || []).forEach((n) => (norm[n.to] = n.from));
    for (const p of Object.values(j.query.pages)) {
      const em = p.imageinfo?.[0]?.extmetadata; const orig = (norm[p.title] || p.title).replace(/^File:/, "");
      res[orig] = em ? { licence: em.LicenseShortName?.value, artiste: strip(em.Artist?.value).slice(0, 120), credit: strip(em.Credit?.value).slice(0, 100), nonfree: em.NonFree?.value, restr: em.Restrictions?.value, url: p.imageinfo[0].descriptionurl } : { manque: true };
    }
  }
  window.WRES = res;
})();
