import fs from 'fs'; import {planBuses} from './entry.mjs';
const d=JSON.parse(fs.readFileSync(process.argv[2],'utf8')); const P=d.pos; const CW=300,CH=340;
const par={},sp=new Set();
for(const r of d.rels){ if(r.type==='parent')(par[r.b]??=[]).push(r.a); if(r.type==='spouse'){sp.add(r.a+'|'+r.b);sp.add(r.b+'|'+r.a);} }
const cx=i=>P[i].x+CW/2; const bus=[];
for(const [c,ps] of Object.entries(par)){ const ex=cx(c),ey=P[c].y;
 if(ps.length===2&&sp.has(ps[0]+'|'+ps[1])) bus.push({id:'M'+c,start:{x:(cx(ps[0])+cx(ps[1]))/2,y:P[ps[0]].y+CH/2},end:{x:ex,y:ey},group:'M'+[...ps].sort().join('|')});
 else ps.forEach(p=>bus.push({id:'P'+p+'>'+c,start:{x:cx(p),y:P[p].y+CH},end:{x:ex,y:ey},group:'P'+p})); }
const cards=Object.values(P).map(p=>({x:p.x,y:p.y,w:CW,h:CH}));
const m=planBuses(bus,{cards,above:70,lane:26,maxLanes:6});
d.paths=bus.map(b=>({pts:m.get(b.id)||[b.start,b.end],fb:!m.has(b.id),g:b.group}));
fs.writeFileSync(process.argv[3],JSON.stringify(d));
