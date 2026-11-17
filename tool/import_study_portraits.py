"""Import attributed Commons portraits selected by Wikidata's reviewed P18.
No image generation or pixel editing: keep the returned thumbnail bytes intact.
Only public-domain/CC BY/CC BY-SA files; all provenance is saved per asset.
"""
import concurrent.futures
import hashlib
import html
import json
from pathlib import Path
import re
import time
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
UA = 'EspectroAtlas/2.6 (offline educational catalog; public image attribution)'

def get(url, binary=False):
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': UA}), timeout=30) as r:
                data = r.read(8_000_001)
                if len(data)>8_000_000: raise ValueError('Image exceeds import limit')
                return data if binary else json.loads(data)
        except Exception:
            if attempt==2: raise
            time.sleep(1+attempt)

def api(host, **params):
    return get('https://'+host+'/w/api.php?'+urllib.parse.urlencode({'format':'json', **params}))

def text(raw):
    return ' '.join(html.unescape(re.sub('<[^>]*>', ' ', raw or '')).split())

# Explicit English encyclopedia identities prevent ambiguous name searches.
OVERRIDES = {
'platao':'Plato','aristoteles':'Aristotle','nicolau_maquiavel':'Niccolò Machiavelli','pierre_joseph_proudhon':'Pierre-Joseph Proudhon',
'piotr_kropotkin':'Peter Kropotkin','rosa_luxemburgo':'Rosa Luxemburg','gk_chesterton':'G. K. Chesterton',
'friedrich_hayek':'Friedrich Hayek','vladimir_lenin':'Vladimir Lenin','mustafa_kemal_ataturk':'Mustafa Kemal Atatürk',
'lee_kuan_yew':'Lee Kuan Yew','papa_leao_xiii':'Pope Leo XIII','jose_bonifacio':'José Bonifácio de Andrada e Silva',
'dom_pedro_ii':'Pedro II of Brazil','luis_carlos_prestes':'Luís Carlos Prestes','fhc':'Fernando Henrique Cardoso',
'lula':'Luiz Inácio Lula da Silva','jose_mujica':'José Mujica','eneas_carneiro':'Enéas Carneiro',
'charles_de_gaulle':'Charles de Gaulle','margaret_thatcher':'Margaret Thatcher','rui_barbosa':'Ruy Barbosa',
'juan_domingo_peron':'Juan Perón','frederick_douglass':'Frederick Douglass','georg_lukacs':'György Lukács',
'karl_korsch':'Karl Korsch','amadeo_bordiga':'Amadeo Bordiga','errico_malatesta':'Errico Malatesta',
'alberto_torres':'Alberto Torres',
}
NEW = {
'friedrich_engels':'Friedrich Engels','ludwig_von_mises':'Ludwig von Mises','murray_rothbard':'Murray Rothbard','hans_hermann_hoppe':'Hans-Hermann Hoppe',
'milton_friedman':'Milton Friedman','thomas_paine':'Thomas Paine','benjamin_constant':'Benjamin Constant','frederic_bastiat':'Frédéric Bastiat',
'herbert_spencer':'Herbert Spencer','emma_goldman':'Emma Goldman','errico_malatesta':'Errico Malatesta','alexander_berkman':'Alexander Berkman',
'max_stirner':'Max Stirner','benjamin_tucker':'Benjamin Tucker','lysander_spooner':'Lysander Spooner','anton_pannekoek':'Anton Pannekoek',
'amadeo_bordiga':'Amadeo Bordiga','leon_trotsky':'Leon Trotsky','mao_zedong':'Mao Zedong','che_guevara':'Che Guevara',
'georg_lukacs':'György Lukács','karl_korsch':'Karl Korsch','herbert_marcuse':'Herbert Marcuse','theodor_adorno':'Theodor W. Adorno',
'max_horkheimer':'Max Horkheimer','erich_fromm':'Erich Fromm','antonio_negri':'Antonio Negri','robert_owen':'Robert Owen',
'charles_fourier':'Charles Fourier','henri_saint_simon':'Henri de Saint-Simon','eduard_bernstein':'Eduard Bernstein','karl_kautsky':'Karl Kautsky',
'jean_jaures':'Jean Jaurès','james_connolly':'James Connolly','james_guillaume':'James Guillaume','daniel_guerin':'Daniel Guérin',
'alexandra_kollontai':'Alexandra Kollontai','murray_bookchin':'Murray Bookchin','leon_tolstoi':'Leo Tolstoy','william_godwin':'William Godwin',
}

def main():
    rows = json.loads((ROOT/'assets/data/personalities.json').read_text())['entries']
    titles = {e['id']: OVERRIDES.get(e['id'], e['name']) for e in rows}
    titles.update(NEW)
    import sys
    only = set(sys.argv[1:])
    if only: titles = {k:v for k,v in titles.items() if k in only}
    entities = {}
    pairs=list(titles.items())
    for i in range(0,len(pairs),25):
        chunk=pairs[i:i+25]
        d=api('www.wikidata.org',action='wbgetentities',sites='enwiki',titles='|'.join(v for k,v in chunk),props='claims|labels|sitelinks',languages='en|pt')
        for e in d.get('entities',{}).values():
            page=e.get('sitelinks',{}).get('enwiki',{}).get('title')
            for key,title in chunk:
                if page==title and e.get('claims',{}).get('P18'):
                    image=e['claims']['P18'][0]['mainsnak'].get('datavalue',{}).get('value')
                    if isinstance(image,str): entities[key]=(image,e['id'],page)
        missing_chunk = [item for item in chunk if item[0] not in entities]
        if missing_chunk:
            d_pt=api('www.wikidata.org',action='wbgetentities',sites='ptwiki',titles='|'.join(v for k,v in missing_chunk),props='claims|labels|sitelinks',languages='en|pt')
            for e in d_pt.get('entities',{}).values():
                page=e.get('sitelinks',{}).get('ptwiki',{}).get('title')
                for key,title in missing_chunk:
                    if page==title and e.get('claims',{}).get('P18'):
                        image=e['claims']['P18'][0]['mainsnak'].get('datavalue',{}).get('value')
                        if isinstance(image,str): entities[key]=(image,e['id'],page)
    # Known upright Marx photograph avoids an unnecessary digital restoration.
    if 'karl_marx' in entities: entities['karl_marx']=('Karl Marx 001.jpg','Q9061','Karl Marx')
    if 'murray_rothbard' in entities: entities['murray_rothbard']=('Murray Rothbard Portrait.jpg','Q297079','Murray Rothbard')
    if 'amadeo_bordiga' in entities: entities['amadeo_bordiga']=('Amadeo Bordiga.jpg','Q314288','Amadeo Bordiga')
    infos={}
    names=list({v[0] for v in entities.values()})
    for i in range(0,len(names),20):
        d=api('commons.wikimedia.org',action='query',prop='imageinfo',iiprop='url|extmetadata',iiurlwidth=480,titles='|'.join('File:'+f for f in names[i:i+20]))
        for page in d.get('query',{}).get('pages',{}).values():
            if page.get('imageinfo'): infos[page['title'][5:]]=page['imageinfo'][0]
    target=ROOT/'assets/portraits';target.mkdir(exist_ok=True)
    def download(item):
        key,(filename,qid,page)=item
        info=infos.get(filename)
        if not info:return None
        m=info.get('extmetadata',{})
        val=lambda field:text(m.get(field,{}).get('value',''))
        license=val('LicenseShortName')
        if not (license.lower().startswith(('cc by ', 'cc by-sa ', 'public domain', 'cc0', 'pd ', 'no restrictions', 'copyrighted free use')) or license in ['CC BY','CC BY-SA']):
            print('SKIP LICENSE',key,license,flush=True);return None
        url=info.get('thumburl') or info['url']
        try: data=get(url,True)
        except Exception:
            try:data=get(info['url'],True)
            except Exception as ex:print('SKIP DOWNLOAD',key,str(ex),flush=True);return None
        ext='.png' if data.startswith(b'\x89PNG') else '.jpg' if data.startswith(b'\xff\xd8') else None
        if not ext:print('SKIP FORMAT',key,flush=True);return None
        path=target/(key+ext);path.write_bytes(data)
        print('OK',key,license,len(data),flush=True)
        return {'key':'personality:'+key,'assetPath':str(path.relative_to(ROOT)),'caption':val('ImageDescription')[:600] or titles[key],
                'author':val('Artist') or 'Autoria não identificada no acervo', 'licenseName':license,
                'licenseUrl':(val('LicenseUrl') or 'https://creativecommons.org/publicdomain/mark/1.0/').replace('http://','https://',1),
                'sourceUrl':info.get('descriptionurl','https://commons.wikimedia.org/wiki/File:'+urllib.parse.quote(filename)),
                'wikidataUrl':'https://www.wikidata.org/wiki/'+qid,'date':val('DateTimeOriginal') or val('DateTime'),
                'changes':'Arquivo importado sem edição de pixels; enquadramento de exibição pode recortar as bordas.',
                'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'verifiedOn':'2026-11-04'}
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        photos=[r for r in pool.map(download,entities.items()) if r]
    manifest = ROOT/'assets/data/study_media.json'
    if only and manifest.exists():
        importedKeys={p['key'] for p in photos}
        photos += [p for p in json.loads(manifest.read_text())['portraits'] if p['key'] not in importedKeys]
    (ROOT/'assets/data/study_media.json').write_text(json.dumps({'schemaVersion':1,'portraits':sorted(photos,key=lambda p:p['key'])},ensure_ascii=False,indent=2)+'\n')
    print('IMPORTED',len(photos),'of',len(titles),'profiles',flush=True)

if __name__=='__main__':main()
