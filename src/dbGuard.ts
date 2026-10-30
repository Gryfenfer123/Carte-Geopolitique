// Garde-fou des échanges avec la base (voir dbGuardModel.ts pour le pourquoi). Branché dans
// supabase.ts comme `fetch` du client : TOUTE requête passe ici, sans toucher aux ~170 appels.
//  - une réponse d'erreur ou un réseau coupé → message visible en bas de l'écran ;
//  - pour les modifications/suppressions d'UNE ligne, on demande à la base combien de lignes ont
//    été touchées : une règle de sécurité (RLS) qui refuse sans erreur donne « 0 ligne » → on prévient.
import { describeFailure, type DbOutcome } from "./dbGuardModel";

const COOLDOWN_MS = 4000; // même message pas plus d'une fois toutes les 4 s (évite l'avalanche)
let lastMsg = "";
let lastAt = 0;
let toastEl: HTMLElement | null = null;
let hideTimer: number | undefined;

function ensureStyle() {
  if (document.getElementById("db-toast-style")) return;
  const s = document.createElement("style");
  s.id = "db-toast-style";
  s.textContent =
    "#db-toast{position:fixed;left:50%;bottom:28px;transform:translateX(-50%);z-index:100000;max-width:min(560px,calc(100vw - 32px));" +
    "background:#3a1410;color:#ffd9cf;border:1px solid #e8734a;border-radius:10px;padding:12px 16px;font:14px/1.4 'IBM Plex Sans',sans-serif;" +
    "box-shadow:0 6px 24px rgba(0,0,0,.5);display:none;cursor:pointer}#db-toast.open{display:block}";
  document.head.appendChild(s);
}

export function showDbError(message: string) {
  const now = Date.now();
  if (message === lastMsg && now - lastAt < COOLDOWN_MS) return;
  lastMsg = message;
  lastAt = now;
  ensureStyle();
  if (!toastEl) {
    toastEl = document.createElement("div");
    toastEl.id = "db-toast";
    toastEl.setAttribute("role", "alert");
    toastEl.title = "Cliquer pour fermer";
    toastEl.addEventListener("click", () => toastEl?.classList.remove("open"));
    document.body.appendChild(toastEl);
  }
  toastEl.textContent = message;
  toastEl.classList.add("open");
  window.clearTimeout(hideTimer);
  hideTimer = window.setTimeout(() => toastEl?.classList.remove("open"), 9000);
}

function report(o: DbOutcome) {
  const msg = describeFailure(o);
  if (msg) {
    console.warn("[base]", o.method, o.url.split("?")[0], o.status, o.code ?? "", o.message ?? "");
    showDbError(msg);
  }
}

export const guardedFetch: typeof fetch = async (input, init) => {
  const url = typeof input === "string" ? input : input instanceof URL ? input.href : input.url;
  const method = (init?.method ?? (typeof input === "object" && "method" in input ? input.method : "GET")).toUpperCase();
  const rest = url.includes("/rest/v1/");
  let nextInit = init;
  // Demander le nombre de lignes touchées (en-tête Content-Range) pour modifier/supprimer une ligne.
  if (rest && (method === "PATCH" || method === "DELETE") && /[?&]id=eq\./.test(url)) {
    const headers = new Headers(init?.headers);
    const prefer = headers.get("Prefer");
    if (!prefer || !/count=/.test(prefer)) headers.set("Prefer", (prefer ? prefer + "," : "") + "count=exact");
    nextInit = { ...init, headers };
  }
  let res: Response;
  try {
    res = await fetch(input, nextInit);
  } catch (e) {
    report({ method, url, status: 0 });
    throw e;
  }
  if (!url.includes("/rest/v1/") && !url.includes("/storage/v1/")) return res;
  const range = res.headers.get("Content-Range"); // « */3 » ou « 0-2/3 »
  const total = range?.split("/")[1];
  const affectedRows = total && total !== "*" ? Number(total) : null;
  if (res.ok) {
    report({ method, url, status: res.status, affectedRows });
  } else {
    let code: string | undefined;
    let message: string | undefined;
    try {
      const body = await res.clone().json();
      code = body?.code ?? undefined;
      message = body?.message ?? body?.error ?? undefined;
    } catch {
      /* corps non JSON : on garde le seul code HTTP */
    }
    report({ method, url, status: res.status, code, message });
  }
  return res;
};
