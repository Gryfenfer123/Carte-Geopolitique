import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(103, "Bulgarie — suite des souverains (premier empire, Asen, Terter, Chichman)")
g.notes = [
    "Complète les arbres Krum, Asen et Chichman (créés en v46) et crée « Terter ». Rien n'est supprimé.",
    "Source : Wikipédia en anglais, « List of Bulgarian monarchs » (noms, filiations et règnes). La page ne donne aucune date de vie : seules les années de mort sûres sont renseignées (d'après les règnes), les naissances sont laissées vides plutôt qu'inventées (signalé).",
    "Non fait : Asparoukh et Tervel, Siméon-Samuel (Cométopoules), prétendants de Vidin, Mitso Asen, Smilets, Ivaylo, Tchaka (maisons non reliées à ces arbres), épouses.",
]
g.tree('BG_KRU', 'BGR', 'Krum')
g.tree('BG_ASE', 'BGR', 'Asen')
g.tree('BG_CHI', 'BGR', 'Chichman')
g.tree('BG_TER', 'BGR', 'Terter', section_title='Terter')
P = g.par
def M(code, name, d, title, dyn, tree, approx='Naissance inconnue.', leader=True):
    return g.m('bg2.' + code, name, None, d, title, dyn, tree, 'h', leader, approx=approx)
M('malamir', 'Malamir', 836, 'Khan de Bulgarie (831-836)', 'Krum', 'BG_KRU')
M('zvinitsa', 'Zvinitsa', None, 'Père de Presian Ier', 'Krum', 'BG_KRU', leader=False)
M('presian', 'Presian Ier', 852, 'Khan de Bulgarie (836-852)', 'Krum', 'BG_KRU')
M('vladimir', 'Vladimir', 893, 'Knèze de Bulgarie (889-893)', 'Krum', 'BG_KRU')
M('boris2', 'Boris II', None, 'Tsar de Bulgarie (969-977)', 'Krum', 'BG_KRU', approx='Naissance et mort incertaines (après 977).')
M('roman', 'Roman', 997, 'Tsar de Bulgarie (977-997)', 'Krum', 'BG_KRU')
M('ivan_asen1', 'Ivan Asen Ier', 1196, 'Tsar de Bulgarie (v. 1188-1196)', 'Asen', 'BG_ASE')
M('peter2', 'Pierre II (Théodore-Pierre)', 1197, 'Tsar de Bulgarie (1185-1197)', 'Asen', 'BG_ASE')
M('kaloyan', 'Kaloyan', 1207, 'Tsar de Bulgarie (1196-1207)', 'Asen', 'BG_ASE')
M('boril', 'Boril', None, 'Tsar de Bulgarie (1207-1218), neveu de Kaloyan', 'Asen', 'BG_ASE', approx='Naissance et mort inconnues (après 1218).')
M('michael_asen1', 'Michel Asen Ier', 1256, 'Tsar de Bulgarie (1246-1256)', 'Asen', 'BG_ASE')
M('constantine', 'Constantin Ier Tikh Asen', 1277, 'Tsar de Bulgarie (1257-1277)', 'Asen', 'BG_ASE')
M('michael_asen2', 'Michel Asen II', 1279, 'Tsar de Bulgarie (1277-1279)', 'Asen', 'BG_ASE')
M('george_t1', 'Georges Ier Terter', 1308, 'Tsar de Bulgarie (1280-1292)', 'Terter', 'BG_TER')
M('theodore_s', 'Théodore Svetoslav', 1322, 'Tsar de Bulgarie (1300-1322)', 'Terter', 'BG_TER')
M('george_t2', 'Georges II Terter', 1323, 'Tsar de Bulgarie (1322-1323)', 'Terter', 'BG_TER')
M('michael_s3', 'Michel III Chichman', 1330, 'Tsar de Bulgarie (1323-1330), mort à Velbazhd', 'Chichman', 'BG_CHI')
M('ivan_stephen', 'Ivan Stéphane', 1373, 'Tsar de Bulgarie (1330-1331)', 'Chichman', 'BG_CHI')
P(R('f50fa150'), 'bg2.malamir'); P('bg2.malamir' if False else R('f50fa150'), 'bg2.zvinitsa')
P('bg2.zvinitsa', 'bg2.presian'); P('bg2.presian', R('d39ce982'))
P(R('d39ce982'), 'bg2.vladimir')
P(R('aafcd9a8'), 'bg2.boris2'); P(R('aafcd9a8'), 'bg2.roman')
P('bg2.ivan_asen1', R('37c8c29c'))
g.fam('bg2.ivan_asen1', 'bg2.peter2'); g.fam('bg2.ivan_asen1', 'bg2.kaloyan'); g.fam('bg2.kaloyan', 'bg2.boril')
P(R('37c8c29c'), 'bg2.michael_asen1')
P('bg2.constantine', 'bg2.michael_asen2')
g.fam(R('37c8c29c'), 'bg2.constantine')
P('bg2.george_t1', 'bg2.theodore_s'); P('bg2.theodore_s', 'bg2.george_t2')
P('bg2.michael_s3', 'bg2.ivan_stephen'); g.fam('bg2.michael_s3', R('da935432'))
g.reposition = {'BG_KRU', 'BG_ASE', 'BG_CHI', 'BG_TER'}
g.write()
