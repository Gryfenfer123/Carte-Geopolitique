import fs from 'fs';
import {computeLayout,guessFemale} from './genealogyLayout.js';
const jobs=JSON.parse(fs.readFileSync(0,'utf8'));
const out={};
for(const [key,j] of Object.entries(jobs)){
  const nodes=j.nodes.map(n=>({id:n.id,name:n.name,birth:n.birth,death:n.death,female:n.g==='f'?true:(n.g==='h'?false:guessFemale(n.name,n.title))}));
  const ids=new Set(nodes.map(n=>n.id));
  const rels=j.rels.filter(r=>ids.has(r.a)&&ids.has(r.b)).map(r=>({a:r.a,b:r.b,type:r.type}));
  const o={cardW:300,cardH:340,originYear:1000,pxPerYear:18,minGen:460,stdGen:460,localIds:new Set(j.local)};
  const pos=computeLayout(nodes,rels,o);
  const r={};
  pos.forEach((p,id)=>{r[id]=[Math.round(p.x),Math.round(p.y)]});
  out[key]=r;
}
process.stdout.write(JSON.stringify(out));
