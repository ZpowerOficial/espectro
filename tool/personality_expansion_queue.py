"""Build a deduplicated research queue from primary institutional identities.

This file does not write assets/data. An identity is not an ideological profile.
Publication continues through individually sourced editorial reconstructions.
"""
import argparse
from collections import defaultdict
import json
from pathlib import Path
import re
import unicodedata

from fetch_personality_candidates import DEFAULT_CACHE, ENDPOINT, ROOT, page_url


def normalized(value):
    return ''.join(c for c in unicodedata.normalize('NFKD', value).casefold()
                   if c.isalnum() and not unicodedata.combining(c))


def build_queue(cache, first, last, catalog):
    by_id = {}
    unresolved = defaultdict(list)
    source_pages = []
    for legislature in range(last, first - 1, -1):
        for page in range(1, 31):
            path = cache / f'{legislature}-{page:02d}.json'
            if not path.exists():
                raise ValueError(f'Incomplete batch: missing {path.name}')
            data = json.loads(path.read_text())
            if (data['requestUrl'] != page_url(legislature, page)
                    or data['requestedLegislature'] != legislature
                    or not re.fullmatch('[a-f0-9]{64}', data['responseSha256'])):
                raise ValueError(f'Invalid cached provenance: {path.name}')
            source_pages.append(dict(path=str(path.relative_to(cache)),
                                     requestUrl=data['requestUrl'],
                                     fetchedAt=data['fetchedAt'],
                                     responseSha256=data['responseSha256']))
            for identity in data['identities']:
                id_ = identity['id']
                if type(id_) is not int or identity['uri'] != f'{ENDPOINT}/{id_}':
                    raise ValueError('Invalid authority identity')
                row = by_id.setdefault(id_, dict(
                    authorityId=f'camara:{id_}',
                    authorityUrl=identity['uri'], name=identity['name'],
                    observedNames=[], requestedLegislatures=[], sourcePages=[],
                    status='identity_only', publicationStatus='not_published',
                    politicalPositionsReviewed=False))
                if identity['name'] not in row['observedNames']:
                    row['observedNames'].append(identity['name'])
                if legislature not in row['requestedLegislatures']:
                    row['requestedLegislatures'].append(legislature)
                row['sourcePages'].append(f'{legislature}-{page:02d}.json')
            for identity in data.get('unresolvedIdentities',[]):
                unresolved[identity['id']].append(f'{legislature}-{page:02d}.json')
            if not data['hasNextPage']:
                break
        else:
            raise ValueError(f'Incomplete pagination: legislature {legislature}')
    existing = defaultdict(set)
    for row in catalog['entries']:
        existing[normalized(row['name'])].add('personality:' + row['id'])
    axes = json.loads((ROOT/'assets/data/twelve_axes.json').read_text())['axes']
    dimensions = ['axis:' + a['id'] for a in axes] + ['triad:' + str(i) for i in range(6)]
    for row in by_id.values():
        # Names only suggest a review; they never establish identity equivalence.
        matches = set()
        for name in row['observedNames']:
            matches.update(existing.get(normalized(name), []))
        row['possibleExistingSubjects'] = sorted(matches)
        row['dimensionsToReview'] = dimensions
        row['nextAction'] = ('Confirmar identidade e recorte; ler discursos, obras, '
                             'programas ou votos contextualizados e registrar suporte por dimensão.')
    return dict(
        schemaVersion=1, batch='camara-identities-2026-11-05',
        status='RESEARCH_QUEUE_NOT_COMPLETE_POLITICAL_PROFILES',
        source='Câmara dos Deputados — Dados Abertos',
        sourceDocumentation='https://dadosabertos.camara.leg.br/swagger/api.html',
        firstLegislature=first, lastLegislature=last,
        limitations=[
            'Recorte brasileiro parlamentar; não constitui expansão mundial equilibrada.',
            'O identificador deduplica registros da autoridade; homônimos não são fundidos pelo nome.',
            'Consultas por legislatura não comprovam um mandato ininterrupto nem posições atuais.',
            'Nomes e URLs oficiais confirmam registros públicos, não ideologia ou respostas ao teste.',
            'Partido, cargo e nacionalidade não geram coordenadas ou espectros.',
            'Esta fila não é carregada pelo aplicativo nem contada como perfis completos.',
        ],
        counts=dict(authorityIdentities=len(by_id),
                    withPossibleExistingMatch=sum(bool(r['possibleExistingSubjects']) for r in by_id.values()),
                    sourcePages=len(source_pages), publishedByThisQueue=0,
                    unresolvedAuthorityIds=len(set(unresolved)-set(by_id))),
        unresolvedIdentities=[dict(authorityId=f'camara:{id_}',sourcePages=pages,
                                  status='name_unavailable_in_requested_pages')
                              for id_,pages in sorted(unresolved.items()) if id_ not in by_id],
        sourcePages=source_pages,
        candidates=sorted(by_id.values(), key=lambda r: int(r['authorityId'].split(':')[1])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--first', type=int, default=46)
    parser.add_argument('--last', type=int, default=57)
    parser.add_argument('--cache', type=Path, default=DEFAULT_CACHE)
    parser.add_argument('--output', type=Path,
                        default=ROOT/'tool/curation/personality_expansion_queue.json')
    args = parser.parse_args()
    if not (1 <= args.first <= args.last <= 57):
        parser.error('Invalid legislature range')
    queue = build_queue(args.cache, args.first, args.last,
                        json.loads((ROOT/'assets/data/personalities.json').read_text()))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(queue, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps(queue['counts']))


if __name__ == '__main__':
    main()
