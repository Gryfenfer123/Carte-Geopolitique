import {computeLayersLayout} from './layers.mjs';
let seed=7;const r=()=>{seed=(seed*1664525+1013904223)%4294967296;return seed/4294967296};
for(let t=0;t<80;t++){
  const n=5+Math.floor(r()*120);
  const nodes=[...Array(n)].map((_,i)=>({id:'a'+i,name:'N'+i,birth:r()<0.2?null:Math.floor(r()*900)-200}));
  const rels=[];
  for(let k=0;k<n*1.3;k++){const a=Math.floor(r()*n),b=Math.floor(r()*n);rels.push({a:'a'+a,b:'a'+b,type:r()<0.6?'parent':'spouse'});}
  const t0=Date.now();
  const res=computeLayersLayout(nodes,rels,{cardW:300,cardH:340,originYear:1000,pxPerYear:22,rowYears:25,gapX:130,spouseGap:150,budgetMs:300});
  // overlap check
  const ps=[...res.pos.values()]; let ov=0;
  for(let i=0;i<ps.length;i++)for(let j=i+1;j<ps.length;j++){if(Math.abs(ps[i].x-ps[j].x)<300&&Math.abs(ps[i].y-ps[j].y)<340)ov++;}
  const bad=[...res.pos.values()].filter(p=>!Number.isFinite(p.x)||!Number.isFinite(p.y)).length; if(res.pos.size!==n||ov||bad) console.log('PB',t,n,res.pos.size,ov,bad);
  if(Date.now()-t0>2500) console.log('slow',t,Date.now()-t0);
}
console.log('fuzz ok');
