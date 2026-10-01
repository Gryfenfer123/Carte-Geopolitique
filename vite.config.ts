import { defineConfig } from "vite";

// Le site est publié sur GitHub Pages sous un sous-dossier
// (https://<pseudo>.github.io/Carte-Geopolitique/), pas à la racine du
// domaine : sans ce `base`, Vite génère des chemins absolus vers /assets/...
// au lieu de /Carte-Geopolitique/assets/..., d'où la page blanche avec des
// 404 sur le JS/CSS observée après le premier déploiement.
export default defineConfig({
  base: "/Carte-Geopolitique/",
});
