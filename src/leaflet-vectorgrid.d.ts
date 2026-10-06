// Déclaration ambient minimale pour leaflet.vectorgrid (pas de types
// officiels sur npm — plugin UMD qui étend la globale `L` au moment de
// l'import). On se contente de déclarer le module comme "sans exports
// typés" : src/historicalMap.ts caste explicitement `L` là où il a besoin
// d'accéder à `L.vectorGrid.protobuf(...)`, ce fichier sert juste à ce que
// `import "leaflet.vectorgrid";` compile sans erreur "module introuvable".
declare module "leaflet.vectorgrid";
