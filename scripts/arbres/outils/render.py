import subprocess,sys,html
def q(sql):
    r=subprocess.run(['psql','-h','/tmp/pg38','-p','5439','-U','postgres','-d','postgres','-At','-F','\t','-c',sql],capture_output=True,text=True)
    if r.returncode: print(r.stderr); sys.exit(1)
    return [l.split('\t') for l in r.stdout.strip().split('\n') if l]
title=sys.argv[1]; out=sys.argv[2]
tid=q(f"select id from public.dossier_entries where title='{title}' and type='genealogy' order by owner_id limit 1")[0][0]
P={}
for r in q(f"select id,name,birth_year,death_year,pos_x,pos_y,'L' from public.genealogy_members where owner_id='{tid}' and pos_x is not null"): P[r[0]]=r
for r in q(f"select m.id,m.name,m.birth_year,m.death_year,f.pos_x,f.pos_y,'F' from public.genealogy_foreign_states f join public.genealogy_members m on m.id=f.member_id where f.owner_id='{tid}'"): P.setdefault(r[0],r)
rel=q("select member_a_id,member_b_id,relation_type from public.genealogy_relations")
W=max(float(p[4]) for p in P.values())+400;H=max(float(p[5]) for p in P.values())+400
mx=min(float(p[4]) for p in P.values())-50; my=min(float(p[5]) for p in P.values())-50
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{(W-mx)/4:.0f}" height="{(H-my)/4:.0f}" viewBox="{mx} {my} {W-mx} {H-my}"><rect x="{mx}" y="{my}" width="99999" height="99999" fill="#0a0b14"/>']
for a,b,t in rel:
    if a in P and b in P:
        pa,pb=P[a],P[b]
        s.append(f'<line x1="{float(pa[4])+150}" y1="{float(pa[5])+170}" x2="{float(pb[4])+150}" y2="{float(pb[5])+170}" stroke="{"#c9a227" if t=="parent" else "#7a6af0"}" stroke-width="4" opacity=".7"/>')
for p in P.values():
    x,y=float(p[4]),float(p[5])
    s.append(f'<rect x="{x}" y="{y}" width="300" height="340" rx="10" fill="{"#1d2340" if p[6]=="L" else "#3a1d1d"}" stroke="#889" stroke-width="3"/><text x="{x+12}" y="{y+190}" font-size="34" fill="#fff">{html.escape(p[1][:24])}</text><text x="{x+12}" y="{y+240}" font-size="34" fill="#9ab">{p[2]}–{p[3]}</text>')
s.append('</svg>')
open(out,'w').write('\n'.join(s))
