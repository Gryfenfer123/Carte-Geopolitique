// ---------------------------------------------------------------------------
// Frises — règnes : interface (ruban « Règnes » sous la frise, carte au clic,
// dialogue « + Règne »). Données : friseReigns.ts ; logique pure : friseReignModel.ts.
// Spécification : docs/specs/frises-chronologiques.md §10 et §11.
//
// - Un règne se saisit ici avec ses sources (au moins une, obligatoire). Il est
//   « vérifié » (trait plein) avec >= 2 sources dont une universitaire, sinon
//   « à vérifier » (pointillés).
// - Modification réservée aux administrateurs ; consultation ouverte à tous.
// ---------------------------------------------------------------------------

import "./friseReigns.css";
import type { SupabaseClient, Session } from "@supabase/supabase-js";
import { buildDateFields } from "./friseDateFields";
import { dateToDecimal, formatFriseDate, dateSortKey, type FriseDate } from "./friseModel";
import { assignLanes, isReignVerified, type ReignSource } from "./friseReignModel";
import { deleteReign, saveReign, searchMembers, type MemberRef, type Reign } from "./friseReigns";

export type FriseReignsDeps = {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  isAdmin: () => boolean;
  showBanner?: (msg: string) => void;
  // Ouvre l'arbre du membre (main.ts : même chemin que « Ouvrir l'arbre » des fiches).
  openGenealogyMember: (ownerType: string, ownerId: string, memberId: string) => Promise<void> | void;
  // Recharge la frise affichée après un changement (frise.ts).
  onChanged: () => Promise<void>;
};

export type RibbonArgs = {
  reigns: Reign[];
  rangeStart: number; // début de la frise (décimal)
  rangeEnd: number; // fin de la frise (décimal)
  xOf: (dec: number) => number | null; // position en pixels d'une date
  scale: number; // échelle d'affichage de la frise (TL_SCALE)
};

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className?: string, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  return e;
}

export function reignDateText(r: Reign): string {
  return formatFriseDate(r.start) + " → " + (r.end ? formatFriseDate(r.end) : "en cours ou fin non renseignée");
}

export function initFriseReigns(deps: FriseReignsDeps) {
  // ----- Carte au clic sur un règne --------------------------------------------------------
  const card = el("div");
  card.id = "tl-reign-card";
  card.style.display = "none";
  document.body.appendChild(card);
  function closeCard() {
    card.style.display = "none";
  }
  document.addEventListener("pointerdown", (ev) => {
    if (card.style.display !== "none" && !card.contains(ev.target as Node) && !(ev.target as HTMLElement).closest(".tl-reign")) closeCard();
  });

  function openCard(r: Reign, anchor: HTMLElement) {
    card.innerHTML = "";
    card.appendChild(el("strong", "", r.member.name));
    const sub = [r.title || r.member.title, r.member.dynasty].filter(Boolean).join(" · ");
    if (sub) card.appendChild(el("div", "tl-card-date", sub));
    card.appendChild(el("div", "tl-reign-dates", "Règne : " + reignDateText(r)));
    if (r.member.birthYear != null || r.member.deathYear != null) {
      card.appendChild(el("div", "tl-card-date", "Vie : " + (r.member.birthYear ?? "?") + " – " + (r.member.deathYear ?? "?")));
    }
    const verified = isReignVerified(r.sources);
    card.appendChild(
      el("div", verified ? "tl-reign-ok" : "tl-reign-todo", verified ? "Vérifié (sources recoupées)" : "À vérifier : il faut 2 sources dont une universitaire")
    );
    const ul = el("ul", "tl-reign-sources");
    for (const s of r.sources) {
      const li = el("li");
      if (/^https?:\/\//i.test(s.url)) {
        const a = el("a", "", s.label);
        a.href = s.url;
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        li.appendChild(a);
      } else {
        li.textContent = s.label;
      }
      if (s.academic) li.appendChild(el("span", "tl-multi-tag", " · universitaire"));
      ul.appendChild(li);
    }
    card.appendChild(ul);
    const actions = el("div", "tl-card-actions");
    const tree = el("button", "btn-small", "Ouvrir l'arbre");
    tree.type = "button";
    tree.addEventListener("click", () => {
      closeCard();
      void deps.openGenealogyMember(r.member.ownerType, r.member.ownerId, r.member.id);
    });
    actions.appendChild(tree);
    if (deps.isAdmin()) {
      const edit = el("button", "btn-small", "Modifier");
      edit.type = "button";
      edit.addEventListener("click", () => {
        closeCard();
        openDialog(r.friseId, r);
      });
      const del = el("button", "btn-small", "Supprimer");
      del.type = "button";
      del.addEventListener("click", () => void remove(r));
      actions.append(edit, del);
    }
    card.appendChild(actions);
    card.style.display = "block";
    const rect = anchor.getBoundingClientRect();
    const cw = card.offsetWidth;
    const ch = card.offsetHeight;
    card.style.left = Math.max(8, Math.min(window.innerWidth - cw - 8, rect.left)) + "px";
    card.style.top = (rect.top - ch - 8 < 8 ? rect.bottom + 8 : rect.top - ch - 8) + "px";
  }

  async function remove(r: Reign) {
    closeCard();
    if (!window.confirm("Supprimer le règne de « " + r.member.name + " » de cette frise ?\nLe membre de l'arbre n'est pas touché.")) return;
    const err = await deps.supabase.from("timeline_reigns").delete().eq("id", r.id);
    if (err.error) return deps.showBanner?.("Échec : " + err.error.message);
    await deps.onChanged();
  }

  // ----- Ruban « Règnes » --------------------------------------------------------------------
  /** Construit le ruban (une barre par règne, rangées séparées si chevauchement). null si rien à montrer. */
  function renderRibbon(a: RibbonArgs): HTMLElement | null {
    type Bar = { r: Reign; x0: number; x1: number };
    const bars: Bar[] = [];
    for (const r of a.reigns) {
      const s = dateToDecimal(r.start);
      const e = r.end ? dateToDecimal(r.end) : a.rangeEnd;
      if (e < a.rangeStart || s > a.rangeEnd) continue; // hors de cette frise
      const x0 = a.xOf(Math.max(s, a.rangeStart));
      const x1 = a.xOf(Math.min(e, a.rangeEnd));
      if (x0 === null || x1 === null) continue;
      bars.push({ r, x0, x1: Math.max(x1, x0 + 6) });
    }
    if (!bars.length) return null;
    const lanes = assignLanes(bars.map((b) => ({ start: b.x0, end: b.x1 })));
    const laneH = Math.round(26 * a.scale);
    const ribbon = el("div", "tl-reigns");
    ribbon.style.height = (Math.max(...lanes) + 1) * (laneH + 4) + "px";
    ribbon.appendChild(el("span", "tl-reigns-label", "Règnes"));
    bars.forEach((b, i) => {
      const r = b.r;
      const verified = isReignVerified(r.sources);
      const bar = el("button", "tl-reign" + (verified ? "" : " todo") + (r.end ? "" : " open"));
      bar.type = "button";
      bar.style.left = b.x0 + "px";
      bar.style.width = b.x1 - b.x0 + "px";
      bar.style.top = lanes[i] * (laneH + 4) + "px";
      bar.style.height = laneH + "px";
      bar.textContent = r.member.name;
      bar.title = r.member.name + " — " + reignDateText(r) + (verified ? "" : " (à vérifier)");
      bar.addEventListener("click", (ev) => {
        ev.stopPropagation();
        openCard(r, bar);
      });
      ribbon.appendChild(bar);
    });
    return ribbon;
  }

  // ----- Dialogue « + Règne » ----------------------------------------------------------------
  const overlay = el("div");
  overlay.id = "tl-reign-overlay";
  const box = el("div");
  box.id = "tl-reign-box";
  overlay.appendChild(box);
  document.body.appendChild(overlay);
  function closeDialog() {
    overlay.classList.remove("open");
  }
  overlay.addEventListener("click", (ev) => {
    if (ev.target === overlay) closeDialog();
  });
  document.addEventListener("keydown", (ev) => {
    if (ev.key === "Escape" && overlay.classList.contains("open")) closeDialog();
  });

  function openDialog(friseId: string, editing?: Reign) {
    if (!deps.isAdmin()) return deps.showBanner?.("Réservé aux administrateurs.");
    box.innerHTML = "";
    box.appendChild(el("h3", "", editing ? "Modifier le règne" : "Ajouter un règne"));
    box.appendChild(
      el(
        "p",
        "tl-note",
        "Les dates de règne ne sont pas dans les arbres : on les note ici, avec leurs sources. Une date sans source n'est pas enregistrée."
      )
    );

    // Membre
    let member: MemberRef | null = editing ? editing.member : null;
    const memberField = el("div", "tl-field");
    memberField.appendChild(el("label", "", "Souverain (membre d'un arbre)"));
    const search = el("input");
    search.type = "text";
    search.placeholder = "Chercher un nom…";
    search.autocomplete = "off";
    const chosen = el("div", "tl-reign-chosen");
    const results = el("div", "tl-results");
    memberField.append(search, chosen, results);
    box.appendChild(memberField);

    const titleInput = el("input");
    titleInput.type = "text";
    titleInput.placeholder = "ex. Roi des Francs";
    titleInput.value = editing?.title ?? "";
    const titleField = el("div", "tl-field");
    titleField.append(el("label", "", "Titre exercé (facultatif)"), titleInput);
    box.appendChild(titleField);

    function showChosen() {
      chosen.textContent = member
        ? member.name + (member.dynasty ? " · " + member.dynasty : "") + " (" + (member.birthYear ?? "?") + " – " + (member.deathYear ?? "?") + ")"
        : "Aucun souverain choisi.";
    }
    showChosen();
    let searchTimer: number | null = null;
    search.addEventListener("input", () => {
      if (searchTimer) window.clearTimeout(searchTimer);
      searchTimer = window.setTimeout(async () => {
        results.innerHTML = "";
        const list = await searchMembers(deps.supabase, search.value);
        for (const m of list) {
          const row = el("button", "tl-fiche-row");
          row.type = "button";
          row.textContent = m.name + (m.title ? " — " + m.title : "") + (m.dynasty ? " · " + m.dynasty : "") + " (" + (m.birthYear ?? "?") + " – " + (m.deathYear ?? "?") + ")";
          row.addEventListener("click", () => {
            member = m;
            if (!titleInput.value && m.title) titleInput.value = m.title;
            results.innerHTML = "";
            search.value = "";
            showChosen();
          });
          results.appendChild(row);
        }
        if (!list.length && search.value.trim().length >= 2) results.appendChild(el("div", "tl-note", "Aucun membre trouvé."));
      }, 250);
    });

    // Dates
    const startFields = buildDateFields("Début du règne");
    const endFields = buildDateFields("Fin du règne (vide = en cours ou inconnue)");
    box.append(startFields.el, endFields.el);
    if (editing) {
      fillDate(startFields.el, editing.start);
      if (editing.end) fillDate(endFields.el, editing.end);
    }

    // Sources (3 lignes)
    const srcBox = el("div", "tl-field");
    srcBox.appendChild(el("label", "", "Sources (au moins une ; « universitaire » = article, thèse, ouvrage d'historien)"));
    const rows: { label: HTMLInputElement; url: HTMLInputElement; academic: HTMLInputElement }[] = [];
    for (let i = 0; i < 3; i++) {
      const line = el("div", "tl-reign-src");
      const label = el("input");
      label.type = "text";
      label.placeholder = "Titre / auteur de la source";
      const url = el("input");
      url.type = "text";
      url.placeholder = "Lien (https://…)";
      const academicWrap = el("label", "tl-inline");
      const academic = el("input");
      academic.type = "checkbox";
      academicWrap.append(academic, document.createTextNode(" universitaire"));
      const s = editing?.sources[i];
      if (s) {
        label.value = s.label;
        url.value = s.url;
        academic.checked = s.academic;
      }
      line.append(label, url, academicWrap);
      srcBox.appendChild(line);
      rows.push({ label, url, academic });
    }
    box.appendChild(srcBox);

    const error = el("div", "tl-error");
    box.appendChild(error);
    const actions = el("div", "tl-actions");
    const save = el("button", "btn-small tl-primary", "Enregistrer");
    save.type = "button";
    const cancel = el("button", "btn-small", "Annuler");
    cancel.type = "button";
    actions.append(save, cancel);
    box.appendChild(actions);
    cancel.addEventListener("click", closeDialog);

    save.addEventListener("click", async () => {
      error.textContent = "";
      const session = deps.getSession();
      if (!session) return void (error.textContent = "Connexion requise.");
      if (!member) return void (error.textContent = "Choisis le souverain (recherche par nom).");
      const s = startFields.read();
      if (s.kind === "empty") return void (error.textContent = "Indique le début du règne.");
      if (s.kind === "error") return void (error.textContent = "Début : " + s.error);
      const e = endFields.read();
      if (e.kind === "error") return void (error.textContent = "Fin : " + e.error);
      const end = e.kind === "ok" ? e.date : null;
      if (end && dateSortKey(end) < dateSortKey(s.date)) return void (error.textContent = "La fin ne peut pas être avant le début.");
      const sources: ReignSource[] = rows
        .filter((r) => r.label.value.trim())
        .map((r) => ({ label: r.label.value.trim(), url: r.url.value.trim(), academic: r.academic.checked }));
      if (!sources.length) return void (error.textContent = "Indique au moins une source : sans source, le règne n'est pas enregistré.");
      save.disabled = true;
      try {
        const err = await saveReign(
          deps.supabase,
          { friseId, memberId: member.id, title: titleInput.value.trim() || null, start: s.date, end, sources },
          session.user.id,
          editing?.id
        );
        if (err) return void (error.textContent = err);
        closeDialog();
        await deps.onChanged();
      } finally {
        save.disabled = false;
      }
    });
    overlay.classList.add("open");
    search.focus();
  }

  return { renderRibbon, openDialog, closeCard };
}

// Remplit un bloc de date (friseDateFields) à partir d'une date existante.
function fillDate(root: HTMLElement, d: FriseDate) {
  const texts = root.querySelectorAll<HTMLInputElement>('input[type="text"]');
  const checks = root.querySelectorAll<HTMLInputElement>('input[type="checkbox"]');
  texts[0].value = String(Math.abs(d.year));
  checks[0].checked = d.year < 0;
  texts[1].value = d.month != null ? String(d.month) : "";
  texts[2].value = d.day != null ? String(d.day) : "";
  checks[1].checked = d.circa;
}

export { deleteReign };
