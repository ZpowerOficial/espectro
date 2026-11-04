"""Read-only public reference audit. HTTP success is not factual validation."""
import concurrent.futures, hashlib, html, json, pathlib, re, time, urllib.request, urllib.error
ROOT=pathlib.Path(__file__).resolve().parents[1]
source_path=ROOT/'tool/curation/sources_round2.json'
CACHE=pathlib.Path('/tmp/espectro-editorial-sources'); CACHE.mkdir(exist_ok=True)
sources=json.loads(source_path.read_text())
urls=sorted({v[1] for v in sources.values()})
def fetch(url):
    key=hashlib.sha256(url.encode()).hexdigest(); path=CACHE/(key+'.json')
    if path.exists(): return json.loads(path.read_text())
    result={'url':url,'checkedAt':'2026-11-04','method':'HTTP GET, at most 300000 bytes; not full editorial validation'}
    try:
        req=urllib.request.Request(url,headers={'User-Agent':'Mozilla/5.0 (compatible; EspectroEditorialReview/1.0)'})
        with urllib.request.urlopen(req,timeout=20) as response:
            body=response.read(300000); mime=response.headers.get('Content-Type','')
            result.update(status=response.status,finalUrl=response.url,contentType=mime,sha256Prefix=hashlib.sha256(body).hexdigest())
            if 'text/html' in mime:
                text=body.decode('utf-8',errors='replace'); title=re.search(r'<title[^>]*>(.*?)</title>',text,re.I|re.S)
                result['title']=html.unescape(re.sub(r'\s+',' ',title.group(1))).strip() if title else None
                (CACHE/(key+'.html')).write_text(text)
    except (urllib.error.URLError,TimeoutError,OSError) as error:
        result.update(status=getattr(error,'code',None),error=str(error))
    path.write_text(json.dumps(result,ensure_ascii=False));return result
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    results=list(pool.map(fetch,urls))
output={'notice':'Acesso técnico às referências; não certifica cada afirmação nem os números editoriais. Bloqueios e erros permanecem explícitos.','sources':{key:{'title':v[0],**next(r for r in results if r['url']==v[1])} for key,v in sources.items()}}
out=ROOT/'docs/catalog-round2-reference-access.json';out.write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'urls':len(urls),'accessible':sum(r.get('status')==200 for r in results),'errors':[(r['url'],r.get('status'),r.get('error')) for r in results if r.get('status')!=200]},ensure_ascii=False,indent=2))
