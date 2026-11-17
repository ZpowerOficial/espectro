"""Fetch public identities for research, never political coordinates.

The Chamber is the primary authority for its own public parliamentary records.
Its identity list does not establish a member's ideology or beliefs. The cache
deliberately excludes email, portraits, party membership and family information.
Run explicitly; normal app builds and catalog integration never use the network.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CACHE = ROOT / 'tool/curation/personality_candidates/camara'
ENDPOINT = 'https://dadosabertos.camara.leg.br/api/v2/deputados'


def project_identity(row, allow_missing_name=False):
    id_ = row['id']
    if type(id_) is not int or id_ <= 0:
        raise ValueError('Invalid official parliamentary identifier')
    uri = f'{ENDPOINT}/{id_}'
    if row.get('uri') != uri:
        raise ValueError(f'Identity source mismatch: {id_}')
    name=row.get('nome')
    if not isinstance(name, str) or not name.strip():
        if allow_missing_name:
            return dict(id=id_, name=None, uri=uri)
        raise ValueError(f'Identity has no published name: {id_}')
    return dict(id=id_, name=name.strip(), uri=uri)


def page_url(legislature, page):
    if not (1 <= legislature <= 57 and 1 <= page <= 30):
        raise ValueError('Unsupported legislature/page')
    return ENDPOINT + '?' + urllib.parse.urlencode(dict(
        idLegislatura=legislature, itens=100, pagina=page,
        ordem='ASC', ordenarPor='id'))


def fetch_page(legislature, page, cache, refresh=False):
    url = page_url(legislature, page)
    path = cache / f'{legislature}-{page:02d}.json'
    if path.exists() and not refresh:
        saved = json.loads(path.read_text())
        if saved['requestUrl'] != url:
            raise ValueError(f'Cache source changed: {path}')
        return saved
    request = urllib.request.Request(url, headers={
        'Accept': 'application/json',
        'User-Agent': 'EspectroCatalogResearch/1.0 (public parliamentary identities)',
    })
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=35) as response:
                body = response.read()
            break
        except urllib.error.HTTPError as error:
            if error.code not in (429, 502, 503, 504) or attempt == 2:
                raise
            time.sleep(min(10, int(error.headers.get('Retry-After', '2'))))
        except (TimeoutError, urllib.error.URLError):
            if attempt == 2:
                raise
            time.sleep(1 + attempt)
    document = json.loads(body)
    projected = [project_identity(row,allow_missing_name=True) for row in document['dados']]
    rows = [row for row in projected if row['name'] is not None]
    unresolved = [{k:row[k] for k in ['id','uri']} for row in projected if row['name'] is None]
    if len(projected) > 100:
        raise ValueError('Unexpected page size')
    # A next-link is evidence of pagination only; it cannot redirect this client.
    has_next = any(link.get('rel') == 'next' for link in document.get('links', []))
    saved = dict(schemaVersion=1, authority='Câmara dos Deputados — Dados Abertos',
                 requestUrl=url, requestedLegislature=legislature, page=page,
                 fetchedAt=datetime.now(timezone.utc).isoformat(),
                 responseSha256=hashlib.sha256(body).hexdigest(),
                 projection='id, nome, uri only; not the complete API response',
                 hasNextPage=has_next, identities=rows, unresolvedIdentities=unresolved,
                 sourceRecordCount=len(projected))
    cache.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(saved, ensure_ascii=False, indent=2) + '\n')
    return saved


def fetch_legislature(legislature, cache, refresh=False):
    total = 0
    seen = set()
    page_signatures = set()
    for page in range(1, 31):
        data = fetch_page(legislature, page, cache, refresh)
        current = {row['id'] for row in data['identities']}
        signature = tuple((r['id'], r['name']) for r in data['identities'])
        if signature and signature in page_signatures:
            raise ValueError(f'Pagination repeated a complete page: legislature {legislature}')
        page_signatures.add(signature)
        seen.update(current)
        total += data.get('sourceRecordCount',len(data['identities']))
        if not data['hasNextPage']:
            print(f'Legislatura consultada {legislature}: {total} registros públicos', flush=True)
            return total
    raise ValueError(f'Pagination limit reached: {legislature}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--first', type=int, default=46)
    parser.add_argument('--last', type=int, default=57)
    parser.add_argument('--cache', type=Path, default=DEFAULT_CACHE)
    parser.add_argument('--refresh', action='store_true')
    args = parser.parse_args()
    if not (1 <= args.first <= args.last <= 57):
        parser.error('Use a documented historical range, at most legislature 57')
    with ThreadPoolExecutor(max_workers=2) as pool:
        futures = [(n,pool.submit(fetch_legislature, n, args.cache, args.refresh))
                   for n in range(args.last, args.first - 1, -1)]
        # Await every result. Any failed page leaves the whole batch incomplete.
        totals,failures=[],[]
        for n,future in futures:
            try:
                totals.append(future.result())
            except Exception as error:
                failures.append(dict(legislature=n,error=str(error)))
        if failures:
            raise SystemExit(json.dumps(dict(status='INCOMPLETE_BATCH',failures=failures)))
    print(json.dumps(dict(status='IDENTITIES_FETCHED_NOT_POLITICAL_PROFILES',
                          recordsAcrossLegislatures=sum(totals))))


if __name__ == '__main__':
    main()
