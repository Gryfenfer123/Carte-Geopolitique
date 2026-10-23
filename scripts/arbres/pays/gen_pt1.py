import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(98, "Portugal — maison de Bourgogne (comtes puis rois, 1096-1383) et compléments Aviz")
g.notes = [
    "Nouvel arbre « Maison de Bourgogne (Portugal) » (aucun n'existait). Alphonse IV, Béatrice, Constance, Marie, Urraque, Bérengère, Jean Ier d'Aviz et Philippa de Lancastre y sont affichés (ils restent dans leur arbre d'origine). Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire du Portugal), aucune page consultée pour ce lot. Dates incertaines laissées vides ou signalées (Inès de Castro, Léonor Teles, Béatrice de Portugal, Thérèse Lourenço).",
    "Créées dans l'arbre de leur propre maison puis affichées ici : Thérèse de León (Castille-León), Mafalda de Savoie (Savoie), Dulce de Barcelone et Isabelle d'Aragon (Barcelone), Urraque et Béatrice de Castille (Castille). Épouses de familles sans arbre (Boulogne, Castro, Manuel, Teles, Lourenço) : placées ici et signalées.",
    "Ajouts Aviz : l'infant Pierre de Coimbra et l'infant Henri le Navigateur (fils de Jean Ier), reliés à leur père, à Philippa de Lancastre et à Isabelle de Coimbra.",
    "Non fait : enfants cadets non dynastiques, Bragance (suite), Habsbourg du Portugal, Saxe-Cobourg-Bragance.",
]
g.tree('PT_BOU', 'PRT', 'Maison de Bourgogne (Portugal)', section_title='Maison de Bourgogne')
g.tree('PT_AVI', 'PRT', "Maison d'Aviz", entry=E('efb44952'))
g.tree('ES_CAS', 'ESP', 'Maison d\'Ivrée', entry=E('4b5cbfc8'))
g.tree('ES_LEO', 'ESP', 'Castille-León', entry=E('149b6c25'))
g.tree('IT_SAV', 'ITA', 'Maison de Savoie')
g.tree('ES_BAR', 'ESP', 'Maison de Barcelone')
g.tree('GB_LAN', 'GBR', 'Maison de Lancastre')
P, S = g.par, g.sp
B = 'Maison de Bourgogne (Portugal)'
def M(code, name, b, d, title, g_='h', leader=False, approx=None, flag=None):
    return g.m('pb.' + code, name, b, d, title, B, 'PT_BOU', g_, leader, approx=approx, flag=flag)
def O(code, name, b, d, title, dyn, tree, g_='f', approx=None):
    g.m('pb.' + code, name, b, d, title, dyn, tree, g_, False, approx=approx)
    g.pin('pb.' + code, 'PT_BOU')

M('henri', 'Henri de Bourgogne, comte de Portugal', 1066, 1112, 'Comte de Portugal (1096-1112)', leader=True)
O('teresa', 'Thérèse de León, comtesse de Portugal', 1080, 1130, 'Comtesse puis régente de Portugal', "Maison d'Ivrée", 'ES_LEO')
M('afonso1', 'Alphonse Ier Henriques', 1109, 1185, 'Premier roi du Portugal (1139-1185)', leader=True)
O('mafalda', 'Mafalda de Savoie (reine du Portugal)', 1125, 1157, 'Reine du Portugal, épouse d\'Alphonse Ier', 'Maison de Savoie', 'IT_SAV')
M('sancho1', 'Sanche Ier le Colonisateur', 1154, 1211, 'Roi du Portugal (1185-1211)', leader=True)
O('dulce', 'Douce de Barcelone', 1160, 1198, 'Reine du Portugal, épouse de Sanche Ier', 'Maison de Barcelone', 'ES_BAR')
M('afonso2', 'Alphonse II le Gros', 1185, 1223, 'Roi du Portugal (1211-1223)', leader=True)
O('urraca', 'Urraque de Castille', 1187, 1220, 'Reine du Portugal, épouse d\'Alphonse II', "Maison d'Ivrée", 'ES_CAS')
M('sancho2', 'Sanche II le Capelo', 1209, 1248, 'Roi du Portugal (1223-1247), déposé', leader=True)
M('afonso3', 'Alphonse III le Boulonnais', 1210, 1279, 'Roi du Portugal (1248-1279), conquiert l\'Algarve', leader=True)
M('mathilde', 'Mathilde II de Boulogne', 1202, 1259, 'Reine du Portugal, première épouse d\'Alphonse III', 'f', flag='Maison de Boulogne : sans arbre')
O('beatriz_c', 'Béatrice de Castille (reine du Portugal)', 1242, 1303, 'Reine du Portugal, épouse d\'Alphonse III', "Maison d'Ivrée", 'ES_CAS')
M('dinis', 'Denis le Laboureur', 1261, 1325, 'Roi du Portugal (1279-1325)', leader=True)
O('isabel', 'Isabelle d\'Aragon (sainte Isabelle du Portugal)', 1271, 1336, 'Reine du Portugal, épouse de Denis', 'Maison de Barcelone', 'ES_BAR')
M('pedro1', 'Pierre Ier le Justicier', 1320, 1367, 'Roi du Portugal (1357-1367)', leader=True)
M('constanza', 'Constance Manuel', 1316, 1345, 'Première épouse de Pierre Ier', 'f', flag='Maison Manuel : sans arbre')
M('ines', 'Inès de Castro', 1325, 1355, 'Maîtresse puis épouse posthume de Pierre Ier, assassinée', 'f', approx='Naissance vers 1325 (incertaine).', flag='Maison de Castro : sans arbre')
M('teresa_l', 'Thérèse Lourenço', None, None, 'Mère de Jean Ier d\'Aviz', 'f', approx='Dates inconnues.', flag='Maison Lourenço : sans arbre')
M('fernando', 'Ferdinand Ier le Beau', 1345, 1383, 'Roi du Portugal (1367-1383), dernier de la maison', leader=True)
M('leonor', 'Léonor Teles', 1350, 1405, 'Reine du Portugal, épouse de Ferdinand Ier', 'f', approx='Naissance vers 1350 (incertaine).', flag='Maison Teles : sans arbre')
M('beatriz', 'Béatrice de Portugal (reine de Castille)', 1372, None, 'Héritière du Portugal, épouse de Jean Ier de Castille', 'f', approx='Mort après 1409 (date incertaine).')

# Aviz : compléments
g.m('pb.pedro_c', 'Pierre de Coimbra, duc de Coimbra', 1392, 1449, 'Infant, régent du Portugal (1439-1446)', 'Dynastie d\'Aviz', 'PT_AVI', 'h', False)
g.m('pb.henri_n', 'Henri le Navigateur', 1394, 1460, 'Infant, duc de Viseu, promoteur des Découvertes', 'Dynastie d\'Aviz', 'PT_AVI', 'h', False)

JB = R('7bb4dae9'); PHI = R('665e0fa9'); ED = R('84ab569c'); ISC = R('2f5f1293'); ISP = R('eeb207f2')
AIV = R('7845813e'); BEA = R('c5b4dc13'); CON = R('270f94e1'); MAR = R('5895d45c')
URR = R('9ea047aa'); BER = R('0373f6a9'); JCAS = R('833ac28e')
for x in [AIV, BEA, CON, MAR, URR, BER, JB, PHI, JCAS]:
    g.pin(x, 'PT_BOU')

P(R('a18b9641'), 'pb.teresa'); S('pb.henri', 'pb.teresa')
kids = lambda ps, cs: [P(p, c) for c in cs for p in ps]
kids(['pb.henri', 'pb.teresa'], ['pb.afonso1'])
S('pb.afonso1', 'pb.mafalda'); P(R('7579d46f'), 'pb.mafalda')
kids(['pb.afonso1', 'pb.mafalda'], ['pb.sancho1', URR])
S('pb.sancho1', 'pb.dulce'); P(R('09a0382a'), 'pb.dulce'); P(R('c9a47997'), 'pb.dulce')
kids(['pb.sancho1', 'pb.dulce'], ['pb.afonso2', BER])
S('pb.afonso2', 'pb.urraca'); P(R('cf451b38'), 'pb.urraca'); P(R('ccb29f99'), 'pb.urraca')
kids(['pb.afonso2', 'pb.urraca'], ['pb.sancho2', 'pb.afonso3'])
S('pb.afonso3', 'pb.mathilde'); S('pb.afonso3', 'pb.beatriz_c'); P(R('0ff20fb0'), 'pb.beatriz_c')
kids(['pb.afonso3', 'pb.beatriz_c'], ['pb.dinis'])
S('pb.dinis', 'pb.isabel'); P(R('376b55ce'), 'pb.isabel'); P(R('763283d5'), 'pb.isabel')
kids(['pb.dinis', 'pb.isabel'], [AIV, CON])
kids([AIV, BEA], ['pb.pedro1', MAR])
S('pb.pedro1', 'pb.constanza'); S('pb.pedro1', 'pb.ines')
kids(['pb.pedro1', 'pb.constanza'], ['pb.fernando'])
kids(['pb.pedro1', 'pb.teresa_l'], [JB])
S('pb.fernando', 'pb.leonor')
kids(['pb.fernando', 'pb.leonor'], ['pb.beatriz'])
S('pb.beatriz', JCAS)
kids([JB, PHI], ['pb.pedro_c', 'pb.henri_n'])
P('pb.pedro_c', ISC)
g.reposition = {'PT_BOU'}
g.write()
