"""Fetch public source texts for review; network success never means factual review.

Only URLs in the curated manifest are requested. Full text stays in /tmp.
"""
import concurrent.futures
import hashlib
import html
import json
import re
import subprocess
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE = Path('/tmp/espectro-primary-readings')
CACHE.mkdir(exist_ok=True)
DOCS = json.loads((ROOT/'tool/curation/primary_reading_dossiers.json').read_text())

def fetch(doc):
    report = CACHE/(doc['id']+'.json')
    if report.exists():
        return json.loads(report.read_text())
    url = doc['url']
    result = {'id': doc['id'], 'url': url, 'checkedAt': '2026-11-05', 'contentReviewed': False}
    try:
        def get(u):
            with urllib.request.urlopen(urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0 EspectroDocumentReview/1.0'}), timeout=25) as r:
                return r.read(8000000), r.url
        raw, final = get(url)
        if 'gutenberg.org/ebooks/' in url:
            match = re.search(rb'href="(/cache/epub/\d+/[^" ]+\.html)"', raw)
            if not match:
                match = re.search(rb'href="(/files/[^" ]+\.html[^" ]*)"', raw)
            if match:
                raw, final = get('https://www.gutenberg.org'+html.unescape(match.group(1).decode()))
        if raw.startswith(b'%PDF'):
            pdf = CACHE/(doc['id']+'.pdf')
            pdf.write_bytes(raw)
            text = subprocess.run(['pdftotext', '-layout', str(pdf), '-'], check=True, capture_output=True).stdout.decode('utf-8', errors='replace')
        else:
            text = raw.decode('utf-8', errors='replace')
        text = re.sub(r'<(script|style)\b[^>]*>.*?</\1>', '', text, flags=re.S|re.I)
        text = html.unescape(re.sub('<[^>]+>', ' ', text))
        text = re.sub(r'[ \t]+', ' ', text)
        text = re.sub(r'\n\s*\n+', '\n\n', text)
        (CACHE/(doc['id']+'.txt')).write_text(text)
        result.update(httpStatus=200, finalUrl=final, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), textChars=len(text))
    except Exception as e:
        result.update(httpStatus=getattr(e,'code',None), error=str(e))
    report.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    return result

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        reports = list(pool.map(fetch,DOCS))
    (ROOT/'docs/primary-reading-access-2026-11-05.json').write_text(json.dumps({'notice':'Acesso técnico apenas. A leitura e a interpretação são estados separados. Texto integral temporário não distribuído pelo app.','documents':reports},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps([{'id':r['id'],'status':r.get('httpStatus'),'chars':r.get('textChars'),'error':r.get('error')} for r in reports],ensure_ascii=False))
