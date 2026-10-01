// ---------------------------------------------------------------------------
// Noms français des pays + drapeaux SVG — porté de labelFor()/flagSvgSpan()/
// isoA2ForSlug()/FLAG_OVERRIDE_ISO2 dans l'artifact source
// (realistic_final.html, ~lignes 3174-3263). FR_NAMES.json et
// FLAG_SVG_ISO2.json sont les données SOURCE extraites à l'identique de
// l'artifact (mêmes SVG vectoriels "flag-icons", licence MIT).
// ---------------------------------------------------------------------------

let frNames: Record<string, string> = {};
let flagSvgIso2: Record<string, string> = {};
let ready: Promise<void> | null = null;

// Corrections/complétions pour des cas où Natural Earth ne porte pas un
// ISO_A2 exploitable (placeholder "-99" ou absent) — identique à
// FLAG_OVERRIDE_ISO2 dans l'artifact.
const FLAG_OVERRIDE_ISO2: Record<string, string> = {
  kosovo: "XK",
  "united-states-of-america": "US",
  "united-kingdom": "GB",
  norway: "NO",
  "new-zealand": "NZ",
  netherlands: "NL",
  israel: "IL",
  georgia: "GE",
  france: "FR",
  finland: "FI",
  denmark: "DK",
  china: "CN",
  australia: "AU",
};

export function loadCountryNameData(): Promise<void> {
  if (ready) return ready;
  ready = Promise.all([
    fetch(import.meta.env.BASE_URL + "data/raw/FR_NAMES.json").then((r) => r.json()),
    fetch(import.meta.env.BASE_URL + "data/raw/FLAG_SVG_ISO2.json").then((r) => r.json()),
  ]).then(([names, flags]) => {
    frNames = names;
    flagSvgIso2 = flags;
  });
  return ready;
}

// name = la valeur NAME de la feature (anglais, Natural Earth) ; retombe sur
// ce nom si aucune traduction française n'est connue — identique à labelFor().
export function frenchCountryName(name: string): string {
  return frNames[name] || name;
}

function isoA2ForSlugFromProps(slug: string, iso2: string | undefined | null): string {
  if (FLAG_OVERRIDE_ISO2[slug]) return FLAG_OVERRIDE_ISO2[slug];
  return iso2 && iso2 !== "-99" ? iso2 : "";
}

let flagIdSeq = 0;
// Construit un <span> autonome contenant le SVG du drapeau, avec des
// identifiants internes rendus uniques à chaque appel (un même drapeau peut
// apparaître simultanément à plusieurs endroits du DOM). Retourne null si
// aucun drapeau n'est disponible.
export function flagSvgSpan(slug: string, iso2: string | undefined | null): HTMLSpanElement | null {
  const iso = isoA2ForSlugFromProps(slug, iso2);
  const raw = iso && flagSvgIso2[iso];
  if (!raw) return null;
  const uid = "fi" + flagIdSeq++;
  const svgHtml = raw
    .replace(/id="([^"]+)"/g, (_m: string, id: string) => 'id="' + id + "-" + uid + '"')
    .replace(/url\(#([^)]+)\)/g, (_m: string, id: string) => "url(#" + id + "-" + uid + ")")
    .replace(/href="#([^"]+)"/g, (_m: string, id: string) => 'href="#' + id + "-" + uid + '"');
  const span = document.createElement("span");
  span.className = "flag-ico";
  span.setAttribute("aria-hidden", "true");
  span.innerHTML = svgHtml;
  return span;
}
