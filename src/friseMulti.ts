// ---------------------------------------------------------------------------
// Frises — dialogue « Frises de ce point » : placements multiples, remontée sur
// la frise parente, et « placer une fiche existante sur une frise ».
// Spécification : docs/specs/frises-chronologiques.md §3 et §4.
//
// - Un événement peut figurer sur plusieurs frises, toujours comme UN SEUL objet
//   (placement = référence, jamais une copie).
// - « Remontée » : une frise parente ne montre pas automatiquement les événements
//   de ses sous-frises ; on choisit, événement par événement, d'en faire
//   apparaître certains dessus. Techniquement c'est un placement de plus sur la
//   frise parente.
// - Depuis une fiche qui n'est sur aucune frise (ex. « Édit de Nantes » rangé dans
//   Religion), on peut la placer sur une frise sans la déplacer : un événement
//   est créé (titre de la fiche + date saisie) et relié à la fiche.
//
// Modification réservée aux administrateurs ; la consultation (liste des frises,
// ouverture d'une frise) est ouverte à tous. Les accès à la base sont dans
// friseEvents.ts. Aucune migration nécessaire.
// ---------------------------------------------------------------------------

import "./friseMulti.css";
import type { SupabaseClient, Session } from "@supabase/supabase-js";
import { buildDateFields } from "./friseDateFields";
import {
  addPlacement,
  checkDateFitsFrise,
  createEventForFiche,
  eventDateText,
  eventIdOfFiche,
  fetchEvent,
  fetchFriseRefs,
  fetchPlacements,
  removePlacement,
  searchFrises,
  type FriseRef,
  type PlacementOptions,
} from "./friseEvents";

export type FriseMultiDeps = {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  isAdmin: () => boolean;
  getOwnerLabel: (ownerType: string, ownerId: string) => string | null;
  showBanner?: (msg: string) => void;
  // Ouvre une frise et met le point en évidence (frise.ts).
  openFrise: (friseId: string, eventId: string) => Promise<void>;
  // Recharge la frise affichée après un changement de placement (frise.ts).
  onChanged: () => Promise<void>;
};

type EventArgs = { eventId: string; currentFriseId?: string | null; parentFriseId?: string | null };

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className?: string, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  return e;
}

export function initFriseMulti(deps: FriseMultiDeps) {
  const { supabase } = deps;

  const overlay = el("div");
  overlay.id = "tl-multi-overlay";
  const box = el("div");
  box.id = "tl-multi-box";
  box.setAttribute("role", "dialog");
  box.setAttribute("aria-modal", "true");
  overlay.appendChild(box);
  document.body.appendChild(overlay);

  function close() {
    overlay.classList.remove("open");
    box.innerHTML = "";
  }
  overlay.addEventListener("click", (ev) => {
    if (ev.target === overlay) close();
  });
  document.addEventListener("keydown", (ev) => {
    if (ev.key === "Escape" && overlay.classList.contains("open")) close();
  });

  function ownerText(r: FriseRef): string {
    const o = deps.getOwnerLabel(r.ownerType, r.ownerId);
    return (r.title || "Frise") + (o ? " — " + o : "");
  }

  // Recherche de frise (par titre) : champ + résultats cliquables.
  function buildFriseSearch(onPick: (r: FriseRef) => void, exclude: Set<string>) {
    const wrap = el("div", "tl-field");
    wrap.appendChild(document.createTextNode("Chercher une frise par titre"));
    const input = el("input");
    input.type = "text";
    input.placeholder = "ex. Histoire de France…";
    input.autocomplete = "off";
    const results = el("div", "tl-results");
    wrap.append(input, results);
    let timer: number | null = null;
    let seq = 0;
    input.addEventListener("input", () => {
      if (timer) window.clearTimeout(timer);
      timer = window.setTimeout(async () => {
        const mine = ++seq;
        const list = (await searchFrises(supabase, input.value)).filter((r) => !exclude.has(r.id));
        if (mine !== seq) return;
        results.innerHTML = "";
        if (!list.length && input.value.trim().length >= 2) {
          results.appendChild(el("div", "tl-result none", "Aucune autre frise trouvée."));
        }
        for (const r of list) {
          const b = el("button", "tl-result", ownerText(r));
          b.type = "button";
          b.addEventListener("click", () => onPick(r));
          results.appendChild(b);
        }
      }, 250);
    });
    return wrap;
  }

  function footer(): HTMLElement {
    const actions = el("div", "tl-actions");
    actions.appendChild(el("span", "tl-spacer"));
    const done = el("button", "btn-small", "Fermer");
    done.type = "button";
    done.addEventListener("click", close);
    actions.appendChild(done);
    return actions;
  }

  // --- Un événement : sur quelles frises apparaît-il ? ---------------------------------
  async function renderEvent(args: EventArgs) {
    const ev = await fetchEvent(supabase, args.eventId);
    if (!ev) {
      box.innerHTML = "";
      box.append(el("p", "tl-error", "Ce point n'existe plus."), footer());
      return;
    }
    const placements = await fetchPlacements(supabase, ev.id);
    const ids = placements.map((p) => p.friseId);
    const refs = await fetchFriseRefs(supabase, [...ids, ...(args.parentFriseId ? [args.parentFriseId] : [])]);
    const refOf = (id: string): FriseRef => refs.find((r) => r.id === id) ?? { id, title: null, ownerType: "", ownerId: "" };
    const admin = deps.isAdmin();
    const baseOptions: PlacementOptions =
      placements.find((p) => p.friseId === args.currentFriseId)?.options ?? placements[0]?.options ?? { side: "up", categoryId: null, color: null };

    box.innerHTML = "";
    box.appendChild(el("h3", undefined, "Frises de « " + ev.title + " »"));
    box.appendChild(el("p", "tl-note", eventDateText(ev) + (placements.length > 1 ? " · c'est le même point sur toutes ces frises" : "")));

    const error = el("p", "tl-error");
    error.setAttribute("role", "alert");
    const fail = (m: string) => (error.textContent = m);

    const list = el("div");
    if (!placements.length) list.appendChild(el("p", "tl-note", "Ce point n'est placé sur aucune frise."));
    for (const p of placements) {
      const ref = refOf(p.friseId);
      const row = el("div", "tl-fiche-row");
      const name = el("span", undefined, ownerText(ref));
      if (p.friseId === args.currentFriseId) name.appendChild(el("em", "tl-multi-tag", " · affichée ici"));
      else if (p.friseId === args.parentFriseId) name.appendChild(el("em", "tl-multi-tag", " · frise parente"));
      row.appendChild(name);
      if (p.friseId !== args.currentFriseId) {
        const open = el("button", "btn-small", "Ouvrir");
        open.type = "button";
        open.addEventListener("click", () => {
          close();
          void deps.openFrise(p.friseId, ev.id);
        });
        row.appendChild(open);
      }
      if (admin && placements.length > 1) {
        const rm = el("button", "btn-small", "Retirer");
        rm.type = "button";
        rm.title = "Retirer le point de cette frise (la fiche et les autres frises ne changent pas)";
        rm.addEventListener("click", async () => {
          const err = await removePlacement(supabase, p.friseId, ev.id);
          if (err) return fail(err);
          await deps.onChanged();
          await renderEvent(args);
        });
        row.appendChild(rm);
      }
      list.appendChild(row);
    }
    box.appendChild(list);

    if (admin) {
      const session = deps.getSession();
      const addTo = async (target: FriseRef) => {
        if (!session) return fail("Connexion requise.");
        fail("");
        const fit = await checkDateFitsFrise(supabase, target.id, target.title, ev.date, ev.end);
        if (fit) return fail(fit);
        const err = await addPlacement(supabase, target.id, ev.id, session.user.id, baseOptions);
        if (err) return fail(err);
        await deps.onChanged();
        await renderEvent(args);
      };

      // Remontée : une frise parente existe et le point n'y est pas encore.
      if (args.parentFriseId && !ids.includes(args.parentFriseId)) {
        const parent = refOf(args.parentFriseId);
        const lift = el("div", "tl-field");
        lift.appendChild(
          el("span", undefined, "Cette frise est la sous-frise de « " + (parent.title || "Frise") + " ». Le point n'y apparaît pas pour l'instant.")
        );
        const b = el("button", "btn-small tl-primary", "Afficher aussi sur la frise parente");
        b.type = "button";
        b.addEventListener("click", () => void addTo(parent));
        lift.appendChild(b);
        box.appendChild(lift);
      }

      box.appendChild(buildFriseSearch((r) => void addTo(r), new Set(ids)));
    }

    box.append(error, footer());
  }

  async function openForEvent(args: EventArgs) {
    box.innerHTML = "";
    box.appendChild(el("p", "tl-note", "Chargement…"));
    overlay.classList.add("open");
    await renderEvent(args);
  }

  // --- Une fiche existante : la placer sur une frise -----------------------------------
  function renderNewFromFiche(args: { entryId: string; title: string }) {
    box.innerHTML = "";
    box.appendChild(el("h3", undefined, "Placer « " + args.title + " » sur une frise"));
    box.appendChild(
      el(
        "p",
        "tl-note",
        "La fiche reste où elle est. Un point de frise est créé avec le titre de la fiche et la date ci-dessous, puis relié à la fiche."
      )
    );
    const date = buildDateFields("Date de l'événement");
    box.appendChild(date.el);
    const error = el("p", "tl-error");
    error.setAttribute("role", "alert");
    const fail = (m: string) => (error.textContent = m);

    const place = async (target: FriseRef) => {
      const session = deps.getSession();
      if (!session) return fail("Connexion requise.");
      const d = date.read();
      if (d.kind === "empty") return fail("Indique d'abord la date de l'événement.");
      if (d.kind === "error") return fail(d.error);
      fail("");
      const fit = await checkDateFitsFrise(supabase, target.id, target.title, d.date, null);
      if (fit) return fail(fit);
      const res = await createEventForFiche(supabase, {
        entryId: args.entryId,
        title: args.title,
        date: d.date,
        end: null,
        friseId: target.id,
        userId: session.user.id,
        placement: { side: "up", categoryId: null, color: null },
      });
      if (!res.ok) return fail(res.error);
      close();
      deps.showBanner?.("« " + args.title + " » est placée sur la frise « " + (target.title || "Frise") + " ».");
      await deps.openFrise(target.id, res.eventId);
    };

    box.append(buildFriseSearch((r) => void place(r), new Set()), error, footer());
  }

  async function openForFiche(args: { entryId: string; title: string | null }) {
    box.innerHTML = "";
    box.appendChild(el("p", "tl-note", "Chargement…"));
    overlay.classList.add("open");
    const eventId = await eventIdOfFiche(supabase, args.entryId);
    if (eventId) return renderEvent({ eventId });
    if (!deps.isAdmin()) {
      close();
      deps.showBanner?.("Cette fiche n'est sur aucune frise.");
      return;
    }
    const title = (args.title || "").trim();
    if (!title) {
      box.innerHTML = "";
      box.append(el("p", "tl-error", "Cette fiche n'a pas de titre : donne-lui d'abord un titre pour pouvoir la placer sur une frise."), footer());
      return;
    }
    renderNewFromFiche({ entryId: args.entryId, title });
  }

  return { openForEvent, openForFiche, close };
}

