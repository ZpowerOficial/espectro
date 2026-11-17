"""Build the offline extension from original editorial rows, without imputation.

Idempotent: replaces this batch only. No competitor text or vectors are imported.
References are contextual reading, not empirical validation of coordinates.
"""
import json
import pathlib
import re
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parents[1]
CURATION = ROOT / 'tool/curation'
BATCH = 'editorial-2026-11-05'
SPECTRA = dict(zip(
    ['radical_left', 'left', 'center', 'right', 'far_right', 'anarchist', 'libertarian', 'third_position'],
    ['Esquerda radical', 'Esquerda', 'Centro', 'Direita', 'Extrema-direita', 'Anarquistas', 'Libertários', 'Terceira posição']))
AXES = {a['id']: a for a in json.loads((ROOT / 'assets/data/twelve_axes.json').read_text())['axes']}
SOURCES = json.loads((CURATION / 'sources_round2.json').read_text())


def rows(file, size):
    for line in (CURATION / file).read_text().splitlines():
        if not line.strip() or line.startswith('#'):
            continue
        row = [s.strip() for s in line.split('|')]
        assert len(row) == size, row
        assert re.fullmatch(r'[a-z0-9_]+', row[0]), row[0]
        yield row


def positions(raw):
    result = {}
    for item in raw.split(','):
        if item:
            key, value = item.split('=')
            assert key in AXES and -1 <= float(value) <= 1, item
            result[key] = float(value)
    return result


def note(axis, value, summary):
    a = AXES[axis]
    pole = a['leftPole'] if value < 0 else a['rightPole'] if value > 0 else 'equilíbrio entre os polos'
    return f"Leitura editorial de {a['label']} com ênfase em {pole}, limitada ao recorte: {summary} A magnitude é heurística, não uma medição extraída da referência."


def basis(summary, keys):
    refs = [SOURCES[k] for k in keys]
    for _, url in refs:
        assert url.startswith('https://'), url
    return {
        'reviewedAt': '2026-11-05',
        'scope': summary,
        'coordinateMethod': 'Parametrização editorial provisória dos eixos explicitados nesta ficha. As referências contextualizam o verbete; não estabelecem os valores numéricos. Eixos sem base específica e todas as tríades desta ampliação permanecem ausentes.',
        'limitations': [
            'Síntese introdutória: há divergências internas, mudanças históricas e leituras concorrentes.',
            'Fontes podem ser textos primários, arquivos institucionais ou referências secundárias; acesso técnico a um link não certifica a interpretação.',
            'Família e posição são recursos de navegação. Não representam probabilidade de afinidade, diagnóstico ou validação psicométrica.',
        ],
        'sourceUrls': list(dict.fromkeys(url for _, url in refs)),
        'sourceTitles': {url: title for title, url in refs},
        'empiricallyValidated': False,
        'nativeMatchingEligible': False,
    }


def save(filename, key, additions):
    path = ROOT / 'assets/data' / filename
    document = json.loads(path.read_text())
    original = [r for r in document[key] if r.get('curationBatch') != BATCH]
    ids = {r['id'] for r in original}
    names = {r['name'].casefold() for r in original}
    for r in additions:
        assert r['id'] not in ids, f"Duplicate id {r['id']}"
        assert r['name'].casefold() not in names, f"Duplicate name {r['name']}"
        ids.add(r['id'])
        names.add(r['name'].casefold())
    document[key] = original + additions
    document['catalogVersion'] = '4.0.0'
    path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + '\n')
    return {'previous': len(original), 'added': len(additions), 'total': len(document[key])}


currents = []
for id_, name, spectrum, ref, summary, ideas, raw in rows('currents_round2.tsv', 7):
    assert spectrum in SPECTRA
    observed = positions(raw)
    currents.append({
        'id': id_, 'name': name, 'family': SPECTRA[spectrum], 'spectrumId': spectrum,
        'summary': summary, 'keyIdeas': ideas.split(';'), 'curationBatch': BATCH,
        'editorialBasis': basis(summary, ref.split(',')),
        'axes': {a: {'mu': observed.get(a, 0), 'sigma': .65, 'relevance': .45 if a in observed else 0,
                     'note': note(a, observed[a], summary) if a in observed else 'Lacuna explícita: este recorte não sustenta uma posição neste eixo; zero é apenas armazenamento inativo, excluído de gráficos e comparação.'} for a in AXES},
        'triangles': {str(i): {'mu': [1/3, 1/3, 1/3], 'sigma': .65, 'relevance': 0,
                              'note': 'Lacuna explícita: sem composição triádica documentada. Os valores de armazenamento não entram em gráficos nem comparação.'} for i in range(6)},
    })

result = {'currents': save('ideological_currents.json', 'currents', currents)}
for kind, file, target, category in [
    ('book', 'books_round2.tsv', 'books_catalog.json', 'Obras e leituras'),
    ('party', 'parties_round2.tsv', 'parties_movements.json', 'Partidos e movimentos históricos'),
    ('history', 'history_round2.tsv', 'historical_eras.json', 'Experiências históricas'),
]:
    additions = []
    for row in rows(file, 10 if kind == 'book' else 9):
        if kind == 'book':
            id_, name, author, era, origin, spectrum, url, summary, ideas, raw = row
        else:
            id_, name, era, origin, spectrum, url, summary, ideas, raw = row
            author = era
        assert spectrum in SPECTRA
        reference = f'{kind}:{id_}'
        assert SOURCES[reference][1] == url, reference
        observed = positions(raw)
        additions.append({
            'id': id_, 'name': name, 'subtitle': author, 'category': category,
            'era': era, 'origin': origin, 'spectrumId': spectrum,
            'summary': summary, 'highlights': ideas.split(';'), 'quote': None,
            'axes': observed, 'triangles': {}, 'curationBatch': BATCH,
            'coordinateNotes': {a: note(a, v, summary) for a, v in observed.items()},
            'editorialBasis': basis(summary, [reference]),
        })
    result[kind] = save(target, 'entries', additions)

result['spectrumOrder'] = list(SPECTRA)
result['addedCurrentsBySpectrum'] = dict(Counter(c['spectrumId'] for c in currents))
result['method'] = 'Original Portuguese summaries and selective provisional coordinates; no empirical validation. Missing evidence remains absent. References audited separately.'
(ROOT / 'docs/catalog-expansion-round2.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(result, ensure_ascii=False, indent=2))

# Preserve the subsequent primary-document review on regeneration.
import runpy
runpy.run_path(str(ROOT / "tool/review_primary_profiles.py"))
