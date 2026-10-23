import subprocess,json,sys,collections
def q(sql):
    r=subprocess.run(['psql','-h','/tmp/pg38','-p','5439','-U','postgres','-d','postgres','-At','-F','\t','-c',sql],capture_output=True,text=True)
    if r.returncode: print(r.stderr); sys.exit(1)
    return [l.split('\t') for l in r.stdout.strip().split('\n') if l]
ADM='96d2f891-6b9e-4967-89ed-18f83270ef28'
# membres créés par les scripts (created_by admin)
# arbres touchés : entrées créées par admin + celles qui ont des membres créés
mem={}
for r in q(f"select m.id,m.owner_id,m.name,coalesce(m.birth_year::text,''),coalesce(m.death_year::text,''),m.pos_x,m.pos_y from public.genealogy_members m where created_by='{ADM}'"):
    mem[r[0]]=r
trees=collections.defaultdict(list)
for i,r in mem.items(): trees[r[1]].append(r)
ent={r[0]:(r[1],r[2]) for r in q("select id,owner_id,title from public.dossier_entries")}
bad=0
# 1 chevauchements
for t,ms in trees.items():
    allm=q(f"select id,name,pos_x,pos_y from public.genealogy_members where owner_id='{t}'")
    fs=q(f"select f.member_id,m.name,f.pos_x,f.pos_y from public.genealogy_foreign_states f join public.genealogy_members m on m.id=f.member_id where f.owner_id='{t}'")
    pts=[(a[1],float(a[2]),float(a[3])) for a in allm if a[2]!='']+[(a[1]+' [étranger]',float(a[2]),float(a[3])) for a in fs if a[2]!='']
    ov=[(a[0],b[0]) for i,a in enumerate(pts) for b in pts[i+1:] if abs(a[1]-b[1])<300 and abs(a[2]-b[2])<340]
    print(ent.get(t,('?','?'))[1][:30],'| membres',len(allm),'| étrangers',len(fs),'| chevauchements',len(ov))
    for o in ov[:5]: print('   CHEV',o)
    bad+=len(ov)
# 2 cohérence des dates
rels=q("select a.name,a.birth_year,b.name,b.birth_year,r.relation_type,a.death_year,b.id from public.genealogy_relations r join public.genealogy_members a on a.id=r.member_a_id join public.genealogy_members b on b.id=r.member_b_id where a.created_by='%s' or b.created_by='%s'"%(ADM,ADM))
for a,ab,b,bb,t,ad,bid in rels:
    if t=='parent' and ab and bb and ab!='' and bb!='':
        d=int(bb)-int(ab)
        if d<14 or d>70: print('ÂGE parent',a,ab,'->',b,bb,d); bad+=1
    if t=='parent' and ad and bb and bb!='' and ad!='':
        if int(bb)>int(ad)+1: print('NAISSANCE APRÈS MORT du parent',a,ad,b,bb); bad+=1
    if t=='spouse' and ab and bb and ab!='' and bb!='':
        if abs(int(ab)-int(bb))>40: print('ÉCART conjoints',a,ab,b,bb); bad+=1
# 3 membres isolés (sans aucune relation) parmi les créés
rel_ids=set()
for r in q("select member_a_id,member_b_id from public.genealogy_relations"): rel_ids.update(r)
for i,r in mem.items():
    if i not in rel_ids: print('ISOLÉ',r[2]); bad+=1
# 4 homonymes dans un même arbre
cnt=collections.Counter((r[1],r[2]) for r in mem.values())
for k,v in cnt.items():
    if v>1: print('DOUBLON',k); bad+=1
print('problèmes:',bad)
