// Annuler / refaire — logique pure.
// On garde des états entiers (les documents sont immuables, donc ce sont de simples références,
// sans copie). Limite de 200 étapes : au-delà, les plus anciennes sont oubliées.

export type History<T> = {
  readonly current: T;
  push(next: T): void;
  /** Remplace l'état courant sans créer d'étape (regroupe les réglages continus : curseur, couleur…). */
  replace(next: T): void;
  undo(): T | null;
  redo(): T | null;
  canUndo(): boolean;
  canRedo(): boolean;
};

export function createHistory<T>(initial: T, limit = 200): History<T> {
  const past: T[] = [];
  let present = initial;
  let future: T[] = [];
  return {
    get current() {
      return present;
    },
    push(next: T) {
      past.push(present);
      if (past.length > limit) past.shift();
      present = next;
      future = [];
    },
    replace(next: T) {
      present = next;
    },
    undo() {
      const prev = past.pop();
      if (prev === undefined) return null;
      future.push(present);
      present = prev;
      return present;
    },
    redo() {
      const nxt = future.pop();
      if (nxt === undefined) return null;
      past.push(present);
      present = nxt;
      return present;
    },
    canUndo: () => past.length > 0,
    canRedo: () => future.length > 0,
  };
}
