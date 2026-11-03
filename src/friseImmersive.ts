// ---------------------------------------------------------------------------
// Frises — navigation : mini-carte en bas (toute la frise + zone affichée, clic /
// glisser pour s'y rendre) et plein écran du navigateur. Ne lit que le DOM.
// ---------------------------------------------------------------------------

import "./friseImmersive.css";

export function initFriseImmersive(opts: { main: HTMLElement; scroll: HTMLElement; fullscreenBtn: HTMLElement }) {
  const { main, scroll } = opts;

  const mini = document.createElement("div");
  mini.id = "tl-minimap";
  const track = document.createElement("div");
  track.className = "tl-mini-track";
  const win = document.createElement("div");
  win.className = "tl-mini-win";
  mini.append(track, win);
  main.appendChild(mini);

  opts.fullscreenBtn.addEventListener("click", () => {
    if (document.fullscreenElement) void document.exitFullscreen();
    else void document.documentElement.requestFullscreen?.().catch(() => undefined);
  });

  const wrapEl = () => scroll.querySelector<HTMLElement>(".tl-band-wrap");

  /** À appeler après chaque rendu de la frise. */
  function refresh() {
    const wrap = wrapEl();
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
      t.style.background = dot.style.background || "#fff";
      track.appendChild(t);
    }
    updateWindow();
  }

  function updateWindow() {
    const wrap = wrapEl();
    if (!wrap || !wrap.offsetWidth) return;
    const total = wrap.offsetWidth;
    const a = Math.max(0, Math.min(1, (scroll.scrollLeft - wrap.offsetLeft) / total));
    const b = Math.max(0, Math.min(1, (scroll.scrollLeft + scroll.clientWidth - wrap.offsetLeft) / total));
    win.style.left = a * 100 + "%";
    win.style.width = Math.max(b - a, 0.008) * 100 + "%";
  }
  scroll.addEventListener("scroll", updateWindow, { passive: true });

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

  return { refresh };
}
