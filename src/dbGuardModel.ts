// Garde-fou des échanges avec la base — LOGIQUE PURE (sans DOM), testable.
// Audit du 2026-10-30 : ~68 écritures sur 125 ne lisaient pas la réponse de la base, donc l'écran
// annonçait « supprimé / enregistré » alors que la base avait refusé. Plutôt que de modifier chaque
// appel (conflits avec les autres conversations), `dbGuard.ts` observe toutes les requêtes et
// utilise ce fichier pour décider s'il faut prévenir Martin et avec quels mots.

export interface DbOutcome {
  method: string; // GET, POST, PATCH, DELETE, PUT, HEAD
  url: string;
  status: number; // 0 = pas de réponse (réseau coupé)
  code?: string; // code d'erreur PostgREST/Postgres, ex. « 42501 »
  message?: string; // message brut de la base
  affectedRows?: number | null; // lu dans l'en-tête Content-Range ; null = inconnu
}

const isRest = (url: string) => url.includes("/rest/v1/");
const isStorage = (url: string) => url.includes("/storage/v1/");

/** Cible une seule ligne (…?id=eq.xxx) : seul cas où « 0 ligne touchée » est forcément anormal. */
export function targetsSingleRow(url: string): boolean {
  return /[?&]id=eq\./.test(url);
}

/** Texte à montrer à Martin, ou null si la requête s'est bien passée / si l'échec est « normal ». */
export function describeFailure(o: DbOutcome): string | null {
  if (!isRest(o.url) && !isStorage(o.url)) return null; // connexion/compte : les formulaires gèrent déjà
  const write = o.method !== "GET" && o.method !== "HEAD";

  if (o.status === 0) return "Connexion à la base impossible : vérifie ta connexion internet. Rien n'a été enregistré.";

  if (o.status >= 200 && o.status < 300) {
    if ((o.method === "DELETE" || o.method === "PATCH") && o.affectedRows === 0 && targetsSingleRow(o.url)) {
      return o.method === "DELETE"
        ? "Rien n'a été supprimé : la base a refusé (droits insuffisants) ou l'élément n'existe déjà plus."
        : "Aucune modification n'a été enregistrée : la base a refusé (droits insuffisants) ou l'élément n'existe plus.";
    }
    return null;
  }

  // Lectures : un 404/406 est un résultat « rien trouvé » courant (.single()), pas une panne.
  if (!write && o.status !== 401 && o.status !== 403 && o.status < 500) return null;

  if (o.status === 401 || /jwt/i.test(o.message ?? "")) return "Ta session a expiré : reconnecte-toi, puis recommence.";
  if (o.code === "42501" || o.status === 403)
    return write
      ? "Tu n'as pas le droit de faire cette modification : la base l'a refusée. Rien n'a été enregistré."
      : "Tu n'as pas le droit de lire ces informations.";
  if (o.code === "23505") return "Cet élément existe déjà : rien n'a été enregistré.";
  if (o.code === "23503") return "Cet élément est lié à un autre ou renvoie à un élément absent : la base a refusé.";
  if (o.status >= 500) return "La base de données a rencontré une erreur. Réessaie dans un instant.";
  return (write ? "La base a refusé l'enregistrement" : "Le chargement a échoué") + (o.message ? " (" + o.message.slice(0, 120) + ")" : "") + ".";
}
