// À exécuter dans le navigateur (origine github.io). Lit members.json injecté dans window.__M.
// Pour chaque personne : recherche Wikipédia (fr puis en), garde la page seulement si
// l'extrait contient l'année de naissance ou de décès (anti-homonymes), prend la vignette.
(async()=>{
 const M=window.__M, out=[], miss=[];
 const api=async(l,p)=>{const u=`https://${l}.wikipedia.org/w/api.php?origin=*&format=json&`+new URLSearchParams(p);const r=await fetch(u);return r.json()};
 for(const m of M){
  let got=null;
  for(const l of ['fr','en']){
   try{
    const s=await api(l,{action:'query',generator:'search',gsrsearch:m.n,gsrlimit:'3',prop:'pageimages|extracts',piprop:'thumbnail',pithumbsize:'400',exintro:'1',explaintext:'1',exlimit:'3'});
    const ps=Object.values(s.query?.pages||{}).sort((a,b)=>a.index-b.index);
    for(const p of ps){
     const ex=(p.extract||'').slice(0,600), yrs=[m.b,m.d].filter(y=>y).map(y=>String(Math.abs(y)));
     if(p.thumbnail&&yrs.some(y=>ex.includes(y))){got={url:p.thumbnail.source,page:`${l}:${p.title}`};break}
    }
   }catch(e){}
   if(got)break;
  }
  got?out.push({id:m.id,n:m.n,...got}):miss.push({id:m.id,n:m.n});
  await new Promise(r=>setTimeout(r,120));
 }
 window.__OUT={out,miss};
})();
