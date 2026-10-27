// ---------------------------------------------------------------------------
// Carte historique « à la GeAcron » — demande de Martin, 2026-10-06 : « un
// bouton en bas qui fait basculer en vue historique et qui permet ensuite avec
// un curseur d'afficher l'époque souhaitée ».
//
// HISTORIQUE DE CE FICHIER (pourquoi il est écrit ainsi) :
//  - v1 (2026-10-06) : OpenHistoricalMap en tuiles vectorielles — jugé « incomplet niveau
//    frontière » par Martin.
//  - v2 (2026-10-06) : historical-basemaps (54 années fixes, GPL-3.0), validé « en version
//    test » — pas de continuité, pas d'identifiant d'entité, donc aucun lien possible avec
//    les dynasties et les arbres généalogiques.
//  - v3 (2026-10-23, ce fichier) : Cliopatria (Seshat Global History Databank, CC BY 4.0).
//    Demande de Martin : « avoir l'évolution année après année de l'ensemble de la carte du
//    monde, de l'Europe, de tout ça » et, à terme, voir à la tête de quel empire était un
//    membre d'un arbre généalogique. Chaque entité a ici des dates et un identifiant Wikidata,
//    ce qui rend ce lien possible. Les données sont préparées par
//    scripts/historique/preparer_cliopatria.py ; la logique pure est dans historiqueModel.ts,
//    le chargement dans historiqueData.ts.
//
// Page plein écran avec sa propre carte Leaflet, indépendante de la carte principale (choix
// maintenu depuis la refonte du 2026-10-06 : la couche sur la carte principale entrait en
// conflit avec l'interactivité des pays).
//
// Résolution réelle de la source : un tracé vaut pour une PÉRIODE (durée médiane ≈ 8 ans, de 1
// à plus de 900 ans). Le curseur avance bien année par année, mais la carte ne change que
// lorsqu'une entité change de tracé.
// ---------------------------------------------------------------------------

import L from "leaflet";
import "./historique.css";
import { assurerTraces, chargerIndex, chargerNomsFr, traceChargee } from "./historiqueData";
import {
  ANNEE_MAX,
  ANNEE_MIN,
  bornerAnnee,
  couleurDuGroupe,
  decoderTrace,
  estTraduction,
  formatAnnee,
  formatPeriode,
  formatExistence,
  periodeEntite,
  groupeDeLigne,
  lienWikidata,
  lienWikipedia,
  lignesALAnnee,
  nomAffiche,
  nomDeLigne,
} from "./historiqueModel";
import type { HistoriqueIndex, Ligne, NomsFr, TraceDecodee } from "./historiqueModel";

const ANNEE_DE_DEPART = 1500;
const REGIONS: { nom: string; bornes: L.LatLngBoundsLiteral }[] = [
  { nom: "Monde", bornes: [[-58, -170], [78, 180]] },
  { nom: "Europe", bornes: [[34, -14], [62, 45]] },
  { nom: "Méditerranée et Proche-Orient", bornes: [[10, -12], [48, 70]] },
  { nom: "Afrique", bornes: [[-36, -20], [38, 55]] },
  { nom: "Asie", bornes: [[-10, 55], [58, 150]] },
  { nom: "Amériques", bornes: [[-56, -135], [72, -30]] },
];
const VITESSES = [1, 5, 10, 25, 50, 100]; // années par seconde pendant la lecture
const STYLE_NORMAL = { weight: 1, fillOpacity: 0.55, opacity: 0.9 };
const STYLE_SURVOL = { weight: 2.2, fillOpacity: 0.78, opacity: 1 };
const DELAI_CURSEUR_MS = 120; // on attend que le curseur se pose avant de charger des fichiers
const MAX_TRACES_EN_MEMOIRE = 4000;

type Visible = { ligne: Ligne; nom: string; groupe: string; groupeAffiche: string; decode: TraceDecodee; calque: L.Polygon };

export function initHistoricalMapSystem() {
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  const racine = document.createElement("div");
  racine.innerHTML = `
    <div id="historical-toggle" class="panel">
      <button id="historical-toggle-btn" title="Vue historique" aria-label="Vue historique"><svg class="icon-svg" style="width:17px;height:17px;" viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/></svg></button>
    </div>
    <div id="historical-view">
      <div id="historical-topbar">
        <h2 id="historical-title">Vue historique</h2>
        <div id="historical-toolbar">
          <div class="historique-rangee">
            <input type="range" id="historical-slider" min="${ANNEE_MIN}" max="${ANNEE_MAX}" value="${ANNEE_DE_DEPART}" step="1" aria-label="Année">
            <span id="historical-slider-year"></span>
          </div>
          <div class="historique-rangee historique-commandes">
            <span class="historique-groupe">
              ${[-100, -10, -1].map((p) => `<button type="button" data-pas="${p}" title="Reculer de ${-p} an${-p > 1 ? "s" : ""}">−${-p}</button>`).join("")}
              <label class="historique-annee">Année <input type="number" id="historical-year-input" min="${ANNEE_MIN}" max="${ANNEE_MAX}" step="1" title="Négatif = avant J.-C. (ex. −500)"></label>
              ${[1, 10, 100].map((p) => `<button type="button" data-pas="${p}" title="Avancer de ${p} an${p > 1 ? "s" : ""}">+${p}</button>`).join("")}
            </span>
            <span class="historique-groupe">
              <button type="button" id="historical-play" title="Faire défiler les années">▶ Lecture</button>
              <select id="historical-speed" aria-label="Vitesse de lecture">${VITESSES.map((v) => `<option value="${v}"${v === 10 ? " selected" : ""}>${v} an${v > 1 ? "s" : ""}/s</option>`).join("")}</select>
              <select id="historical-region" aria-label="Zone affichée">${REGIONS.map((r, i) => `<option value="${i}">${r.nom}</option>`).join("")}</select>
            </span>
          </div>
        </div>
        <button id="historical-view-close" class="close-x" aria-label="Fermer la vue historique">&times;</button>
      </div>
      <div id="historical-map-container">
        <div id="historical-info" hidden></div>
      </div>
      <p id="historical-slider-hint" class="muted">Données : <a href="https://github.com/Seshat-Global-History-Databank/cliopatria" target="_blank" rel="noopener">Cliopatria</a> v0.2.1 — Seshat Global History Databank (Bennett et al., <a href="https://doi.org/10.1038/s41597-025-04516-9" target="_blank" rel="noopener">Scientific Data, 2025</a>), licence <a href="https://creativecommons.org/licenses/by/4.0/" target="_blank" rel="noopener">CC BY 4.0</a> ; contours simplifiés pour le web et calés sur le trait de côte actuel (<a href="https://www.naturalearthdata.com" target="_blank" rel="noopener">Natural Earth</a>, domaine public) ; dates de naissance et de fin d'États ajustées d'après Wikidata et Wikipédia lorsqu'elles sont connues. Noms français : <a href="https://www.wikidata.org" target="_blank" rel="noopener">Wikidata</a> (CC0) et traductions de l'équipe. Les frontières, noms et dates du passé sont débattus par les historiens : ces cartes montrent une version possible.</p>
    </div>
  `;
  document.body.appendChild(racine);

  let actif = false;
  let annee = ANNEE_DE_DEPART;
  let index: HistoriqueIndex | null = null;
  let nomsFr: NomsFr | null = null;
  let carte: L.Map | null = null;
  let couchePolygones: L.FeatureGroup | null = null;
  let coucheEtiquettes: L.LayerGroup | null = null;
  let visibles: Visible[] = [];
  let groupeSelectionne: string | null = null;
  let jeton = 0; // une réponse réseau en retard ne doit pas écraser un affichage plus récent
  let enChargement = false;
  let minuterie: number | undefined;
  let lecture: number | undefined;
  const decodes = new Map<number, TraceDecodee>();

  const etiquetteAnnee = $("historical-slider-year");
  const curseur = $<HTMLInputElement>("historical-slider");
  const champAnnee = $<HTMLInputElement>("historical-year-input");

  function decoder(idTrace: number, brut: number[][][]): TraceDecodee {
    let d = decodes.get(idTrace);
    if (!d) {
      if (decodes.size >= MAX_TRACES_EN_MEMOIRE) decodes.clear();
      d = decoderTrace(brut);
      decodes.set(idTrace, d);
    }
    return d;
  }

  // Carte Leaflet dédiée, créée à la première ouverture puis réutilisée.
  function assurerCarte(): L.Map {
    if (carte) return carte;
    carte = L.map("historical-map-container", {
      zoomControl: true,
      minZoom: 2,
      maxZoom: 8,
      preferCanvas: true,
      maxBounds: [[-85, -190], [85, 190]],
      maxBoundsViscosity: 0.8,
    });
    // Fond « physique » (relief et océans, SANS frontières ni noms de pays modernes) — retour de
    // Martin du 2026-10-06 : « c'est le fond de carte des pays actuels ».
    L.tileLayer("https://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}", {
      attribution: '&copy; <a href="https://www.esri.com">Esri</a> — Esri, US National Park Service',
      maxZoom: 8,
    }).addTo(carte);
    couchePolygones = L.featureGroup().addTo(carte);
    coucheEtiquettes = L.layerGroup().addTo(carte);
    carte.fitBounds(REGIONS[0].bornes);
    // Les étiquettes dépendent de la taille des territoires à l'écran : on les recalcule quand le zoom change.
    carte.on("zoomend", placerEtiquettes);
    carte.on("click", () => fermerFiche());
    return carte;
  }

  function styleDuGroupe(groupe: string, survol: boolean) {
    const c = couleurDuGroupe(groupe);
    const selectionne = groupe === groupeSelectionne;
    return { color: c.contour, fillColor: c.remplissage, ...(survol || selectionne ? STYLE_SURVOL : STYLE_NORMAL) };
  }

  function surligner(groupe: string, survol: boolean) {
    for (const v of visibles) if (v.groupe === groupe) v.calque.setStyle(styleDuGroupe(groupe, survol));
  }

  function dessiner(idx: HistoriqueIndex, lignes: Ligne[]) {
    assurerCarte();
    couchePolygones!.clearLayers();
    visibles = [];
    for (const ligne of lignes) {
      const brut = traceChargee(idx, ligne[3]);
      if (!brut) continue;
      const decode = decoder(ligne[3], brut);
      const nomSource = nomDeLigne(idx, ligne);
      const nom = nomAffiche(nomsFr, nomSource);
      const groupe = groupeDeLigne(idx, ligne); // nom d'origine : sert de clé de couleur et de surbrillance
      const groupeAffiche = nomAffiche(nomsFr, ligne[4] >= 0 ? idx.noms[ligne[4]] : nomSource);
      // bubblingMouseEvents:false → un clic sur un territoire n'est pas pris pour un clic sur le fond (qui ferme la fiche)
      const calque = L.polygon(decode.latlngs, { ...styleDuGroupe(groupe, false), bubblingMouseEvents: false });
      calque.bindTooltip(groupeAffiche !== nom ? `${nom} — ${groupeAffiche}` : nom, { sticky: true, className: "historical-tooltip" });
      calque.on("mouseover", () => surligner(groupe, true));
      calque.on("mouseout", () => surligner(groupe, false));
      calque.on("click", () => selectionner(idx, ligne, groupe));
      couchePolygones!.addLayer(calque);
      visibles.push({ ligne, nom, groupe, groupeAffiche, decode, calque });
    }
    placerEtiquettes();
  }

  // Étiquettes : seulement pour les territoires assez grands pour contenir leur nom à l'écran actuel,
  // sans jamais se chevaucher (les plus grands passent en premier).
  function placerEtiquettes() {
    if (!carte || !coucheEtiquettes) return;
    coucheEtiquettes.clearLayers();
    const posees: { x0: number; y0: number; x1: number; y1: number }[] = [];
    for (const v of visibles) {
      const largeurTexte = v.nom.length * 6.3 + 10;
      const [[sud, ouest], [nord, est]] = v.decode.boite;
      const a = carte.latLngToContainerPoint([nord, ouest]);
      const b = carte.latLngToContainerPoint([sud, est]);
      if (Math.abs(b.x - a.x) < largeurTexte || Math.abs(b.y - a.y) < 18) continue;
      const c = carte.latLngToContainerPoint(v.decode.centre);
      const boite = { x0: c.x - largeurTexte / 2, x1: c.x + largeurTexte / 2, y0: c.y - 9, y1: c.y + 9 };
      if (posees.some((p) => boite.x0 < p.x1 && boite.x1 > p.x0 && boite.y0 < p.y1 && boite.y1 > p.y0)) continue;
      posees.push(boite);
      const texte = document.createElement("span");
      texte.textContent = v.nom;
      L.marker(v.decode.centre, {
        icon: L.divIcon({ className: "historical-label", html: texte, iconSize: [0, 0] }),
        interactive: false,
        keyboard: false,
      }).addTo(coucheEtiquettes);
    }
  }

  function selectionner(idx: HistoriqueIndex, ligne: Ligne, groupe: string) {
    const ancien = groupeSelectionne;
    groupeSelectionne = groupe;
    if (ancien) surligner(ancien, false);
    surligner(groupe, false);
    const meta = idx.meta[ligne[0]];
    const nomSource = nomDeLigne(idx, ligne);
    const nom = nomAffiche(nomsFr, nomSource);
    const groupeAffiche = nomAffiche(nomsFr, ligne[4] >= 0 ? idx.noms[ligne[4]] : nomSource);
    const wikipedia = lienWikipedia(meta);
    const wikidata = lienWikidata(meta);
    const fiche = $("historical-info");
    fiche.replaceChildren();
    const titre = document.createElement("h3");
    titre.textContent = nom;
    fiche.append(titre);
    const ligneTexte = (texte: string) => {
      const p = document.createElement("p");
      p.textContent = texte;
      fiche.append(p);
    };
    if (groupeAffiche !== nom) ligneTexte(`Membre de : ${groupeAffiche}`);
    if (nomSource !== nom) {
      ligneTexte(`Nom d'origine (source, anglais) : ${nomSource}${estTraduction(nomsFr, nomSource) ? " — traduction française proposée, à confirmer" : ""}`);
    }
    const existence = periodeEntite(idx, ligne);
    ligneTexte(`Existe sur la carte : ${formatExistence(existence.debut, existence.fin)}`);
    ligneTexte(`Ce contour (cette forme) vaut pour : ${formatPeriode(ligne[1], ligne[2])}`);
    ligneTexte(`Superficie d'après le tracé : environ ${ligne[5].toLocaleString("fr-FR")} km²`);
    const liens = document.createElement("p");
    for (const [libelle, url] of [["Wikipédia (anglais)", wikipedia], ["Wikidata", wikidata]] as const) {
      if (!url) continue;
      const a = document.createElement("a");
      a.href = url;
      a.target = "_blank";
      a.rel = "noopener";
      a.textContent = libelle;
      liens.append(a, " ");
    }
    if (liens.childNodes.length) fiche.append(liens);
    const fermer = document.createElement("button");
    fermer.type = "button";
    fermer.className = "close-x";
    fermer.setAttribute("aria-label", "Fermer");
    fermer.textContent = "×";
    fermer.addEventListener("click", fermerFiche);
    fiche.append(fermer);
    fiche.hidden = false;
  }

  function fermerFiche() {
    const ancien = groupeSelectionne;
    groupeSelectionne = null;
    if (ancien) surligner(ancien, false);
    $("historical-info").hidden = true;
  }

  function montrerErreur(on: boolean) {
    const existant = document.getElementById("historical-slider-hint-error");
    if (!on) return existant?.remove();
    if (existant) return;
    const e = document.createElement("div");
    e.id = "historical-slider-hint-error";
    e.textContent = "Impossible de charger les données pour cette année (connexion réseau ?).";
    $("historical-slider-hint").prepend(e);
  }

  async function afficher(an: number) {
    const mon = ++jeton;
    enChargement = true;
    etiquetteAnnee.classList.add("loading");
    try {
      index ??= await chargerIndex();
      nomsFr ??= await chargerNomsFr();
      const lignes = lignesALAnnee(index, an);
      await assurerTraces(index, lignes);
      if (mon !== jeton) return; // une sélection plus récente a pris le dessus
      dessiner(index, lignes);
      montrerErreur(false);
      void precharger(index, an);
    } catch (err) {
      if (mon !== jeton) return;
      console.error("Vue historique : échec du chargement pour l'année " + an, err);
      montrerErreur(true);
    } finally {
      if (mon === jeton) {
        enChargement = false;
        etiquetteAnnee.classList.remove("loading");
      }
    }
  }

  // Pendant qu'on regarde une année, on prépare discrètement la suivante (lecture fluide).
  async function precharger(idx: HistoriqueIndex, an: number) {
    try {
      await assurerTraces(idx, lignesALAnnee(idx, bornerAnnee(an + 15)));
    } catch {
      /* sans importance : le vrai chargement réessaiera */
    }
  }

  function definirAnnee(valeur: number, immediat = false) {
    annee = bornerAnnee(valeur);
    curseur.value = String(annee);
    champAnnee.value = String(annee);
    etiquetteAnnee.textContent = formatAnnee(annee);
    if (!actif) return;
    window.clearTimeout(minuterie);
    if (immediat) void afficher(annee);
    else minuterie = window.setTimeout(() => void afficher(annee), DELAI_CURSEUR_MS);
  }

  function arreterLecture() {
    if (lecture !== undefined) window.clearInterval(lecture);
    lecture = undefined;
    $("historical-play").textContent = "▶ Lecture";
  }

  function demarrerLecture() {
    if (annee >= ANNEE_MAX) definirAnnee(ANNEE_MIN, true);
    const vitesse = parseInt($<HTMLSelectElement>("historical-speed").value, 10);
    const pas = vitesse <= 5 ? 1 : vitesse / 5;
    const cadence = vitesse <= 5 ? 1000 / vitesse : 200;
    $("historical-play").textContent = "⏸ Pause";
    lecture = window.setInterval(() => {
      if (enChargement) return; // on n'avance pas tant que l'image précédente n'est pas prête
      if (annee >= ANNEE_MAX) return arreterLecture();
      definirAnnee(annee + pas, true);
    }, cadence);
  }

  function activer() {
    if (actif) return;
    actif = true;
    $("historical-view").classList.add("open");
    $("historical-toggle-btn").classList.add("active");
    const m = assurerCarte();
    // La carte était masquée à sa création : Leaflet doit relire la taille réelle de son conteneur.
    window.setTimeout(() => {
      m.invalidateSize();
      m.fitBounds(REGIONS[parseInt($<HTMLSelectElement>("historical-region").value, 10)].bornes);
    }, 50);
    void afficher(annee);
  }

  function desactiver() {
    if (!actif) return;
    actif = false;
    arreterLecture();
    $("historical-view").classList.remove("open");
    $("historical-toggle-btn").classList.remove("active");
  }

  $("historical-toggle-btn").addEventListener("click", () => (actif ? desactiver() : activer()));
  $("historical-view-close").addEventListener("click", desactiver);
  curseur.addEventListener("input", () => definirAnnee(parseInt(curseur.value, 10)));
  champAnnee.addEventListener("change", () => {
    const n = parseInt(champAnnee.value, 10);
    definirAnnee(Number.isNaN(n) ? annee : n, true);
  });
  racine.querySelectorAll<HTMLButtonElement>("button[data-pas]").forEach((b) =>
    b.addEventListener("click", () => definirAnnee(annee + parseInt(b.dataset.pas!, 10), true)),
  );
  $("historical-play").addEventListener("click", () => (lecture === undefined ? demarrerLecture() : arreterLecture()));
  $("historical-speed").addEventListener("change", () => {
    if (lecture !== undefined) {
      arreterLecture();
      demarrerLecture();
    }
  });
  $("historical-region").addEventListener("change", (e) => {
    const i = parseInt((e.target as HTMLSelectElement).value, 10);
    carte?.fitBounds(REGIONS[i].bornes);
  });
  definirAnnee(annee);

  // Point d'extension pour le lien date ↔ vue historique (demande de Martin du 2026-10-06 : cliquer
  // une date dans une fiche ou une frise ouvre la carte à cette époque) — câblage prévu plus tard.
  function openAt(an: number) {
    definirAnnee(an, true); // si la vue est déjà ouverte, ceci l'affiche ; sinon activer() s'en charge
    activer();
  }

  return {
    openAt,
    isActive: () => actif,
  };
}
