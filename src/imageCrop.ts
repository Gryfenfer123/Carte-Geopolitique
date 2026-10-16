// ---------------------------------------------------------------------------
// Outil de recadrage d'image générique (demande de Martin, 2026-10-14 :
// "Pouvoir recadrer une image dans les catégories (pas possible
// actuellement)") — jusqu'ici, seule la bannière d'une catégorie/sous-
// catégorie de dossier pouvait être REPOSITIONNÉE (glisser pour changer
// object-position/background-position, voir attachBannerDragReframe dans
// dossier.ts), jamais vraiment RECADRÉE (rogner l'image à un rectangle
// choisi). Un outil de recadrage à rectangle déplaçable/redimensionnable,
// à ratio fixe, existait déjà pour les photos de membre d'arbre
// généalogique (openCropModal, genealogy.ts) — celui-ci en reprend
// exactement le même principe (rectangle borné à l'image affichée, poignée
// de coin bas-droit, conversion display→pixels réels au moment du rendu
// final sur un <canvas>), mais factorisé en module indépendant et
// réutilisable (genealogy.ts garde volontiers SON propre code, qui
// fonctionne déjà et n'a pas été touché, pour ne rien risquer dessus) :
// dossier.ts l'utilise pour les bannières de catégorie ET de sous-
// catégorie (ratio fixe = celui d'affichage de la bannière, demande de
// Martin confirmée explicitement : "ratio fixe").
//
// API : openImageCropModal(dataUrl, ratio, outW?) retourne une Promise qui
// se résout avec un File (JPEG) recadré si "Valider le cadrage" est
// cliqué, ou null si "Annuler"/fermeture. Le modal (HTML + CSS) est injecté
// une seule fois dans <body> au premier appel.
// ---------------------------------------------------------------------------

let injected = false;
let pendingResolve: ((file: File | null) => void) | null = null;
let openInternalRef: ((dataUrl: string, ratio: number, outW: number) => void) | null = null;

let cropNaturalW = 0;
let cropDisplayW = 0;
let cropDisplayH = 0;
let cropRect = { x: 0, y: 0, w: 0, h: 0 };
let cropDragMode: "move" | "resize" | null = null;
let cropDragStartX = 0;
let cropDragStartY = 0;
let cropStartRect = { x: 0, y: 0, w: 0, h: 0 };
let currentRatio = 1;
let currentOutW = 960;

function $(id: string): HTMLElement {
  return document.getElementById(id)!;
}

function ensureInjected() {
  if (injected) return;
  injected = true;
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="img-crop-modal" class="poi-overlay">
      <div class="poi-overlay-box gen-crop-box">
        <h3>Recadrer l'image</h3>
        <div id="img-crop-hint">Glissez le cadre pour le déplacer, la poignée (coin) pour le redimensionner.</div>
        <div id="img-crop-stage">
          <img id="img-crop-img" alt="">
          <div id="img-crop-rect"><div id="img-crop-handle"></div></div>
        </div>
        <div class="dossier-form-actions" style="margin-top:10px;">
          <button id="img-crop-confirm" class="btn-primary">Valider le cadrage</button>
          <button id="img-crop-cancel" class="btn-small">Annuler</button>
        </div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

  function paintCropRect() {
    const rectEl = $("img-crop-rect");
    rectEl.style.left = cropRect.x + "px";
    rectEl.style.top = cropRect.y + "px";
    rectEl.style.width = cropRect.w + "px";
    rectEl.style.height = cropRect.h + "px";
  }
  function closeModal(result: File | null) {
    $("img-crop-modal").classList.remove("open");
    const resolve = pendingResolve;
    pendingResolve = null;
    if (resolve) resolve(result);
  }
  $("img-crop-rect").addEventListener("mousedown", (e) => {
    if ((e.target as HTMLElement).id === "img-crop-handle") return;
    cropDragMode = "move";
    cropDragStartX = e.clientX;
    cropDragStartY = e.clientY;
    cropStartRect = { ...cropRect };
    e.preventDefault();
  });
  $("img-crop-handle").addEventListener("mousedown", (e) => {
    cropDragMode = "resize";
    cropDragStartX = e.clientX;
    cropDragStartY = e.clientY;
    cropStartRect = { ...cropRect };
    e.stopPropagation();
    e.preventDefault();
  });
  document.addEventListener("mousemove", (e) => {
    if (!cropDragMode) return;
    const dx = e.clientX - cropDragStartX;
    const dy = e.clientY - cropDragStartY;
    if (cropDragMode === "move") {
      const x = Math.max(0, Math.min(cropStartRect.x + dx, cropDisplayW - cropStartRect.w));
      const y = Math.max(0, Math.min(cropStartRect.y + dy, cropDisplayH - cropStartRect.h));
      cropRect = { ...cropStartRect, x, y };
    } else {
      let w = Math.max(40, cropStartRect.w + dx);
      w = Math.min(w, cropDisplayW - cropStartRect.x, (cropDisplayH - cropStartRect.y) * currentRatio);
      const h = w / currentRatio;
      cropRect = { x: cropStartRect.x, y: cropStartRect.y, w, h };
    }
    paintCropRect();
  });
  document.addEventListener("mouseup", () => {
    cropDragMode = null;
  });
  $("img-crop-cancel").addEventListener("click", () => closeModal(null));
  $("img-crop-confirm").addEventListener("click", () => {
    const img = $("img-crop-img") as HTMLImageElement;
    if (!cropDisplayW || !cropNaturalW) {
      closeModal(null);
      return;
    }
    const scale = cropNaturalW / cropDisplayW;
    const sx = cropRect.x * scale;
    const sy = cropRect.y * scale;
    const sw = cropRect.w * scale;
    const sh = cropRect.h * scale;
    const outW = currentOutW;
    const outH = Math.round(outW / currentRatio);
    const canvas = document.createElement("canvas");
    canvas.width = outW;
    canvas.height = outH;
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      closeModal(null);
      return;
    }
    ctx.drawImage(img, sx, sy, sw, sh, 0, 0, outW, outH);
    canvas.toBlob(
      (blob) => {
        closeModal(blob ? new File([blob], "image.jpg", { type: "image/jpeg" }) : null);
      },
      "image/jpeg",
      0.9
    );
  });

  function openInternal(dataUrl: string, ratio: number, outW: number) {
    currentRatio = ratio;
    currentOutW = outW;
    const img = $("img-crop-img") as HTMLImageElement;
    img.crossOrigin = "anonymous";
    img.src = dataUrl;
    img.onload = () => {
      cropNaturalW = img.naturalWidth;
      requestAnimationFrame(() => {
        const rect = img.getBoundingClientRect();
        cropDisplayW = rect.width;
        cropDisplayH = rect.height;
        let w = cropDisplayW;
        let h = w / ratio;
        if (h > cropDisplayH) {
          h = cropDisplayH;
          w = h * ratio;
        }
        cropRect = { x: (cropDisplayW - w) / 2, y: (cropDisplayH - h) / 2, w, h };
        paintCropRect();
      });
    };
    $("img-crop-modal").classList.add("open");
  }
  openInternalRef = openInternal;
}

// ratio = largeur / hauteur du rectangle de recadrage (ex. le ratio
// d'affichage de la bannière visée) ; outW = largeur en pixels de l'image
// finale produite (la hauteur en découle via ratio).
export function openImageCropModal(dataUrl: string, ratio: number, outW = 960): Promise<File | null> {
  ensureInjected();
  return new Promise((resolve) => {
    pendingResolve = resolve;
    openInternalRef!(dataUrl, ratio, outW);
  });
}

// Lit un File local (input[type=file] ou glisser-déposer) en data: URL,
// pour l'usage typique "on vient de choisir/déposer un fichier → on ouvre
// tout de suite le recadrage dessus".
export function readFileAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(file);
  });
}
