// ---------------------------------------------------------------------------
// Frises chronologiques — logique pure (dates, périodes, bornes partagées,
// trous de transition, largeurs). Aucune dépendance au DOM ni à Supabase :
// testable seule. Modèle décrit dans supabase/schema_v27.sql et dans la
// spécification du projet ("frises-chronologiques-specification").
//
// Rappels du modèle (validé avec Martin, 2026-10-21) :
// - une période EST une sous-catégorie (dossier_sections) portant une date de
//   début ; les périodes d'une frise ne se chevauchent pas ;
// - chaque période a une date de début ET une date de fin ; la fin d'une
//   période peut être égale au début de la suivante (borne partagée, cas
//   normal). Si la fin est AVANT le début de la suivante, l'intervalle devient
//   automatiquement une TRANSITION (hachurée, grisée) ; la fin ne peut pas
//   dépasser le début de la suivante (chevauchement). Anciennes données sans
//   fin : la fin est le début de la suivante (ou aujourd'hui pour la dernière).
// ---------------------------------------------------------------------------

export type FriseDate = {
  year: number; // négatif = avant J.-C. (pas d'année 0)
  month: number | null; // 1-12
  day: number | null; // 1-31, seulement si month est renseigné
  circa: boolean; // "vers"
};

export type Period = {
  id: string;
  name: string;
  start: FriseDate;
  // Fin de la période (null seulement pour d'anciennes données).
  end: FriseDate | null;
  color: string | null; // couleur d'affichage (#rrggbb) ou null
};

export type Segment =
  | {
      kind: "period";
      period: Period;
      startDec: number;
      endDec: number;
      openEnded: boolean; // dernière période sans fin explicite
    }
  | {
      kind: "gap";
      afterPeriodId: string;
      startDec: number;
      endDec: number;
    };

export type LayoutIssue = { periodId: string; message: string };

const MONTHS_SHORT = ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."];

// --- Dates ------------------------------------------------------------------

/** Clé de tri entière (même formule que timeline_events.sort_key en base). */
export function dateSortKey(d: FriseDate): number {
  return d.year * 10000 + (d.month ?? 0) * 100 + (d.day ?? 0);
}

/** Position décimale en années (pour la géométrie). */
export function dateToDecimal(d: FriseDate): number {
  const m = d.month ? d.month - 1 : 0;
  const day = d.day ? d.day - 1 : 0;
  return d.year + m / 12 + day / 365;
}

/** Année de référence pour "jusqu'à aujourd'hui". */
export function currentYear(): number {
  return new Date().getFullYear();
}

export function formatFriseDate(d: FriseDate): string {
  const y = d.year < 0 ? `${-d.year} av. J.-C.` : String(d.year);
  let s: string;
  if (d.month && d.day) s = `${d.day} ${MONTHS_SHORT[d.month - 1]} ${y}`;
  else if (d.month) s = `${MONTHS_SHORT[d.month - 1]} ${y}`;
  else s = y;
  return d.circa ? `vers ${s}` : s;
}

/**
 * Valide les champs d'un formulaire de date. `year` est l'année telle que
 * saisie (positive) et `bc` indique "av. J.-C.". Renvoie la date ou un
 * message d'erreur en français.
 */
export function parseDateFields(input: {
  year: string;
  bc: boolean;
  month: string;
  day: string;
  circa: boolean;
}): { ok: true; date: FriseDate } | { ok: false; error: string } {
  const yRaw = input.year.trim();
  if (!/^\d{1,6}$/.test(yRaw)) return { ok: false, error: "L'année doit être un nombre (ex. 843)." };
  const y = parseInt(yRaw, 10);
  if (y === 0) return { ok: false, error: "L'année 0 n'existe pas : après 1 av. J.-C. vient l'an 1." };
  const year = input.bc ? -y : y;
  const month = input.month.trim() ? parseInt(input.month, 10) : null;
  if (month !== null && (!Number.isInteger(month) || month < 1 || month > 12)) {
    return { ok: false, error: "Le mois doit être compris entre 1 et 12." };
  }
  const dayRaw = input.day.trim();
  let day: number | null = null;
  if (dayRaw) {
    if (month === null) return { ok: false, error: "Indique le mois avant de préciser le jour." };
    if (!/^\d{1,2}$/.test(dayRaw)) return { ok: false, error: "Le jour doit être un nombre." };
    day = parseInt(dayRaw, 10);
    const maxDay = new Date(2001, month, 0).getDate() + (month === 2 ? 1 : 0); // février : 29 toléré (années bissextiles)
    if (day < 1 || day > maxDay) return { ok: false, error: "Ce jour n'existe pas pour ce mois." };
  }
  return { ok: true, date: { year, month, day, circa: input.circa } };
}

// --- Périodes : bornes partagées, trous, chevauchements ---------------------

/**
 * Transforme les périodes d'une frise en segments consécutifs, triées par
 * date de début (puis de fin). Pour chaque période :
 *  - fin explicite ; sinon début de la suivante ; sinon (dernière) ouverte
 *    jusqu'à `openEndYear` ;
 *  - fin strictement avant le début de la suivante → un segment "gap"
 *    (transition) occupe l'intervalle ;
 *  - fin égale au début de la suivante → borne partagée (cas normal, accepté) ;
 *  - fin après le début de la suivante → chevauchement, signalé ;
 *  - fin avant son propre début → signalé.
 */
export function layoutPeriods(
  periods: Period[],
  openEndYear: number = currentYear()
): { segments: Segment[]; issues: LayoutIssue[]; sorted: Period[] } {
  const endKey = (p: Period) => (p.end ? dateSortKey(p.end) : dateSortKey(p.start));
  const sorted = [...periods].sort((a, b) => dateSortKey(a.start) - dateSortKey(b.start) || endKey(a) - endKey(b));
  const segments: Segment[] = [];
  const issues: LayoutIssue[] = [];
  for (let i = 0; i < sorted.length; i++) {
    const p = sorted[i];
    const next = sorted[i + 1] ?? null;
    const startKey = dateSortKey(p.start);
    const startDec = dateToDecimal(p.start);
    if (p.end && dateSortKey(p.end) < startKey) {
      issues.push({ periodId: p.id, message: `La fin de « ${p.name} » est avant son début.` });
    }
    if (!next) {
      const hasEnd = !!p.end && dateSortKey(p.end) >= startKey;
      const endDec = hasEnd ? dateToDecimal(p.end as FriseDate) : Math.max(openEndYear, startDec + 1);
      segments.push({ kind: "period", period: p, startDec, endDec, openEnded: !hasEnd });
      continue;
    }
    const nextKey = dateSortKey(next.start);
    const nextDec = dateToDecimal(next.start);
    const zeroLength = !!p.end && dateSortKey(p.end) === startKey;
    if (nextKey === startKey && !zeroLength) {
      issues.push({ periodId: next.id, message: `« ${next.name} » commence à la même date que « ${p.name} ».` });
    }
    if (p.end && dateSortKey(p.end) >= startKey) {
      const eKey = dateSortKey(p.end);
      if (eKey > nextKey) {
        issues.push({
          periodId: p.id,
          message: `La fin de « ${p.name} » dépasse le début de « ${next.name} » : les périodes ne peuvent pas se chevaucher.`,
        });
        segments.push({ kind: "period", period: p, startDec, endDec: Math.max(nextDec, startDec), openEnded: false });
      } else if (eKey < nextKey) {
        const endDec = dateToDecimal(p.end);
        segments.push({ kind: "period", period: p, startDec, endDec, openEnded: false });
        segments.push({ kind: "gap", afterPeriodId: p.id, startDec: endDec, endDec: nextDec });
      } else {
        segments.push({ kind: "period", period: p, startDec, endDec: nextDec, openEnded: false });
      }
    } else {
      segments.push({ kind: "period", period: p, startDec, endDec: Math.max(nextDec, startDec), openEnded: false });
    }
  }
  return { segments, issues, sorted };
}

/** Indice du segment qui contient une date décimale (début inclus, fin exclue, sauf le dernier). */
export function locateSegment(dec: number, segments: Segment[]): number {
  for (let i = 0; i < segments.length; i++) {
    const last = i === segments.length - 1;
    if (dec >= segments[i].startDec && (dec < segments[i].endDec || (last && dec <= segments[i].endDec))) return i;
  }
  return -1;
}

/**
 * Largeur en pixels de chaque segment : proportionnelle à la durée, avec un
 * minimum pour que les périodes courtes restent lisibles (la frise défile
 * alors horizontalement si besoin).
 */
export function computeWidths(
  segments: Segment[],
  containerWidth: number,
  opts: { minPeriod?: number; minGap?: number } = {}
): number[] {
  const minPeriod = opts.minPeriod ?? 150;
  const minGap = opts.minGap ?? 60;
  if (segments.length === 0) return [];
  const total = segments.reduce((s, seg) => s + Math.max(seg.endDec - seg.startDec, 0), 0) || 1;
  return segments.map((seg) => {
    const prop = (Math.max(seg.endDec - seg.startDec, 0) / total) * containerWidth;
    return Math.max(prop, seg.kind === "gap" ? minGap : minPeriod);
  });
}

/**
 * Abscisse (en pixels, depuis le bord gauche de la bande) d'une date décimale,
 * par interpolation dans le segment qui la contient. Prévu pour placer les
 * événements sur la bande (étape suivante). Hors bornes : null.
 */
export function xForDecimal(dec: number, segments: Segment[], widths: number[]): number | null {
  let x = 0;
  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i];
    const w = widths[i];
    if (dec >= seg.startDec && dec <= seg.endDec) {
      const span = seg.endDec - seg.startDec || 1;
      return x + ((dec - seg.startDec) / span) * w;
    }
    x += w;
  }
  return null;
}

/**
 * Largeurs en pixels À L'ÉCHELLE : proportionnelles à la durée (même nombre de
 * pixels par année partout), avec un tout petit minimum pour qu'une période
 * très courte ou de durée nulle reste visible et cliquable. Cette échelle
 * constante est ce qui rend la règle de graduation (niceTicks) exacte.
 */
export function computeLinearWidths(segments: Segment[], totalPx: number, minPx = 18): number[] {
  if (segments.length === 0) return [];
  const total = segments.reduce((s, seg) => s + Math.max(seg.endDec - seg.startDec, 0), 0) || 1;
  return segments.map((seg) => Math.max((Math.max(seg.endDec - seg.startDec, 0) / total) * totalPx, minPx));
}

export type Tick = { dec: number; label: string; year: number; month: number | null };

const TICK_STEPS = [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000, 10000];

/**
 * Graduations de la règle : un pas "rond" (1, 2, 5, 10, 25, 50, 100… ans) choisi
 * pour que deux repères soient espacés d'au moins `minGapPx` pixels ; en zoom
 * fort (≥ ~1000 px par an), un repère par mois. `ppy` = pixels par année.
 */
export function niceTicks(startDec: number, endDec: number, ppy: number, minGapPx = 90): Tick[] {
  const out: Tick[] = [];
  if (!(ppy > 0) || endDec <= startDec) return out;
  if (ppy / 12 >= minGapPx * 0.8) {
    // Un repère par mois.
    for (let y = Math.floor(startDec); y <= Math.ceil(endDec); y++) {
      if (y === 0) continue;
      for (let m = 1; m <= 12; m++) {
        const dec = y + (m - 1) / 12;
        if (dec < startDec - 1e-9 || dec > endDec + 1e-9) continue;
        out.push({ dec, label: formatFriseDate({ year: y, month: m, day: null, circa: false }), year: y, month: m });
      }
    }
    return out;
  }
  const step = TICK_STEPS.find((s) => s * ppy >= minGapPx) ?? TICK_STEPS[TICK_STEPS.length - 1];
  for (let y = Math.ceil(startDec / step) * step; y <= endDec + 1e-9; y += step) {
    if (y === 0) continue;
    out.push({ dec: y, label: formatFriseDate({ year: y, month: null, day: null, circa: false }), year: y, month: null });
  }
  return out;
}
