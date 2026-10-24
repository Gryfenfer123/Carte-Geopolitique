import json,subprocess,sys
d=json.load(open(__import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)),'..','data','db.json')))
def q(s): return 'null' if s is None else "'"+str(s).replace("'","''")+"'"
o=["drop schema if exists public cascade; create schema public;",
"create table public.dossier_sections(id uuid primary key default gen_random_uuid(),category_id uuid,owner_type text not null,owner_id text not null,parent_section_id uuid references public.dossier_sections(id),title text not null,position int not null default 0,created_by uuid);",
"create table public.dossier_entries(id uuid primary key default gen_random_uuid(),section_id uuid references public.dossier_sections(id),category_id uuid,owner_type text not null,owner_id text not null,type text not null,title text,status text default 'published',created_by uuid);",
"create table public.genealogy_members(id uuid primary key default gen_random_uuid(),owner_type text,owner_id text,name text,photo_url text,birth_year int,death_year int,title text,dynasty text,bio text,pos_x float,pos_y float,created_by uuid,is_leader boolean default false);",
"create table public.genealogy_relations(id uuid primary key default gen_random_uuid(),member_a_id uuid references public.genealogy_members(id),member_b_id uuid references public.genealogy_members(id),relation_type text,created_by uuid);",
"create table public.genealogy_foreign_states(member_id uuid,owner_type text,owner_id uuid,pos_x float,pos_y float,is_leader boolean,pinned boolean default false,hidden boolean default false,primary key(member_id,owner_type,owner_id));"]
cat='428a2e75-c8e3-51a1-b12a-bfe7a4018659'
countries=set(e[1] for e in d['e'])|set(x[1] for x in d['s'] if x[2] is None and str(x[3]).lower()=='dynastie')|set('POL CZE UKR LTU LVA EST FIN SWE NOR GRC DNK HUN ROU BGR SRB HRV SVK SVN AUT CHE NLD BEL LUX IRL PRT RUS ALB MNE BLR MDA MKD BIH ISL MLT CYP LIE MCO AND SMR VAT DEU FRA ESP GBR ITA CHN'.split())
import uuid
for c in sorted(countries):
    o.append(f"insert into public.dossier_sections(id,category_id,owner_type,owner_id,title,position) values ('{uuid.uuid5(uuid.NAMESPACE_DNS,'top'+c)}','{cat}','country',{q(c)},'Dynastie',2);")
# sections d'arbres existantes (génériques)
ent_sec={}
for e in d['e']:
    if e[4]=='genealogy':
        sid=str(uuid.uuid5(uuid.NAMESPACE_DNS,'sec'+e[0]))
        o.append(f"insert into public.dossier_sections(id,category_id,owner_type,owner_id,parent_section_id,title) values ('{sid}','{cat}','country',{q(e[1])},'{uuid.uuid5(uuid.NAMESPACE_DNS,'top'+e[1])}',{q(e[2])});")
        o.append(f"insert into public.dossier_entries(id,section_id,category_id,owner_type,owner_id,type,title) values ('{e[0]}','{sid}','{cat}','country',{q(e[1])},'genealogy',{q(e[2])});")
for m in d['m']:
    o.append(f"insert into public.genealogy_members(id,owner_type,owner_id,name,birth_year,death_year,title,dynasty) values ('{m[0]}','entry',{q(m[1])},{q(m[2])},{m[3] if m[3] is not None else 'null'},{m[4] if m[4] is not None else 'null'},{q(m[5])},{q(m[6])});")
mem={m[0] for m in d['m']}
for r in d['r']:
    t={'p':'parent','s':'spouse'}.get(r[2])
    if t and r[0] in mem and r[1] in mem:
        o.append(f"insert into public.genealogy_relations(member_a_id,member_b_id,relation_type) values ('{r[0]}','{r[1]}','{t}');")
open('/tmp/mock.sql','w').write("\n".join(o))
