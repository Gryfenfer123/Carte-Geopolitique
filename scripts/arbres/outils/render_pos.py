import json,sys,html
d=json.load(open(sys.argv[1])); out=sys.argv[2]
N=d['nodes']; P=d['pos']; CW,CH=300,340
sp=set(); par={}
for r in d['rels']:
    if r['type']=='spouse': sp.add((r['a'],r['b'])); sp.add((r['b'],r['a']))
    if r['type']=='parent': par.setdefault(r['b'],[]).append(r['a'])
xs=[p['x'] for p in P.values()]; ys=[p['y'] for p in P.values()]
mx,my=min(xs)-100,min(ys)-100; W=max(xs)+CW+100-mx; H=max(ys)+CH+100-my
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W/3:.0f}" height="{H/3:.0f}" viewBox="{mx} {my} {W} {H}"><rect x="{mx}" y="{my}" width="{W}" height="{H}" fill="#f4f1ea"/>']
for r in d['rels']:
    a,b=P[r['a']],P[r['b']]
    if r['type']=='spouse':
        s.append(f'<line x1="{a["x"]+CW/2}" y1="{a["y"]+CH/2}" x2="{b["x"]+CW/2}" y2="{b["y"]+CH/2}" stroke="#b5483a" stroke-width="5" stroke-dasharray="14,10"/>')
done=set()
for c,ps in par.items():
    pc=P[c]; ex,ey=pc['x']+CW/2,pc['y']
    if len(ps)==2 and (ps[0],ps[1]) in sp:
        mx0=(P[ps[0]]['x']+P[ps[1]]['x'])/2+CW/2; my0=P[ps[0]]['y']+CH/2
        s.append(f'<path d="M{mx0} {my0} L{mx0} {my0+CH/2+60} L{ex} {ey-60} L{ex} {ey}" fill="none" stroke="#3d6a8a" stroke-width="5" opacity=".75"/>')
    else:
        for p in ps:
            q=P[p]; x0,y0=q['x']+CW/2,q['y']+CH
            s.append(f'<path d="M{x0} {y0} L{x0} {y0+60} L{ex} {ey-60} L{ex} {ey}" fill="none" stroke="#3d6a8a" stroke-width="5" opacity=".75"/>')
for i,n in enumerate(N):
    p=P[n['id']]
    s.append(f'<rect x="{p["x"]}" y="{p["y"]}" width="{CW}" height="{CH}" rx="10" fill="#fff" stroke="#556" stroke-width="3"/><text x="{p["x"]+14}" y="{p["y"]+190}" font-size="34" fill="#111">{html.escape(n["name"][:20])}</text><text x="{p["x"]+14}" y="{p["y"]+240}" font-size="34" fill="#567">{n["birth"]}</text>')
s.append('</svg>'); open(out,'w').write('\n'.join(s))
