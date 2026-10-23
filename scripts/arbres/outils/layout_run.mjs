import fs from 'fs';
import path from 'path';
import {fileURLToPath} from 'url';
import {execSync} from 'child_process';
import {computeLayout,guessFemale} from './genealogyLayout.js';
// Mise en page : par défaut la même que le bouton « Organiser par dates » de l'appli (src/genealogyLayers.ts,
// compilé à la volée par rolldown). LAYOUT=old pour l'ancienne mise en page descendante.
const here=path.dirname(fileURLToPath(import.meta.url));
const useLayers=process.env.LAYOUT!=='old';
let computeLayersLayout=null;
if(useLayers){
  const out='/tmp/arbres_layers';
  const js=path.join(out,'genealogyLayers.js');
  const src=path.join(here,'..','..','..','src','genealogyLayers.ts');
  if(!fs.existsSync(js)||fs.statSync(js).mtimeMs<fs.statSync(src).mtimeMs){
    execSync(`npx rolldown ${src} --format esm -d ${out}`,{cwd:path.join(here,'..','..','..'),stdio:'ignore'});
  }
  ({computeLayersLayout}=await import(js));
}
const jobs=JSON.parse(fs.readFileSync(0,'utf8'));
const out={};
for(const [key,j] of Object.entries(jobs)){
  const nodes=j.nodes.map(n=>({id:n.id,name:n.name,birth:n.birth,death:n.death,female:n.g==='f'?true:(n.g==='h'?false:guessFemale(n.name,n.title))}));
  const ids=new Set(nodes.map(n=>n.id));
  const rels=j.rels.filter(r=>ids.has(r.a)&&ids.has(r.b)).map(r=>({a:r.a,b:r.b,type:r.type}));
  const r={};
  if(useLayers){
    const res=computeLayersLayout(nodes,rels,{cardW:300,cardH:340,originYear:1000,pxPerYear:640/33,rowYears:33,gapX:200,spouseGap:190,budgetMs:+(process.env.LAYOUT_MS||6000)});
    res.pos.forEach((p,id)=>{r[id]=[Math.round(p.x),Math.round(p.y)]});
    console.error(key,JSON.stringify(res.stats));
  } else {
    const o={cardW:300,cardH:340,originYear:1000,pxPerYear:18,minGen:460,stdGen:460,localIds:new Set(j.local)};
    const pos=computeLayout(nodes,rels,o);
    pos.forEach((p,id)=>{r[id]=[Math.round(p.x),Math.round(p.y)]});
  }
  out[key]=r;
}
process.stdout.write(JSON.stringify(out));
