import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(65, "Allemagne — Habsbourg : branche de Toscane, liens avec les Wittelsbach, dates manquantes")
g.notes = [
    "Complète l'arbre Habsbourg (rien n'est supprimé) : relie les deux membres isolés (Auguste-Ferdinande, Louise-Antoinette) à leurs parents en créant la branche de Toscane (Ferdinand III, Léopold II, Ferdinand IV de Toscane) sous l'arbre Habsbourg-Lorraine (Autriche), rattache Marie-Anne de Bavière et Jeanne-Sophie à leurs parents Wittelsbach, complète les dates d'Éléonore de Gonzague et d'Éléonore d'Autriche.",
    "Auguste-Ferdinande et Louise-Antoinette sont DÉPLACÉES de l'arbre Habsbourg vers l'arbre Habsbourg-Lorraine (elles descendent de Léopold II) : elles restent visibles en « étrangères » dans l'arbre Habsbourg tant qu'elles ont un lien avec lui.",
    "Sources : Wikipédia en anglais (Ferdinand III, Léopold II et Ferdinand IV de Toscane ; Éléonore de Gonzague ; Éléonore d'Autriche ; Marie-Anne de Bavière ; Jeanne-Sophie).",
    "Les épouses sont créées dans l'arbre de leur propre maison quand il existe (Wettin, Bourbon-Siciles, Bourbon-Parme) ; leurs parents absents sont signalés pour l'Italie.",
    "Prérequis : v64 exécuté.",
]
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry=E('6b34bc03'))
g.tree('AT_HL', 'AUT', 'Habsbourg-Lorraine')
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('IT_BS', 'ITA', 'Maison de Bourbon-Siciles')
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=E('84c9f117'))
g.reposition = {'DE_HAB', 'AT_HL'}
P, S = g.par, g.sp

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

def A(code, name, b, d, title, dyn, g_, tree='AT_HL', leader=False, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

L2, ML = X('5c2c90'), X('2f5ade')                       # Léopold II (empereur) + Marie-Louise d'Espagne
TOS = 'Habsbourg-Lorraine (Toscane)'
A('ha.ferdinand3', 'Ferdinand III de Toscane', 1769, 1824, 'Grand-duc de Toscane', TOS, 'h')
kids([L2, ML], ['ha.ferdinand3'])
A('ha.luisa_naples', 'Louise de Naples et de Sicile', 1773, 1802, 'Grande-duchesse de Toscane', 'Bourbon-Siciles', 'f', 'IT_BS')
kids([X('8b9e28'), X('4ec820')], ['ha.luisa_naples'])
S('ha.ferdinand3', 'ha.luisa_naples')
A('ha.maria_ferdinanda', 'Marie-Ferdinande de Saxe', 1796, 1865, 'Grande-duchesse de Toscane (seconde épouse de Ferdinand III)', 'Wettin', 'f', 'DE_WET')
kids([X('7d231c'), X('be02f6')], ['ha.maria_ferdinanda'])
S('ha.ferdinand3', 'ha.maria_ferdinanda')
A('ha.leopold2_tos', 'Léopold II de Toscane', 1797, 1870, 'Grand-duc de Toscane', TOS, 'h')
kids(['ha.ferdinand3', 'ha.luisa_naples'], ['ha.leopold2_tos'])
A('ha.maria_anna_sax', 'Marie-Anne de Saxe (grande-duchesse de Toscane)', None, 1832, 'Grande-duchesse de Toscane', 'Wettin', 'f', 'DE_WET', approx='naissance non donnée par la page de Léopold II de Toscane')
kids([X('7d231c'), X('be02f6')], ['ha.maria_anna_sax'])
S('ha.leopold2_tos', 'ha.maria_anna_sax')
A('ha.maria_antonia_ds', 'Marie-Antonia des Deux-Siciles', None, None, 'Grande-duchesse de Toscane (seconde épouse de Léopold II)', 'Bourbon-Siciles', 'f', 'IT_BS',
  flag='Ses parents (François Ier des Deux-Siciles et Marie-Isabelle d\'Espagne) sont à ajouter avec l\'arbre des Deux-Siciles', approx='dates non données par la page de Léopold II de Toscane')
S('ha.leopold2_tos', 'ha.maria_antonia_ds')
# Auguste-Ferdinande : fille de Léopold II de Toscane (mère déduite des dates de mariage)
g.move('wi.auguste_f', 'AT_HL', 'Habsbourg-Lorraine (Toscane)')
kids(['ha.leopold2_tos', 'ha.maria_anna_sax'], ['wi.auguste_f'])
A('ha.ferdinand4', 'Ferdinand IV de Toscane', 1835, 1908, 'Dernier grand-duc de Toscane', TOS, 'h')
kids(['ha.leopold2_tos', 'ha.maria_antonia_ds'], ['ha.ferdinand4'])
A('ha.anne_saxe', 'Anne de Saxe (grande-duchesse de Toscane)', 1836, 1859, 'Grande-duchesse de Toscane (première épouse de Ferdinand IV)', 'Wettin', 'f', 'DE_WET')
kids([X('261ab7'), X('2b873f')], ['ha.anne_saxe'])
S('ha.ferdinand4', 'ha.anne_saxe')
A('ha.alice_parme', 'Alice de Bourbon-Parme', 1849, 1935, 'Grande-duchesse de Toscane (seconde épouse de Ferdinand IV)', 'Bourbon-Parme', 'f', 'IT_PAR',
  flag='Son père (Charles III de Parme) est à ajouter avec l\'arbre de Parme')
S('ha.ferdinand4', 'ha.alice_parme')
# Louise-Antoinette : déplacée vers l'arbre Habsbourg-Lorraine
g.movex(X('7215d7'), 'AT_HL', TOS)
kids(['ha.ferdinand4', 'ha.alice_parme'], [X('7215d7')])

# ---------- liens avec les Wittelsbach ----------
kids([X('e567ae'), X('bd87f6')], [X('ec4532')])           # Marie-Anne de Bavière (1574) : fille de Guillaume V et Renée de Lorraine
# Jeanne-Sophie de Bavière (1373-1410) : fille d'Albert Ier de Hainaut-Bavière et de Marguerite de Brzeg
kids([X('200c82'), X('142ffe')], [X('fa79ec')])
# dates manquantes sur des membres déjà en base (jamais de remplacement d'une date existante)
g.xsetdates(X('e2b87c'), 1598, 1655)                      # Éléonore de Gonzague (épouse de Ferdinand II)
g.xsetdates(X('cc0333'), 1498, 1558)                      # Éléonore d'Autriche (reine de Portugal puis de France)

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
