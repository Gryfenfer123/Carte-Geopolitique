"""Générateur de scripts SQL d'arbres généalogiques (Carte Géopolitique).
Usage : from lib import *; g = Gen(39, "Pologne") ; g.tree(...) ; g.m(...) ; g.par/sp(...) ; g.write()
Les identifiants sont déterministes (uuid5) : un script ultérieur peut donc retrouver les membres créés par un script précédent
(registre data/registry.json)."""
import json, os, re, uuid, subprocess, sys

NS = uuid.UUID('6f0c1a5e-7d52-4c2e-9d41-2a1b1c0de001')
ADMIN = '96d2f891-6b9e-4967-89ed-18f83270ef28'
CAT = '428a2e75-c8e3-51a1-b12a-bfe7a4018659'
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
SNAP = json.load(open(os.path.join(HERE, 'data', 'db.json')))
REGF = os.path.join(HERE, 'data', 'registry.json')
REG = json.load(open(REGF)) if os.path.exists(REGF) else {'members': {}, 'trees': {}, 'flags': [], 'scripts': {}}

REG.setdefault('xmoved', {})
MEM = {m[0]: m for m in SNAP['m']}            # id -> [id, owner, name, b, d, title, dyn, photo]
ENT = {e[0]: e for e in SNAP['e']}
BYTREE = {}
for m in SNAP['m']:
    BYTREE.setdefault(m[1], []).append(m[0])
RELS = SNAP['r']                               # [a, b, 'p'|'s'|'h']


def uid(key):
    return str(uuid.uuid5(NS, key))


def X(prefix):
    """Retrouve un membre DÉJÀ présent dans la base (copie du 23/10) par préfixe d'identifiant."""
    c = [i for i in MEM if i.startswith(prefix)]
    if len(c) != 1:
        raise SystemExit(f'X({prefix}) -> {len(c)} résultats')
    return 'x:' + c[0]


def R(prefix):
    """Retrouve un membre existant par préfixe d'identifiant, qu'il vienne de la copie de la base (X) ou d'un script précédent (code du registre)."""
    c = [k for k, v in REG['members'].items() if v['id'].startswith(prefix)]
    if len(c) == 1:
        return c[0]
    return X(prefix)


def Xname(name, b=None, tree_prefix=None):
    c = [m for m in SNAP['m'] if m[2] == name and (b is None or m[3] == b) and (tree_prefix is None or ENT.get(m[1], [''])[0].startswith(tree_prefix) or m[1].startswith(tree_prefix))]
    if len(c) != 1:
        raise SystemExit(f'Xname({name},{b},{tree_prefix}) -> {len(c)}: {[(x[0][:8], x[1][:8], x[2], x[3]) for x in c]}')
    return 'x:' + c[0][0]


def find(pat, tree=None):
    """Aide à la recherche (affichage)."""
    r = re.compile(pat, re.I)
    for m in SNAP['m']:
        if r.search(m[2] or '') and (tree is None or m[1].startswith(tree)):
            e = ENT.get(m[1])
            print(m[0][:8], (e[2] if e else m[1])[:24], '|', m[2], m[3], m[4], '|', (m[5] or '')[:44])


def q(s):
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def n(v):
    return 'null' if v is None else str(v)


def ph(path):
    if not path:
        return None
    base = 'https://upload.wikimedia.org/wikipedia/'
    if '/thumb/' in path:
        return base + path + '/330px-' + path.split('/')[-1]
    return base + path


class Gen:
    def __init__(self, num, label):
        self.num = num
        self.label = label
        self.trees = {}      # key -> dict
        self.M = []          # nouveaux membres
        self.R = []          # relations (a, b, type)
        self.code2id = {}
        self.flags = []      # (nom, naissance, arbre, raison)
        self.notes = []      # lignes de commentaire pour l'en-tête
        self.dateflags = []  # dates approximatives / incertaines
        self.pins = []       # (code, tree) membres épinglés sans lien
        self.setb = []       # (id, sources) à ajouter aux notes
        self.setd = []       # (code, naissance, mort) dates à corriger/compléter sur un membre déjà créé
        self.xmoves = []     # (id, tree, dynasty) membres de la base déplacés
        self.xsetd = []      # (id, naissance, mort) dates à COMPLÉTER sur un membre déjà en base (jamais écraser une date existante)
        self.named = []      # liens vers un membre retrouvé par son nom (id non déterministe)
        self.moves = []      # (code, tree, dynasty) membres déjà créés qu'on rattache à leur vrai arbre

    # ---- arbres
    def tree(self, key, country, dynasty, entry=None, section_title=None):
        """entry = identifiant (complet) d'un arbre EXISTANT, sinon l'arbre sera créé sous Pays > Dynastie > section_title."""
        if entry is None and key in REG['trees']:
            entry = REG['trees'][key]['entry']
        t = dict(key=key, country=country, dynasty=dynasty, entry=entry, new=entry is None,
                 section_title=section_title or dynasty)
        if entry is None:
            print(f'>>> NOUVEL ARBRE créé : {key} ({dynasty}) — vérifier qu\'il n\'existe pas déjà (sinon passer entry=E(...))')
            t['entry'] = uid('tree:' + key)
            t['section'] = uid('section:' + key)
        else:
            assert entry in ENT or key in REG['trees'], f'arbre {entry} introuvable'
        self.trees[key] = t
        return t

    # ---- membres
    def m(self, code, name, b, d, title, dyn, tree, g=None, leader=False, photo=None, flag=None, approx=None, src=None):
        """src = source(s) de la fiche (texte/URL), écrite dans le champ Notes / biographie. g = 'f' ou 'h' (sexe, pour la mise en page seulement). approx = commentaire sur une date incertaine."""
        assert code not in self.code2id and code not in REG['members'], f'code en double {code}'
        i = uid('member:' + code)
        self.code2id[code] = i
        self.M.append(dict(code=code, id=i, name=name, b=b, d=d, title=title, dyn=dyn, tree=tree, g=g, leader=leader, photo=ph(photo), src=src))
        if flag:
            self.flags.append((name, b, tree, flag))
        if approx:
            self.dateflags.append((name, b, d, approx))
        return code

    def ref(self, c):
        """code -> identifiant complet (nouveau membre, membre d'un script précédent, ou membre existant 'x:uuid')."""
        if c.startswith('x:'):
            return c[2:]
        if c in self.code2id:
            return self.code2id[c]
        if c in REG['members']:
            return REG['members'][c]['id']
        raise SystemExit(f'code inconnu {c}')

    def move(self, code, tree, dyn=None):
        """Déplace un membre créé par un script précédent vers son vrai arbre (il reste visible dans l'ancien comme membre étranger)."""
        assert code in REG['members'], code
        self.moves.append((code, tree, dyn))
        REG['members'][code]['tree'] = tree
        if dyn:
            REG['members'][code]['dyn'] = dyn

    def link_named(self, parent_code, child_name, birth, ptype='parent'):
        """Lien parent -> enfant dont l'enfant est un membre déjà en base retrouvé par nom + année de naissance."""
        self.named.append((parent_code, child_name, birth, ptype))

    def link_named_parent(self, child_code, parent_name, birth):
        """Lien parent -> enfant dont le PARENT est un membre déjà en base retrouvé par nom + année de naissance."""
        self.named.append((child_code, parent_name, birth, 'rev'))

    def movex(self, xcode, tree, dyn=None):
        """Déplace un membre DÉJÀ présent en base (code X(...)) vers un autre arbre (arbre cible non « étendu à droite »)."""
        i = xcode[2:]
        assert i in MEM, xcode
        self.xmoves.append((i, tree, dyn))
        REG['xmoved'][i] = tree

    def xsetdates(self, xcode, b, d):
        """Complète la naissance / la mort d'un membre DÉJÀ en base (code X(...)) quand elles sont vides ; ne remplace jamais une date existante."""
        i = xcode[2:]
        assert i in MEM, xcode
        self.xsetd.append((i, b, d))
        Gen.FIXB[i] = b if b is not None else MEM[i][3]

    def setdates(self, code, b, d):
        assert code in REG['members'], code
        self.setd.append((code, b, d))
        REG['members'][code]['b'] = b
        REG['members'][code]['d'] = d

    def setbio(self, code, src, i=None):
        """Ajoute « Sources : ... » aux notes d'un membre (code d'un script précédent, ou i = id complet) sans jamais effacer le texte existant ; sans effet si des sources y figurent déjà."""
        i = i or REG['members'][code]['id']
        self.setb.append((i, src))

    def pin(self, code, tree):
        self.pins.append((code, tree))

    def par(self, a, b):
        self.R.append((a, b, 'parent'))

    def fam(self, a, b):
        self.R.append((a, b, 'family'))

    def sp(self, a, b):
        self.R.append((a, b, 'spouse'))

    # ---- infos d'un membre (pour la mise en page)
    def info(self, c):
        i = self.ref(c)
        for mm in self.M:
            if mm['id'] == i:
                return dict(id=i, name=mm['name'], b=mm['b'], d=mm['d'], title=mm['title'], g=mm['g'], tree=mm['tree'])
        for k, v in REG['members'].items():
            if v['id'] == i:
                return dict(id=i, name=v['name'], b=v['b'], d=v['d'], title=v.get('title'), g=v.get('g'), tree=v['tree'])
        if i in MEM:
            m = MEM[i]
            return dict(id=i, name=m[2], b=m[3], d=m[4], title=m[5], g=None, tree=m[1])
        raise SystemExit('info ' + c)

    def tree_entry(self, key):
        return self.trees[key]['entry'] if key in self.trees else REG['trees'][key]['entry']

    # ---- mise en page
    def layout(self):
        """Calcule les positions par arbre (module genealogyLayout compilé) ; renvoie {tree_key: {member_id: (x,y)}}."""
        allrels = []  # (a_id, b_id, type)
        for a, b, t in self.R:
            allrels.append((self.ref(a), self.ref(b), t))
        # relations déjà en base
        for a, b, t in RELS:
            if t in ('p', 's'):
                allrels.append((a, b, 'parent' if t == 'p' else 'spouse'))
        for k, v in REG.get('rels', {}).items():
            pass
        for r in REG.get('relist', []):
            allrels.append(tuple(r))
        out = {}
        jobs = {}
        for key, t in self.trees.items():
            if self.is_append(key):
                continue
            entry = t['entry']
            local = {}
            for mm in self.M:
                if mm['tree'] == key:
                    local[mm['id']] = mm
            for k, v in REG['members'].items():
                if v['tree'] == key:
                    local[v['id']] = v
            if not t['new']:
                for i in BYTREE.get(entry, []):
                    if REG['xmoved'].get(i, key) != key:
                        continue
                    m = MEM[i]
                    local[i] = dict(id=i, name=m[2], b=m[3], d=m[4], title=m[5], g=None)
            for i, tk in REG['xmoved'].items():
                if tk == key:
                    m = MEM[i]
                    local[i] = dict(id=i, name=m[2], b=m[3], d=m[4], title=m[5], g=None)
            # membres voisins (un cran) hors de l'arbre
            nodes = {}
            for i, v in local.items():
                nodes[i] = dict(id=i, name=v['name'], birth=self.FIXB.get(i, v['b']), death=v['d'], title=v.get('title'), g=v.get('g'))
            rels = []
            for a, b, ty in allrels:
                if a in local or b in local:
                    for z in (a, b):
                        if z not in nodes:
                            nodes[z] = self._node(z)
                    rels.append(dict(a=a, b=b, type=ty))
            for pc, pt in list(self.pins) + [tuple(x) for x in REG.get('pins', [])]:
                if pt == key:
                    z = self.ref(pc) if not (len(pc) == 36 and pc.count('-') == 4) else pc
                    if z not in nodes:
                        nodes[z] = self._node(z)
            seen = set(); rr = []
            for r in rels:
                kk = (r['a'], r['b'], r['type'])
                if kk not in seen:
                    seen.add(kk); rr.append(r)
            jobs[key] = dict(nodes=list(nodes.values()), rels=rr, local=list(local.keys()))
        inp = json.dumps(jobs)
        res = subprocess.run(['node', os.path.join(HERE, 'outils', 'layout_run.mjs')], input=inp, capture_output=True, text=True)
        if res.returncode != 0:
            raise SystemExit(res.stderr)
        pos = json.loads(res.stdout)
        for key in pos:
            self.separate(pos[key])
        self.jobs = jobs
        for key in self.trees:
            if self.is_append(key):
                pos[key] = {}
                k = 0
                for mm in self.M:
                    if mm['tree'] == key:
                        pos[key][mm['id']] = (30000 + max(0, self.num - 40) * 6000 + k * 340, ((mm['b'] or 1300) - 1000) * 18)
                        k += 1
        return pos

    def separate(self, p):
        ids = list(p.keys())
        for _ in range(200):
            moved = False
            for i, a in enumerate(ids):
                for b in ids[i + 1:]:
                    ax, ay = p[a]; bx, by = p[b]
                    if abs(ax - bx) < 340 and abs(ay - by) < 380:
                        if bx >= ax:
                            p[b] = [ax + 380, by]
                        else:
                            p[a] = [bx + 380, ay]
                        moved = True
            if not moved:
                break

    def is_append(self, key):
        t = self.trees[key]
        if getattr(self, 'sans_repositionnement', False):
            return True   # lot « sources » : on ne touche jamais aux positions des cartes
        if t['new']:
            return False
        if key in getattr(self, 'reposition', set()):
            return False
        if REG['trees'].get(key, {}).get('script') is not None and key in REG['trees']:
            return False
        return True

    FIXB = {}

    def _node(self, i):
        n = self._node0(i)
        if i in self.FIXB:
            n['birth'] = self.FIXB[i]
        return n

    def _node0(self, i):
        for mm in self.M:
            if mm['id'] == i:
                return dict(id=i, name=mm['name'], birth=mm['b'], death=mm['d'], title=mm['title'], g=mm['g'])
        for k, v in REG['members'].items():
            if v['id'] == i:
                return dict(id=i, name=v['name'], birth=v['b'], death=v['d'], title=v.get('title'), g=v.get('g'))
        m = MEM.get(i)
        if m:
            return dict(id=i, name=m[2], birth=m[3], death=m[4], title=m[5], g=None)
        raise SystemExit('nœud inconnu ' + i)

    # ---- écriture
    def write(self, header_extra=''):
        pos = self.layout()
        # Migrations d'avant le 23/10 (v1-v60) : ancien nommage ; ensuite : supabase/arbres/arbres_vN.sql (voir docs/CHANTIERS.md)
        if self.num <= 60:
            nom = f'schema_v{self.num}.sql'
            fname = os.path.join(REPO, 'supabase', nom)
        else:
            nom = f'arbres_v{self.num}.sql'
            fname = os.path.join(REPO, 'supabase', 'arbres', nom)
        newids = {mm['id'] for mm in self.M}
        used_ext = set()
        for a, b, t in self.R:
            for c in (a, b):
                i = self.ref(c)
                if i not in newids:
                    used_ext.add(i)
        o = []
        o.append(f'-- {nom} — {self.label}')
        o.append('-- Ajouts uniquement : rien n\'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).')
        for ln in self.notes:
            o.append('-- ' + ln)
        if header_extra:
            o.append(header_extra)
        o.append('-- À lancer UNE fois dans Supabase -> SQL Editor -> Run. Le script s\'arrête sans rien écrire si une vérification échoue.')
        o.append('-- Ensuite, sur le site, ouvre chaque arbre créé et vérifie ; « Organiser par dates » remet l\'ordre si tu déplaces des cartes.')
        o.append('')
        o.append('do $$')
        o.append('declare')
        o.append(f"  admin_id constant uuid := '{ADMIN}';")
        o.append(f"  cat_id constant uuid := '{CAT}';")
        o.append('  top uuid;')
        o.append('  sec uuid;')
        o.append('  k int;')
        o.append('  ext uuid;')
        o.append('begin')
        first = self.M[0]['id'] if self.M else None
        if first:
            o.append(f"  if exists (select 1 from public.genealogy_members where id = '{first}') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;")
        # vérification des membres existants référencés
        if used_ext:
            ids = ','.join(q(i) for i in sorted(used_ext))
            o.append(f"  select count(*) into k from public.genealogy_members where id in ({ids});")
            o.append(f"  if k <> {len(used_ext)} then raise exception 'Membres préexistants manquants (% sur {len(used_ext)}) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;")
        # arbres
        for key, t in self.trees.items():
            if t['new']:
                o.append(f"  -- Arbre « {t['dynasty']} » ({t['country']})")
                o.append(f"  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = {q(t['country'])} and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;")
                o.append(f"  if top is null then raise exception 'Section Dynastie introuvable pour {t['country']} : rien n''a été fait.'; end if;")
                o.append(f"  select id into sec from public.dossier_sections where parent_section_id = top and title = {q(t['section_title'])};")
                o.append(f"  if sec is null then")
                o.append(f"    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)")
                o.append(f"    values ('{t['section']}', cat_id, 'country', {q(t['country'])}, top, {q(t['section_title'])}, (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);")
                o.append(f"    sec := '{t['section']}';")
                o.append("  end if;")
                o.append(f"  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)")
                o.append(f"  values ('{t['entry']}', 'country', {q(t['country'])}, 'genealogy', {q(t['dynasty'])}, cat_id, sec, admin_id);")
            else:
                o.append(f"  select count(*) into k from public.dossier_entries where id = '{t['entry']}' and type = 'genealogy';")
                o.append(f"  if k <> 1 then raise exception 'Arbre {t['dynasty'].replace(chr(39), chr(39)*2)} introuvable : rien n''a été fait.'; end if;")
        # membres
        for mm in self.M:
            e = self.tree_entry(mm['tree'])
            x, y = pos[mm['tree']].get(mm['id'], (0, 0))
            o.append(f"  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('{mm['id']}', 'entry', '{e}', {q(mm['name'])}, {q(mm['photo'])}, {n(mm['b'])}, {n(mm['d'])}, {q(mm['title'])}, {q(mm['dyn'])}, {q(('Sources : ' + mm['src']) if mm.get('src') else None)}, {x}, {y}, admin_id, {'true' if mm['leader'] else 'false'});")
        o.append("  perform set_config('app.admin', admin_id::text, true);")
        o.append("""  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;""")
        for a, b, t in self.R:
            o.append(f"  perform pg_temp.rel('{self.ref(a)}', '{self.ref(b)}', '{t}');")
        for pc, nm, bb, ty in self.named:
            o.append(f"  select id into ext from public.genealogy_members where name = {q(nm)} and birth_year = {bb} limit 1;")
            call = f"pg_temp.rel(ext, '{self.ref(pc)}', 'parent')" if ty == 'rev' else f"pg_temp.rel('{self.ref(pc)}', ext, '{ty}')"
            o.append(f"  if ext is not null then perform {call}; else raise notice 'Membre introuvable (script précédent non exécuté ?) : {nm.replace(chr(39), chr(39)*2)}'; end if;")
        # repositionnement des membres existants des arbres étendus
        repos = []
        for key, t in self.trees.items():
            if not t['new'] and not self.is_append(key):
                ids = [i for i in BYTREE.get(t['entry'], []) if REG['xmoved'].get(i, key) == key] + [v['id'] for v in REG['members'].values() if v['tree'] == key]
                ids += [i for i, tk in REG['xmoved'].items() if tk == key and i not in ids]   # membres venus d'un autre arbre (movex d'un script précédent)
                for i in ids:
                    if i in pos[key]:
                        x, y = pos[key][i]
                        repos.append((t['dynasty'], i, x, y))
        for dy, i, x, y in repos:
            o.append(f"  update public.genealogy_members set pos_x = {x}, pos_y = {y} where id = '{i}';")
        for i, tk, dyn in self.xmoves:
            assert tk in pos and pos[tk], 'arbre cible ' + tk + ' en mode « ajout à droite » : déplacement impossible'
            x, y = pos[tk].get(i, (0, 0))
            e = self.tree_entry(tk)
            dsql = f", dynasty = {q(dyn)}" if dyn else ''
            o.append(f"  update public.genealogy_members set owner_id = '{e}', pos_x = {x}, pos_y = {y}{dsql} where id = '{i}' and owner_type = 'entry';")
            o.append(f"  delete from public.genealogy_foreign_states where member_id = '{i}' and owner_type = 'entry' and owner_id = '{e}';")
        for i, b, d in self.xsetd:
            o.append(f"  update public.genealogy_members set birth_year = coalesce(birth_year, {n(b)}), death_year = coalesce(death_year, {n(d)}) where id = '{i}';")
        for i, src in self.setb:
            t = q('Sources : ' + src)
            o.append(f"  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then {t} when bio like '%Sources :%' then bio else bio || E'\\n\\n' || {t} end where id = '{i}';")
        for code, b, d in self.setd:
            o.append(f"  update public.genealogy_members set birth_year = {n(b)}, death_year = {n(d)} where id = '{REG['members'][code]['id']}';")
        for code, tk, dyn in self.moves:
            i = REG['members'][code]['id']
            x, y = pos[tk].get(i, (0, 0))
            e = self.tree_entry(tk)
            dsql = f", dynasty = {q(dyn)}" if dyn else ''
            o.append(f"  update public.genealogy_members set owner_id = '{e}', pos_x = {x}, pos_y = {y}{dsql} where id = '{i}' and owner_type = 'entry';")
            o.append(f"  delete from public.genealogy_foreign_states where member_id = '{i}' and owner_type = 'entry' and owner_id = '{e}';")
        # foreign states
        for key, t in self.trees.items():
            if self.is_append(key):
                continue
            local = set(self.jobs[key]['local'])
            for nd in self.jobs[key]['nodes']:
                if nd['id'] in local:
                    continue
                if nd['id'] not in pos[key]:
                    continue
                x, y = pos[key][nd['id']]
                o.append(f"  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('{nd['id']}', 'entry', '{t['entry']}', {x}, {y}, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;")
        o.append(f"  raise notice 'schema_v{self.num} : % membres ajoutés.', {len(self.M)};")
        o.append('end $$;')
        open(fname, 'w').write('\n'.join(o) + '\n')
        # registre
        for mm in self.M:
            REG['members'][mm['code']] = dict(id=mm['id'], name=mm['name'], b=mm['b'], d=mm['d'], tree=mm['tree'], title=mm['title'], g=mm['g'], script=self.num)
        for key, t in self.trees.items():
            REG['trees'][key] = dict(entry=t['entry'], country=t['country'], dynasty=t['dynasty'], script=self.num if t['new'] else REG['trees'].get(key, {}).get('script'))
        for a, b, t in self.R:
            REG.setdefault('relist', []).append((self.ref(a), self.ref(b), t))
        for pc, pt in self.pins:
            REG.setdefault('pins', [])
            if [self.ref(pc), pt] not in REG['pins']:
                REG['pins'].append([self.ref(pc), pt])
        for f in self.flags:
            REG['flags'].append(dict(name=f[0], b=f[1], tree=f[2], reason=f[3], script=self.num))
        for d in self.dateflags:
            REG.setdefault('dateflags', []).append(dict(name=d[0], b=d[1], d=d[2], note=d[3], script=self.num))
        REG['scripts'][str(self.num)] = dict(label=self.label, members=len(self.M), rels=len(self.R), trees=[t['dynasty'] + ' (' + t['country'] + ')' for t in self.trees.values() if t['new']])
        json.dump(REG, open(REGF, 'w'), ensure_ascii=False, indent=1)
        return fname
