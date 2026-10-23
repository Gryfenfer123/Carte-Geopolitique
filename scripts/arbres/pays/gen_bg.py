import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(46, "Bulgarie — Krum, Asen, Chichman, Saxe-Cobourg-Gotha ; Basarab Ier ajouté en Valachie")
g.notes = [
    "Crée sous Bulgarie > Dynastie : Krum (Krum -> Pierre Ier), Asen (Ivan Asen II, Kaliman Ier), Chichman (Ivan Alexandre -> Ivan Chichman), Saxe-Cobourg-Gotha (Ferdinand Ier -> Siméon II).",
    "Prudence : les dates des khans/tsars du haut Moyen Âge ne sont pas dans les fiches Wikipédia ; elles sont laissées vides plutôt qu'inventées. Pas inclus : Asparoukh, Térvel, Samuel (Cométopoules), Terter (données insuffisantes).",
    "Ajoute dans l'arbre Basarab (Roumanie) Basarab Ier et Nicolas Alexandre (père de Radu Ier) car Théodora de Valachie, épouse d'Ivan Alexandre, est la fille de Basarab Ier.",
    "Branche de Saxe-Cobourg-Koháry : Ferdinand (père d'August), August et Clémentine d'Orléans sont créés dans l'arbre Wettin (origine), Ferdinand Ier de Bulgarie démarre l'arbre bulgare ; liens avec François de Saxe-Cobourg-Saalfeld (v38) si présent.",
    "Anne-Marie (Hongrie) : Anne-Marie de Hongrie (impératrice de Bulgarie) est créée dans Árpád ; Marie-Louise de Bourbon-Parme dans Bourbon-Parme.",
    "Prérequis : v44 exécuté.",
]
g.tree('BG_KRU', 'BGR', 'Krum')
g.tree('BG_ASE', 'BGR', 'Asen')
g.tree('BG_CHI', 'BGR', 'Chichman')
g.tree('BG_SCG', 'BGR', 'Saxe-Cobourg-Gotha')
g.tree('RO_BAS', 'ROU', 'Basarab')
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('DE_WET', 'DEU', 'Wettin', entry='309f20ea-3b5d-453b-87f9-286b7f1e6c60')
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=E('84c9f117'))
g.tree('FR_ORL', 'FRA', 'Bourbon-Orléans', entry=E('786a379d'))
g.reposition = {'HU_ARP'}
Gen.FIXB = {uid('member:bg.ivan_asen2'): 1194, uid('member:bg.ivan_alex'): 1301, uid('member:bg.krum'): 755, uid('member:bg.omurtag'): 785,
            uid('member:bg.boris1'): 830, uid('member:bg.peter1'): 912, uid('member:bg.irene_l'): 910, uid('member:bg.maria_b1'): 835,
            uid('member:bg.theodora_w'): 1305, uid('member:bg.sarah'): 1315, uid('member:ro.basarab1'): 1270, uid('member:ro.nicholas_a'): 1300}
P, S = g.par, g.sp

# --- Basarab I et Nicolas Alexandre (Valachie)
g.m('ro.basarab1', 'Basarab Ier le Fondateur', 1270, 1352, 'Voïvode de Valachie (v. 1310-1352)', 'Basarab', 'RO_BAS', 'h', True, approx='naissance « vers 1270 » ; règne 1310/1320 - 1352')
g.m('ro.nicholas_a', 'Nicolas Alexandre de Valachie', None, 1364, 'Voïvode de Valachie (1352-1364)', 'Basarab', 'RO_BAS', 'h', True, approx='naissance inconnue')
P('ro.basarab1', 'ro.nicholas_a'); P('ro.nicholas_a', 'ro.radu1')

# --- Krum
KR = 'Krum'
g.m('bg.krum', 'Krum', None, 814, 'Khan de Bulgarie (v. 803-814)', KR, 'BG_KRU', 'h', True, approx='naissance inconnue (vers le milieu du VIIIe siècle)')
g.m('bg.omurtag', 'Omourtag', None, 831, 'Khan de Bulgarie (814-831)', KR, 'BG_KRU', 'h', True, approx='naissance inconnue')
g.m('bg.boris1', 'Boris Ier', None, 907, 'Knèze de Bulgarie (852-889), christianise la Bulgarie', KR, 'BG_KRU', 'h', True, approx='naissance inconnue')
g.m('bg.maria_b1', 'Maria (épouse de Boris Ier)', None, None, 'Princesse de Bulgarie', 'Origine inconnue', 'BG_KRU', 'f', flag='Origine inconnue : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('bg.simeon1', 'Siméon Ier le Grand', 864, 927, 'Knèze puis premier tsar de Bulgarie (893-927)', KR, 'BG_KRU', 'h', True, approx='naissance 864 ou 865')
g.m('bg.sursuvul', 'Maria Sursuvoul (épouse de Siméon Ier)', None, None, 'Tsarine de Bulgarie', 'Sursuvoul (noblesse bulgare)', 'BG_KRU', 'f', flag='Famille Sursuvoul (noblesse bulgare) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('bg.peter1', 'Pierre Ier de Bulgarie', None, 970, 'Tsar de Bulgarie (927-969)', KR, 'BG_KRU', 'h', True, approx='naissance inconnue (début du Xe siècle)')
g.m('bg.irene_l', 'Irène Lécapène (Maria)', None, None, 'Tsarine de Bulgarie', 'Lécapène (Byzance)', 'BG_KRU', 'f', flag='Maison Lécapène (Empire byzantin) : arbre à créer avec la Grèce ; naissance inconnue ; morte vers 965', approx='dates inconnues (morte vers le milieu des années 960)')
P('bg.krum', 'bg.omurtag'); g.fam('bg.omurtag', 'bg.boris1')
S('bg.boris1', 'bg.maria_b1')
P('bg.boris1', 'bg.simeon1'); P('bg.maria_b1', 'bg.simeon1')
S('bg.simeon1', 'bg.sursuvul')
P('bg.simeon1', 'bg.peter1'); P('bg.sursuvul', 'bg.peter1')
S('bg.peter1', 'bg.irene_l')

# --- Asen
AS = 'Asen'
g.m('bg.ivan_asen2', 'Ivan Asen II', None, 1241, 'Tsar de Bulgarie (1218-1241)', AS, 'BG_ASE', 'h', True, approx='naissance entre 1192 et 1196')
g.m('hu.anna_maria', 'Anne-Marie de Hongrie (impératrice de Bulgarie)', 1203, None, 'Tsarine de Bulgarie', 'Árpád', 'HU_ARP', 'f', approx='naissance 1203 ou 1204 ; mort non renseignée')
g.m('bg.irene_d', 'Irène Comnène Doukas', None, None, 'Tsarine de Bulgarie', 'Doukas (Épire)', 'BG_ASE', 'f', flag='Maison Doukas/Ange (Épire, Byzance) : arbre à créer avec la Grèce ; dates non renseignées', approx='dates inconnues')
g.m('bg.kaliman', 'Kaliman Ier Asen', 1234, 1246, 'Tsar de Bulgarie (1241-1246)', AS, 'BG_ASE', 'h', True)
P('hu.andrew2', 'hu.anna_maria'); P('hu.gertrude', 'hu.anna_maria')
S('bg.ivan_asen2', 'hu.anna_maria'); S('bg.ivan_asen2', 'bg.irene_d')
P('bg.ivan_asen2', 'bg.kaliman'); P('hu.anna_maria', 'bg.kaliman')

# --- Chichman
CH = 'Chichman'
g.m('bg.ivan_alex', 'Ivan Alexandre', None, 1371, 'Tsar de Bulgarie (1331-1371)', CH, 'BG_CHI', 'h', True, approx='naissance inconnue')
g.m('bg.theodora_w', 'Théodora de Valachie (Théophane)', None, None, 'Tsarine de Bulgarie (répudiée vers 1349)', 'Basarab', 'BG_CHI', 'f', approx='dates inconnues')
g.m('bg.sarah', 'Sarah-Théodora', None, None, 'Tsarine de Bulgarie', 'Origine juive convertie', 'BG_CHI', 'f', flag='Origine : juive convertie, sans arbre ; dates inconnues', approx='dates inconnues')
g.m('bg.michael_a4', 'Michel Asen IV', 1322, 1355, 'Co-tsar de Bulgarie', CH, 'BG_CHI', 'h', approx='naissance « vers 1322 »')
g.m('bg.ivan_asen4', 'Ivan Asen IV', 1326, 1349, 'Co-tsar de Bulgarie', CH, 'BG_CHI', 'h')
g.m('bg.sratsimir', 'Ivan Sratsimir', 1324, 1394, 'Tsar de Vidin', CH, 'BG_CHI', 'h', True, approx='naissance 1324 ou 1328 ; mort 1394 ou vers 1397')
g.m('bg.shishman', 'Ivan Chichman', 1350, 1395, 'Tsar de Bulgarie (1371-1395)', CH, 'BG_CHI', 'h', True, approx='naissance 1350 ou 1351')
g.m('bg.kira_maria', 'Kira Maria (épouse d\'Ivan Chichman)', None, None, 'Tsarine de Bulgarie', 'Origine bulgare', 'BG_CHI', 'f', flag='Origine bulgare incertaine : sans arbre ; dates inconnues', approx='dates inconnues (morte au début des années 1380)')
g.m('bg.dragana', 'Dragana Lazarević', None, None, 'Tsarine de Bulgarie', 'Lazarević (Serbie)', 'BG_CHI', 'f', flag='Lazarević (Serbie) : arbre à créer avec la Serbie ; dates non renseignées', approx='dates non renseignées')
P('ro.basarab1', 'bg.theodora_w')
S('bg.ivan_alex', 'bg.theodora_w'); S('bg.ivan_alex', 'bg.sarah')
for c in ('bg.michael_a4', 'bg.ivan_asen4', 'bg.sratsimir'):
    P('bg.ivan_alex', c); P('bg.theodora_w', c)
P('bg.ivan_alex', 'bg.shishman'); P('bg.sarah', 'bg.shishman')
S('bg.shishman', 'bg.kira_maria'); S('bg.shishman', 'bg.dragana')

# --- Saxe-Cobourg-Gotha (Bulgarie)
SC = 'Saxe-Cobourg-Gotha (Koháry)'
g.m('bg.ferdinand_sk', 'Ferdinand de Saxe-Cobourg-Koháry', 1785, 1851, 'Prince de Saxe-Cobourg-Koháry', 'Wettin (Saxe-Cobourg)', 'DE_WET', 'h')
g.m('bg.kohary', 'Marie-Antonie Koháry', 1797, 1862, 'Princesse de Saxe-Cobourg-Koháry', 'Koháry (Hongrie)', 'DE_WET', 'f', flag='Famille Koháry (noblesse hongroise) : sans arbre')
g.m('bg.august', 'August de Saxe-Cobourg et Gotha', 1818, 1881, 'Prince, père de Ferdinand Ier de Bulgarie', 'Wettin (Saxe-Cobourg-Koháry)', 'DE_WET', 'h')
g.m('bg.clementine', 'Clémentine d\'Orléans', 1817, 1907, 'Princesse de Saxe-Cobourg et Gotha', 'Bourbon-Orléans', 'FR_ORL', 'f')
g.m('bg.ferdinand', 'Ferdinand Ier de Bulgarie', 1861, 1948, 'Prince (1887) puis tsar de Bulgarie (1908-1918)', SC, 'BG_SCG', 'h', True)
g.m('bg.marie_louise', 'Marie-Louise de Bourbon-Parme', 1870, 1899, 'Princesse de Bulgarie', 'Bourbon-Parme', 'IT_PAR', 'f', approx='naissance 1870 (non revérifiée)')
g.m('bg.eleonore', 'Éléonore Reuss de Köstritz', 1860, 1917, 'Tsarine de Bulgarie', 'Reuss', 'BG_SCG', 'f', flag='Maison de Reuss (Allemagne) : sans arbre', approx='naissance 1860 (non revérifiée)')
g.m('bg.boris3', 'Boris III de Bulgarie', 1894, 1943, 'Tsar de Bulgarie (1918-1943)', SC, 'BG_SCG', 'h', True)
g.m('bg.cyril', 'Cyrille de Bulgarie', 1895, 1945, 'Prince de Preslav, régent (1943-1944)', SC, 'BG_SCG', 'h', approx='dates 1895-1945 (non revérifiées)')
g.m('bg.giovanna', 'Jeanne de Savoie (Giovanna)', 1907, 2000, 'Tsarine de Bulgarie', 'Savoie', 'BG_SCG', 'f', flag='Maison de Savoie (Italie) : arbre à créer avec l\'Italie ; dates non revérifiées', approx='dates 1907-2000 (non revérifiées)')
g.m('bg.simeon2', 'Siméon II de Bulgarie', 1937, None, 'Tsar de Bulgarie (1943-1946), Premier ministre (2001-2005)', SC, 'BG_SCG', 'h', True)
g.m('bg.margarita', 'Margarita Gómez-Acebo', 1935, None, 'Épouse de Siméon II', 'Gómez-Acebo (Espagne)', 'BG_SCG', 'f', flag='Famille Gómez-Acebo (noblesse espagnole) : sans arbre ; naissance non revérifiée', approx='naissance 1935 (non revérifiée)')
g.m('bg.marie_louise_b', 'Marie-Louise de Bulgarie', 1933, None, 'Princesse de Bulgarie', SC, 'BG_SCG', 'f')
g.link_named_parent('bg.ferdinand_sk', 'François de Saxe-Cobourg-Saalfeld', 1750)
S('bg.ferdinand_sk', 'bg.kohary')
P('bg.ferdinand_sk', 'bg.august'); P('bg.kohary', 'bg.august')
S('bg.august', 'bg.clementine'); P(X('86246879'), 'bg.clementine')
P('bg.august', 'bg.ferdinand'); P('bg.clementine', 'bg.ferdinand')
S('bg.ferdinand', 'bg.marie_louise'); S('bg.ferdinand', 'bg.eleonore')
P('ro.robert_p', 'bg.marie_louise')
for c in ('bg.boris3', 'bg.cyril'):
    P('bg.ferdinand', c); P('bg.marie_louise', c)
S('bg.boris3', 'bg.giovanna')
for c in ('bg.simeon2', 'bg.marie_louise_b'):
    P('bg.boris3', c); P('bg.giovanna', c)
S('bg.simeon2', 'bg.margarita')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
