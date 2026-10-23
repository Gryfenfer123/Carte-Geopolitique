import sys,re
from playwright.sync_api import sync_playwright
svg,out=sys.argv[1],sys.argv[2]
s=open(svg).read();m=re.search(r'width="(\d+)" height="(\d+)"',s);w,h=int(m.group(1)),int(m.group(2))
with sync_playwright() as p:
    b=p.chromium.launch(executable_path='/opt/pw-browsers/chromium');pg=b.new_page(viewport={'width':w,'height':h});pg.goto('file://'+svg);pg.screenshot(path=out);b.close()
