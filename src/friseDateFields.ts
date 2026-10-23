// ---------------------------------------------------------------------------
// Frises — bloc de saisie d'une date (année, av. J.-C., mois, jour, « vers »).
// Même présentation et mêmes règles que les dates de frise.ts (parseDateFields,
// friseModel.ts), pour les formulaires construits par d'autres modules
// (friseMulti.ts, friseAutoPlace.ts). Les classes .tl-date / .tl-inline sont
// celles de style.css.
// ---------------------------------------------------------------------------

import { parseDateFields, type FriseDate } from "./friseModel";

export type DateRead = { kind: "empty" } | { kind: "ok"; date: FriseDate } | { kind: "error"; error: string };

export type DateFieldsHandle = {
  el: HTMLElement;
  /** Lit la saisie : vide (rien tapé), valide, ou message d'erreur en français. */
  read: () => DateRead;
  clear: () => void;
};

export function buildDateFields(legendText: string): DateFieldsHandle {
  const fs = document.createElement("fieldset");
  fs.className = "tl-date";
  const legend = document.createElement("legend");
  legend.textContent = legendText;
  fs.appendChild(legend);

  const text = (placeholder: string, label: string) => {
    const i = document.createElement("input");
    i.type = "text";
    i.inputMode = "numeric";
    i.placeholder = placeholder;
    i.setAttribute("aria-label", label);
    fs.appendChild(i);
    return i;
  };
  const check = (label: string) => {
    const l = document.createElement("label");
    l.className = "tl-inline";
    const c = document.createElement("input");
    c.type = "checkbox";
    l.append(c, document.createTextNode(" " + label));
    fs.appendChild(l);
    return c;
  };

  const year = text("Année", "Année");
  const bc = check("av. J.-C.");
  const month = text("Mois", "Mois");
  const day = text("Jour", "Jour");
  const circa = check("vers");

  return {
    el: fs,
    read: () => {
      if (!year.value.trim() && !month.value.trim() && !day.value.trim()) return { kind: "empty" };
      const r = parseDateFields({ year: year.value, bc: bc.checked, month: month.value, day: day.value, circa: circa.checked });
      return r.ok ? { kind: "ok", date: r.date } : { kind: "error", error: r.error };
    },
    clear: () => {
      year.value = month.value = day.value = "";
      bc.checked = circa.checked = false;
    },
  };
}
