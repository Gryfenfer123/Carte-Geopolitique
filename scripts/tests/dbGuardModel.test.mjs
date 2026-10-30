// Test de src/dbGuardModel.ts (logique pure). Lancer : npm run test:dbguard
import { describeFailure } from "../../node_modules/.cache/dbguard/dbGuardModel.js";
let fails = 0;
const t = (nom, o, attendu) => {
  const r = describeFailure(o);
  const ok = attendu === null ? r === null : typeof r === "string" && r.includes(attendu);
  if (!ok) { fails++; console.error("ÉCHEC", nom, "→", r); } else console.log("ok   ", nom);
};
const R = "https://x.supabase.co/rest/v1/";
t("lecture réussie", { method: "GET", url: R + "groups", status: 200 }, null);
t("lecture 406 (.single sans résultat) = normal", { method: "GET", url: R + "groups?id=eq.1", status: 406 }, null);
t("lecture 404 = normal", { method: "GET", url: R + "x", status: 404 }, null);
t("lecture 500 → prévient", { method: "GET", url: R + "x", status: 500 }, "erreur");
t("réseau coupé", { method: "POST", url: R + "x", status: 0 }, "Connexion");
t("écriture refusée 42501", { method: "POST", url: R + "x", status: 403, code: "42501" }, "pas le droit");
t("écriture 401 JWT", { method: "PATCH", url: R + "x?id=eq.1", status: 401, message: "JWT expired" }, "session a expiré");
t("doublon 23505", { method: "POST", url: R + "x", status: 409, code: "23505" }, "existe déjà");
t("lien 23503", { method: "DELETE", url: R + "x?id=eq.1", status: 409, code: "23503" }, "lié");
t("DELETE d'une ligne : 0 touchée → prévient", { method: "DELETE", url: R + "x?id=eq.9", status: 204, affectedRows: 0 }, "Rien n'a été supprimé");
t("PATCH d'une ligne : 0 touchée → prévient", { method: "PATCH", url: R + "x?id=eq.9", status: 204, affectedRows: 0 }, "Aucune modification");
t("DELETE d'une ligne : 1 touchée = ok", { method: "DELETE", url: R + "x?id=eq.9", status: 204, affectedRows: 1 }, null);
t("PATCH en masse 0 ligne = pas d'alerte", { method: "PATCH", url: R + "x?frise_id=eq.9", status: 204, affectedRows: 0 }, null);
t("compte/auth ignoré", { method: "POST", url: "https://x.supabase.co/auth/v1/token", status: 400 }, null);
t("stockage refusé", { method: "POST", url: "https://x.supabase.co/storage/v1/object/b/f", status: 403 }, "pas le droit");
t("insert OK", { method: "POST", url: R + "x", status: 201 }, null);
console.log(fails ? fails + " échec(s)" : "Tous les tests passent");
process.exit(fails ? 1 : 0);
