import json,sys,html,itertools
d=json.load(open(sys.argv[1])); out=sys.argv[2]
N={n['id']:n for n in d['nodes']}; P=d['pos']; CW,CH=300,340
par={};sp=set();spl=[]
for r in d['rels']:
    if r['type']=='parent': par.setdefault(r['b'],[]).append(r['a'])
    if r['type']=='spouse':
        if (r['b'],r['a']) not in sp: spl.append((r['a'],r['b']))
        sp.add((r['a'],r['b'])); sp.add((r['b'],r['a']))
cx=lambda i:P[i]['x']+CW/2
strokes=[]
for c,ps in par.items():
    ex,ey=cx(c),P[c]['y']
    if len(ps)==2 and (ps[0],ps[1]) in sp:
        strokes.append(dict(p=((cx(ps[0])+cx(ps[1]))/2,P[ps[0]]['y']+CH/2,ex,ey),sk='M'+'|'.join(sorted(ps)),ek=c,skip=[ps[0],ps[1],c],bad=0))
    else:
        for p in ps: strokes.append(dict(p=(cx(p),P[p]['y']+CH,ex,ey),sk='P'+p,ek=c,skip=[p,c],bad=0))
def X(a,b):
    def dd(p,q,r):return (q[0]-p[0])*(r[1]-p[1])-(q[1]-p[1])*(r[0]-p[0])
    a1,a2=a[:2],a[2:];b1,b2=b[:2],b[2:]
    d1,d2,d3,d4=dd(b1,b2,a1),dd(b1,b2,a2),dd(a1,a2,b1),dd(a1,a2,b2)
    return ((d1>1e-3 and d2<-1e-3) or (d1<-1e-3 and d2>1e-3)) and ((d3>1e-3 and d4<-1e-3) or (d3<-1e-3 and d4>1e-3))
bad_sp=set()
for a,b in itertools.combinations(strokes,2):
    if a['sk']==b['sk'] or a['ek']==b['ek']: continue
    if X(a['p'],b['p']): a['bad']=b['bad']=1
for s_,t_ in spl:
    L=(cx(s_),P[s_]['y']+CH/2,cx(t_),P[t_]['y']+CH/2)
    for st in strokes:
        if s_ in st['skip'] and t_ in st['skip']: continue
        if X(L,st['p']): st['bad']=1; bad_sp.add((s_,t_))
xs=[p['x'] for p in P.values()]; ys=[p['y'] for p in P.values()]
mx,my=min(xs)-100,min(ys)-100; W=max(xs)+CW+100-mx; H=max(ys)+CH+100-my
sc=float(sys.argv[3]) if len(sys.argv)>3 else 3
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W/sc:.0f}" height="{H/sc:.0f}" viewBox="{mx} {my} {W} {H}"><rect x="{mx}" y="{my}" width="{W}" height="{H}" fill="#f4f1ea"/>']
for a,b in spl: s.append(f'<line x1="{cx(a)}" y1="{P[a]["y"]+CH/2}" x2="{cx(b)}" y2="{P[b]["y"]+CH/2}" stroke="{"#e00" if (a,b) in bad_sp else "#b5483a"}" stroke-width="{10 if (a,b) in bad_sp else 5}" stroke-dasharray="14,10"/>')
for st in strokes:
    a=st['p']; s.append(f'<line x1="{a[0]}" y1="{a[1]}" x2="{a[2]}" y2="{a[3]}" stroke="{"#e00" if st["bad"] else "#3d6a8a"}" stroke-width="{9 if st["bad"] else 5}" opacity=".8"/>')
for i,n in N.items():
    p=P[i]; s.append(f'<rect x="{p["x"]}" y="{p["y"]}" width="{CW}" height="{CH}" rx="10" fill="#fff" stroke="#556" stroke-width="3" fill-opacity=".92"/><text x="{p["x"]+14}" y="{p["y"]+190}" font-size="34" fill="#111">{html.escape(n["name"][:20])}</text><text x="{p["x"]+14}" y="{p["y"]+240}" font-size="34" fill="#567">{n["birth"]}</text>')
s.append('</svg>'); open(out,'w').write('\n'.join(s))
print('strokes bad',sum(s_['bad'] for s_ in strokes),'of',len(strokes))
