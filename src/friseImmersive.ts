// ---------------------------------------------------------------------------
// Frises — plein écran du navigateur. (La mini-carte « où en est-on » a été retirée à la demande de Martin,
// 2026-11-03 ; `refresh` est conservé pour ne pas toucher aux appels de frise.ts.)
// ---------------------------------------------------------------------------

export function initFriseImmersive(opts: { main: HTMLElement; scroll: HTMLElement; fullscreenBtn: HTMLElement }) {
  opts.fullscreenBtn.addEventListener("click", () => {
    if (document.fullscreenElement) void document.exitFullscreen();
    else void document.documentElement.requestFullscreen?.().catch(() => undefined);
  });
  return { refresh() {} };
}
