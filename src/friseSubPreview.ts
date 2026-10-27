// ---------------------------------------------------------------------------
// Frises — aperçu d'une sous-frise au survol (période ou point avec durée).
// Montre, sans ouvrir la sous-frise : ses périodes et ses premiers points.
// Lecture seule ; aucune migration. Les données sont gardées 60 s en mémoire
// pour que le survol reste instantané.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import { fetchPeriods } from "./friseEvents";
import { dateSortKey, formatFriseDate, type FriseDate } from "./friseModel";

export type SubPreview = {
  periods: { name: string; start: FriseDate }[];
  points: { title: string; date: FriseDate }[];
  pointCount: number;
};

const SHOWN_PERIODS = 6;
const SHOWN_POINTS = 6;
const TTL_MS = 60_000;
const cache = new Map<string, { at: number; data: SubPreview }>();

type EventRow = { id: string; title: string; date_year: number; date_month: number | null; date_day: number | null; date_circa: boolean | null };

export async function loadSubPreview(supabase: SupabaseClient, friseId: string): Promise<SubPreview> {
  const hit = cache.get(friseId);
  if (hit && Date.now() - hit.at < TTL_MS) return hit.data;
  const periods = (await fetchPeriods(supabase, friseId))
    .sort((a, b) => dateSortKey(a.start) - dateSortKey(b.start))
    .map((p) => ({ name: p.name, start: p.start }));
  const { data: pls } = await supabase.from("timeline_placements").select("event_id").eq("frise_entry_id", friseId);
  const ids = ((pls as { event_id: string }[] | null) ?? []).map((r) => r.event_id);
  let points: SubPreview["points"] = [];
  if (ids.length) {
    const { data: evs } = await supabase
      .from("timeline_events")
      .select("id, title, date_year, date_month, date_day, date_circa")
      .in("id", ids);
    points = ((evs as EventRow[] | null) ?? [])
      .map((e) => ({ title: e.title, date: { year: e.date_year, month: e.date_month, day: e.date_day, circa: !!e.date_circa } }))
      .sort((a, b) => dateSortKey(a.date) - dateSortKey(b.date));
  }
  const data: SubPreview = { periods, points, pointCount: points.length };
  cache.set(friseId, { at: Date.now(), data });
  return data;
}

/** Bloc HTML de l'aperçu (classes .tl-sub-* dans friseMulti.css). */
export function buildSubPreview(d: SubPreview): HTMLElement {
  const box = document.createElement("div");
  box.className = "tl-sub-preview";
  const head = (text: string) => {
    const h = document.createElement("div");
    h.className = "tl-sub-head";
    h.textContent = text;
    box.appendChild(h);
  };
  const line = (text: string) => {
    const l = document.createElement("div");
    l.className = "tl-sub-line";
    l.textContent = text;
    box.appendChild(l);
  };
  if (!d.periods.length && !d.pointCount) {
    line("Sous-frise encore vide.");
    return box;
  }
  if (d.periods.length) {
    head(d.periods.length + (d.periods.length > 1 ? " périodes" : " période"));
    d.periods.slice(0, SHOWN_PERIODS).forEach((p) => line(formatFriseDate(p.start) + " · " + p.name));
    if (d.periods.length > SHOWN_PERIODS) line("… et " + (d.periods.length - SHOWN_PERIODS) + " autres");
  }
  if (d.pointCount) {
    head(d.pointCount + (d.pointCount > 1 ? " points" : " point"));
    d.points.slice(0, SHOWN_POINTS).forEach((p) => line(formatFriseDate(p.date) + " · " + p.title));
    if (d.pointCount > SHOWN_POINTS) line("… et " + (d.pointCount - SHOWN_POINTS) + " autres");
  }
  return box;
}
