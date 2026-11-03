// ---------------------------------------------------------------------------
// Frises — mode immersif : la frise occupe tout l'écran. Les barres du haut
// (titre, boutons, légende) se cachent et réapparaissent quand la souris monte
// en haut de l'écran ; un titre flottant reste visible ; une mini-carte en bas
// montre toute la frise et la zone affichée (clic / glisser pour s'y rendre).
// Aucun accès à la base : ce module ne lit que le DOM de la frise.
// ---------------------------------------------------------------------------

import "./friseImmersive.css";

export function initFriseImmersive(opts: { view: HTMLElement; scroll: HTMLElement; toggleBtn: HTMLElement; fullscreenBtn: HTMLElement }) {
  const { view, scroll } = opts;
  const chrome = view.querySelector<HTMLElement>("#timeline-chrome")!;
  let immersive = true;
  try {
    immersive = localStorage.getItem("tl-immersive") !== "0";
  } catch {
    /* stockage indisponible */
  }

  // Titre flottant
  const floatTitle = document.createElement("div");
  floatTitle.id = "tl-float-title";
  view.appendChild(floatTitle);

  // Mini-carte
  const mini = document.createElement("div");
  mini.id = "tl-minimap";
  const track = document.createElement("div");
  track.className = "tl-mini-track";
  const win = document.createElement("div");
  win.className = "tl-mini-win";
  mini.append(track, win);
  view.appendChild(mini);

  function apply() {
    view.classList.toggle("tl-immersive", immersive);
    opts.toggleBtn.classList.toggle("active", immersive);
    opts.toggleBtn.textContent = immersive ? "Barres fixes" : "Immersif";
    if (!immersive) chrome.classList.remove("tl-chrome-open");
  }
  opts.toggleBtn.addEventListener("click", () => {
    immersive = !immersive;
    try {
      localStorage.setItem("tl-immersive", immersive ? "1" : "0");
    } catch {
      /* ignoré */
    }
    apply();
  });
  opts.fullscreenBtn.addEventListener("click", () => {
    if (document.fullscreenElement) void document.exitFullscreen();
    else void document.documentElement.requestFullscreen?.().catch(() => undefined);
  });

  // Les barres du haut se montrent quand la souris approche du bord supérieur (ou reste dessus).
  view.addEventListener("mousemove", (ev) => {
    if (!immersive) return;
    const open = chrome.classList.contains("tl-chrome-open");
    const limit = open ? chrome.offsetHeight + 12 : 14;
    if (ev.clientY <= limit) chrome.classList.add("tl-chrome-open");
    else if (open && !chrome.contains(document.activeElement as Node)) chrome.classList.remove("tl-chrome-open");
  });
  chrome.addEventListener("focusin", () => immersive && chrome.classList.add("tl-chrome-open"));

  function wrapEl(): HTMLElement | null {
    return scroll.querySelector<HTMLElement>(".tl-band-wrap");
  }

  /** À appeler après chaque rendu de la frise : reconstruit la mini-carte et le titre flottant. */
  function refresh() {
    const wrap = wrapEl();
    const title = view.querySelector<HTMLElement>("#timeline-title")?.textContent ?? "";
    const parent = view.querySelector<HTMLElement>(".tl-crumb:last-of-type")?.textContent ?? "";
    floatTitle.textContent = "";
    if (parent) {
      const p = document.createElement("span");
      p.textContent = parent + " › ";
      floatTitle.appendChild(p);
    }
    floatTitle.appendChild(document.createTextNode(title));
    track.innerHTML = "";
    if (!wrap || !wrap.offsetWidth) {
      mini.style.display = "none";
      return;
    }
    mini.style.display = "";
    const total = wrap.offsetWidth;
    for (const cell of wrap.querySelectorAll<HTMLElement>(".tl-cell")) {
      const seg = document.createElement("div");
      seg.className = "tl-mini-seg" + (cell.classList.contains("tl-gap") ? " gap" : "");
      seg.style.left = (cell.offsetLeft / total) * 100 + "%";
      seg.style.width = (cell.offsetWidth / total) * 100 + "%";
      seg.style.background = getComputedStyle(cell).backgroundColor;
      track.appendChild(seg);
    }
    for (const dot of wrap.querySelectorAll<HTMLElement>(".tl-dot")) {
      const t = document.createElement("span");
      t.className = "tl-mini-tick";
      t.style.left = (parseFloat(dot.style.left) / total) * 100 + "%";
      t.style.background = dot.style.background || dot.style.backgroundColor || "#fff";
      track.appendChild(t);
    }
    updateWindow();
  }

  function updateWindow() {
    const wrap = wrapEl();
    if (!wrap || !wrap.offsetWidth) return;
    const total = wrap.offsetWidth;
    const x0 = (scroll.scrollLeft - wrap.offsetLeft) / total;
    const x1 = (scroll.scrollLeft + scroll.clientWidth - wrap.offsetLeft) / total;
    const a = Math.max(0, Math.min(1, x0));
    const b = Math.max(0, Math.min(1, x1));
    win.style.left = a * 100 + "%";
    win.style.width = Math.max(b - a, 0.008) * 100 + "%";
  }
  scroll.addEventListener("scroll", updateWindow, { passive: true });

  // Clic ou glisser sur la mini-carte : le centre de l'écran va à cet endroit.
  function jump(clientX: number) {
    const wrap = wrapEl();
    if (!wrap) return;
    const r = mini.getBoundingClientRect();
    const frac = Math.max(0, Math.min(1, (clientX - r.left) / r.width));
    scroll.scrollLeft = wrap.offsetLeft + frac * wrap.offsetWidth - scroll.clientWidth / 2;
  }
  let dragging = false;
  mini.addEventListener("pointerdown", (ev) => {
    dragging = true;
    mini.setPointerCapture(ev.pointerId);
    jump(ev.clientX);
    ev.stopPropagation();
  });
  mini.addEventListener("pointermove", (ev) => dragging && jump(ev.clientX));
  mini.addEventListener("pointerup", () => (dragging = false));

  apply();
  return { refresh };
}
