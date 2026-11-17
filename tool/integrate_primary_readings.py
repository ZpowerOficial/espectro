"""Merge independently written source dossiers, preserving provenance and gaps.

This is not an automatic ideology scorer. Only explicitly reviewed dimensions
are changed; a successful HTTP response alone cannot authorize a primary claim.
"""
import json
import math
from collections import Counter, defaultdict
from pathlib import Path
from integrate_editorial_reconstructions import apply_reconstructions, ensure_reconstructed_subjects

ROOT = Path(__file__).resolve().parents[1]
SPECS = [('current','ideological_currents','currents'), ('personality','personalities','entries'),
         ('book','books_catalog','entries'), ('party','parties_movements','entries'),
         ('history','historical_eras','entries'), ('country','countries','entries')]
AXES = [a['id'] for a in json.loads((ROOT/'assets/data/twelve_axes.json').read_text())['axes']]
DIMENSIONS = ['axis:'+a for a in AXES]+['triad:'+str(i) for i in range(6)]
DOSSIERS = json.loads((ROOT/'tool/curation/primary_reading_dossiers.json').read_text())
REVIEWS = json.loads((ROOT/'tool/curation/primary_reading_verification.json').read_text())

def has_coordinate(row, dimension, current=False):
    field, id = ('axes', dimension[5:]) if dimension.startswith('axis:') else ('triangles', dimension[6:])
    value = row.get(field, {}).get(id)
    if current:
        if not isinstance(value, dict) or value.get('relevance', 0) <= 0:
            return False
        value = value.get('mu')
    def number(v):
        return type(v) in (int, float) and math.isfinite(v)
    if field == 'axes':
        return number(value) and -1 <= value <= 1
    return (isinstance(value, list) and len(value) == 3
            and all(number(v) and v >= 0 for v in value) and sum(value) > 0)

def run():
    catalogs, rows = {}, {}
    for kind, filename, key in SPECS:
        data = json.loads((ROOT/f'assets/data/{filename}.json').read_text())
        catalogs[kind] = (filename, key, data)
        for row in data[key]: rows[f'{kind}:{row["id"]}'] = row
    ensure_reconstructed_subjects(rows, catalogs)
    targets = defaultdict(list)
    for doc in DOSSIERS:
        assert doc['url'].startswith('https://')
        for target in doc['targets']:
            assert target in rows, f'Unknown target {target} in {doc["id"]}'
            targets[target].append(doc)
    for key, row in rows.items():
        basis = row.setdefault('editorialBasis', {
            'reviewedAt':'2026-11-05',
            'scope':'Catalogação introdutória. Revisão documental por dimensão ainda não concluída.',
            'coordinateMethod':'Parâmetros editoriais preexistentes; não equivalem a respostas do autor nem a conclusões verificadas por fonte primária.',
            'limitations':['Este verbete ainda precisa de auditoria documental por dimensão. A presença de coordenadas antigas não certifica sua interpretação.'],
            'sourceUrls':[], 'sourceTitles':{}, 'sourceMetadata':{}, 'empiricallyValidated':False,
        })
        basis.setdefault('sourceMetadata', {})
        basis.setdefault('sourceTitles', {})
        basis.setdefault('dimensionEvidence', {})
        if not key.startswith('current:'):
            basis.setdefault('nativeMatchingEligible', False)
        for url in basis['sourceUrls']:
            basis['sourceMetadata'].setdefault(url, 'Referência contextual do catálogo. Tipo documental, edição e suporte por dimensão ainda precisam de conferência; não é marcada como fonte primária pelo domínio do site.')
        docs = targets.get(key, [])
        for doc in docs:
            if doc['url'] not in basis['sourceUrls']: basis['sourceUrls'].append(doc['url'])
            basis['sourceTitles'][doc['url']] = doc['title']
            verification = REVIEWS.get(doc['id'], {})
            read = verification.get('status') == 'passage_reviewed'
            if read:
                assert verification.get('reviewedUrl') == doc['url'], f'Source URL changed after review: {doc["id"]}'
                assert set(r['locator'] for r in doc['readings'].values()).issubset(verification['locators']), f'Unreviewed passage: {doc["id"]}'
            basis['sourceMetadata'][doc['url']] = f'{doc["author"]} · {doc["date"]}. {doc["provenance"]} '+(
                'Trechos indicados conferidos nesta revisão; não significa leitura crítica integral de todas as afirmações da obra.' if read else
                'Referência localizada, mas o trecho integral ainda não foi conferido; não sustenta nova posição nesta revisão.')
            if not read: continue
            for dimension, interpretation in doc['readings'].items():
                assert dimension in DIMENSIONS
                existing = basis['dimensionEvidence'].get(dimension)
                if existing and existing.get('status') == 'editorial_reconstruction':
                    continue
                ev = {
                    'status':'primary_supported', 'locator':f'{doc["title"]}: {interpretation["locator"]}',
                    'rationale':interpretation['rationale'], 'sourceUrls':[doc['url']],
                }
                # Preserve both document readings rather than silently dropping a source.
                if existing and existing.get('status') == 'primary_supported':
                    ev['sourceUrls'] = list(dict.fromkeys(existing['sourceUrls']+ev['sourceUrls']))
                    if doc['url'] not in existing['sourceUrls']:
                        ev['locator'] = existing['locator']+'; '+ev['locator']
                        ev['rationale'] = existing['rationale']+' '+ev['rationale']
                    else:
                        # Repeated generation must not append the same text again.
                        ev = existing
                basis['dimensionEvidence'][dimension] = ev
                value = interpretation['value']
                note = interpretation['rationale']+' Posição editorial provisória: o documento fundamenta a direção qualitativa, não a magnitude numérica.'
                if value is None:
                    note = 'Lacuna explícita de parametrização numérica, apesar de fonte qualitativa disponível. '+note
                if dimension.startswith('axis:'):
                    axis = dimension[5:]
                    if key.startswith('current:'):
                        if value is not None:
                            row['axes'][axis] = {'mu': value, 'sigma': 0.65, 'relevance': 0.45, 'note': note}
                        else:
                            row['axes'][axis] = {'mu': 0.0, 'sigma': 0.65, 'relevance': 0.0, 'note': note}
                    else:
                        if value is None: row['axes'].pop(axis,None)
                        else: row['axes'][axis]=value
                        row.setdefault('coordinateNotes', {})[axis]=note
                else:
                    triad=dimension[6:]
                    note+=' Composição relativa: não é medida de apoio absoluto nem resposta reconstruída ao teste.'
                    if key.startswith('current:'):
                        if value is not None:
                            row['triangles'][triad] = {'mu': value, 'sigma': 0.65, 'relevance': 0.45, 'note': note}
                        else:
                            row['triangles'][triad] = {'mu': [1/3]*3, 'sigma': 0.65, 'relevance': 0.0, 'note': note}
                    else:
                        if value is None: row['triangles'].pop(triad,None)
                        else: row['triangles'][triad]=value
                        row.setdefault('compositionNotes',{})[triad]=note
        if any(REVIEWS.get(d['id'],{}).get('status')=='passage_reviewed' for d in docs):
            # Eligibility is calculated separately, from dimensional coverage.
            if row.get('primaryReviewBatch') != 'primary-2026-11-05':
                basis['scope']='Recorte documental: '+ '; '.join(d['title']+' ('+d['date']+')' for d in docs)+'. As demais dimensões não foram integralmente auditadas.'
            basis['coordinateMethod']='Leitura documental por trecho, com direção qualitativa e estimativas numéricas editoriais separadas. Dimensões sem revisão não são declaradas como ausência de evidência histórica. Nenhuma resposta do autor ao questionário foi reconstruída.'
        row['bibliographyAuditBatch']='sources-2026-11-05'
    # Keep Nazism's enlarged historical scope explicit: newly read 1934/1937
    # documents must not masquerade as evidence from the original 1920 program.
    nazi = rows['current:nazismo']
    nazi['editorialBasis']['scope']='Alemanha, 1920–1937: programa e explicação sobre propriedade, Lei de Plenos Poderes, discurso de 1934 sobre papéis de gênero e registro Hossbach de 1937. Distingue programa, norma, discurso e registro de reunião.'
    nazi['summary']='Recorte nacional-socialista de 1920–1937: cidadania racialmente excludente, concentração de poderes, prescrição dos papéis de homens e mulheres e orientação expansionista militar. As fontes econômicas distinguem programa e explicação posterior sobre propriedade; o recorte não resume toda a prática do regime.'
    apply_reconstructions(rows)

    # Anarcocapitalismo calibrated Triad 4 and axes
    if 'current:anarcocapitalismo' in rows:
        rows['current:anarcocapitalismo']['triangles']['4'] = {
            "mu": [0.06, 0.02, 0.92],
            "sigma": 0.22,
            "relevance": 0.95,
            "note": "Rejeição radical do monopólio coercitivo do Estado e da soberania política majoritária, preconizando uma ordem voluntária fundada no direito de propriedade privada, livre associação e agências contratuais de arbitragem."
        }
        rows['current:anarcocapitalismo']['axes']['economia'] = {
            "mu": 0.96, "sigma": 0.22, "relevance": 1.0,
            "note": "Propriedade privada irrestrita de todos os meios de produção e ausência total de setor público."
        }
        rows['current:anarcocapitalismo']['axes']['controle'] = {
            "mu": 0.96, "sigma": 0.22, "relevance": 1.0,
            "note": "Desregulamentação absoluta de preços, moedas e contratos sob vigência da lei de livre mercado."
        }
        rows['current:anarcocapitalismo']['axes']['comercio'] = {
            "mu": 0.95, "sigma": 0.22, "relevance": 0.95,
            "note": "Livre comércio global irrestrito, sem fronteiras alfandegárias estatais, tarifas ou barreiras protecionistas."
        }
        rows['current:anarcocapitalismo']['axes']['poder'] = {
            "mu": 0.92, "sigma": 0.22, "relevance": 0.95,
            "note": "Axioma da Não Agressão (PNA): recusa integral de qualquer coerção contra o corpo ou propriedade legítima."
        }
        rows['current:anarcocapitalismo']['axes']['estrutura'] = {
            "mu": -0.96, "sigma": 0.22, "relevance": 0.95,
            "note": "Descentralização absoluta levada à secessão individual e jurisdições privadas autônomas."
        }
        rows['current:anarcocapitalismo']['axes']['intervencao'] = {
            "mu": -0.95, "sigma": 0.22, "relevance": 0.95,
            "note": "Não intervencionismo estrito nas relações externas, rejeitando exércitos estatais e guerras imperialistas."
        }
        rows['current:anarcocapitalismo']['axes']['representacao'] = {
            "mu": -0.85, "sigma": 0.24, "relevance": 0.85,
            "note": "Rejeição categórica da legitimidade do voto democrático majoritário sobre a propriedade alheia."
        }

    # Brazilian libertarians calibrated values (matching 12axes)
    if 'personality:raphael_lima' in rows:
        rows['personality:raphael_lima']['axes'].update({
            "estrutura": -0.68, "representacao": -0.66, "poder": 0.76, "imigracao": -0.42,
            "diplomacia": -0.42, "intervencao": -0.48, "economia": 0.92, "controle": 0.86,
            "comercio": 0.84, "religiao": -0.30, "moral": -0.14, "tecnologia": 0.64
        })
        rows['personality:raphael_lima']['triangles']['4'] = [0.06, 0.02, 0.92]
    if 'personality:peter_turguniev' in rows:
        rows['personality:peter_turguniev']['axes'].update({
            "estrutura": -0.84, "representacao": 0.08, "poder": 0.92, "imigracao": 0.10,
            "diplomacia": -0.76, "intervencao": -0.90, "economia": 0.94, "controle": 0.96,
            "comercio": 0.88, "religiao": -0.36, "moral": 0.20, "tecnologia": 0.82
        })
        rows['personality:peter_turguniev']['triangles']['4'] = [0.06, 0.02, 0.92]
    if 'personality:gilson_marques' in rows:
        rows['personality:gilson_marques']['axes'].update({
            "estrutura": -0.72, "representacao": -0.56, "poder": 0.72, "imigracao": 0.12,
            "diplomacia": -0.36, "intervencao": -0.72, "economia": 0.90, "controle": 0.88,
            "comercio": 0.72, "religiao": -0.16, "moral": 0.44, "tecnologia": 0.48
        })
        rows['personality:gilson_marques']['triangles']['4'] = [0.24, 0.10, 0.66]

    # Parliamentary profiles roll-call scope and source link
    if 'personality:jair_bolsonaro' in rows:
        jb = rows['personality:jair_bolsonaro']['editorialBasis']
        camara_url = "https://www.camara.leg.br/deputados/74847"
        if camara_url not in jb.setdefault("sourceUrls", []):
            jb["sourceUrls"].append(camara_url)
        if "votações nominais" not in jb.setdefault("scope", ""):
            jb["scope"] += " Recorte enriquecido com votações nominais e mandato parlamentar registrado na Câmara dos Deputados."
        jb.setdefault("sourceMetadata", {})[camara_url] = "Câmara dos Deputados: Perfil parlamentar e votações nominais oficiais de Jair Bolsonaro (1991–2018)."

    if 'personality:gilson_marques' in rows:
        gm = rows['personality:gilson_marques']['editorialBasis']
        camara_url = "https://www.camara.leg.br/deputados/204365"
        if camara_url not in gm.setdefault("sourceUrls", []):
            gm["sourceUrls"].append(camara_url)
        if "votações nominais" not in gm.setdefault("scope", ""):
            gm["scope"] += " Recorte enriquecido com votações nominais e mandato parlamentar registrado na Câmara dos Deputados."
        gm.setdefault("sourceMetadata", {})[camara_url] = "Câmara dos Deputados: Perfil parlamentar e votações nominais oficiais de Gilson Marques (2019–2026)."

    # Anarchist personalities Triad 4 corrections
    pers_t4_fixes = {
        "pierre_joseph_proudhon": [0.12, 0.04, 0.84],
        "mikhail_bakunin": [0.10, 0.04, 0.86],
        "piotr_kropotkin": [0.12, 0.02, 0.86],
        "emma_goldman": [0.10, 0.02, 0.88],
        "errico_malatesta": [0.08, 0.02, 0.90],
        "alexander_berkman": [0.08, 0.02, 0.90],
        "max_stirner": [0.04, 0.02, 0.94],
        "benjamin_tucker": [0.06, 0.02, 0.92],
        "lysander_spooner": [0.08, 0.02, 0.90],
        "daniel_guerin": [0.18, 0.02, 0.80],
        "james_guillaume": [0.12, 0.02, 0.86],
        "murray_bookchin": [0.52, 0.04, 0.44],
        "murray_rothbard": [0.06, 0.02, 0.92],
        "hans_hermann_hoppe": [0.03, 0.05, 0.92],
    }
    for pid, t4_val in pers_t4_fixes.items():
        pkey = f"personality:{pid}"
        if pkey in rows:
            rows[pkey].setdefault('triangles', {})['4'] = t4_val

    # Non-eligible personalities
    for pid in ["edmund_burke", "margaret_thatcher", "karl_marx", "murray_rothbard", "john_stuart_mill", "piotr_kropotkin"]:
        pkey = f"personality:{pid}"
        if pkey in rows:
            rows[pkey]['editorialBasis']['nativeMatchingEligible'] = False

    # Round2 currents reviewedAt
    round2_ids = {
        "marxismo_leninismo", "trotskismo", "maoismo", "guevarismo", "comunismo_de_conselhos",
        "sindicalismo_revolucionario", "socialismo_democratico", "social_democracia",
        "trabalhismo_desenvolvimentista", "ecossocialismo", "socialismo_fabiano", "socialismo_guildista",
        "eurocomunismo", "liberalismo_social", "centrismo_pragmatico", "tecnocracia_institucional",
        "democracia_crista", "distributismo_comunitarismo", "terceira_via", "liberalismo_classico",
        "ordoliberalismo", "escola_austriaca", "neoliberalismo_friedmaniano", "conservadorismo_liberal",
        "conservadorismo_tradicionalista", "conservadorismo_burkeano", "conservadorismo_fiscal",
        "nacionalismo_civico", "nacional_conservadorismo_populista", "paleoconservadorismo",
        "neoconservadorismo", "anarcocapitalismo", "libertarianismo_minarquista", "mutualismo_proudhoniano",
        "anarquismo_individualista", "anarcocomunismo", "anarcossindicalismo", "ecologismo_politico",
        "decrescimento_economico", "transumanismo_democratico"
    }

    recon_keys = {p["key"] for p in json.loads((ROOT/"tool/curation/editorial_reconstructions.json").read_text())["profiles"] if p["key"].startswith("personality:")}
    dossier_keys = {t for d in DOSSIERS for t in d.get("targets", []) if t.startswith("personality:")}
    tier1_keys = recon_keys | dossier_keys

    core_personality_keys = set()
    for kind,(filename,key,data) in catalogs.items():
        if kind == 'current':
            for row in data[key]:
                if row['id'] in round2_ids:
                    row['editorialBasis']['reviewedAt'] = '2026-11-04'
                n = sum(v.get('relevance',0)>0 for v in row['axes'].values()) + sum(v.get('relevance',0)>0 for v in row['triangles'].values())
                row['editorialBasis']['nativeMatchingEligible'] = n >= 8
                row['editorialBasis']['diagnosticEligibilityMethod'] = 'Mínimo editorial de 8 dimensões parametrizadas; o motor exige também 60% das dimensões válidas do usuário em comum. Não é certificação histórica ou psicométrica e não depende do espectro ou do caráter do regime.'
        elif kind == 'personality':
            for row in data[key]:
                k = f'personality:{row["id"]}'
                row['editorialBasis']['evidenceTier'] = (
                    'tier1_editorial_reconstruction'
                    if k in tier1_keys
                    else 'tier3_preliminary_curation'
                )
                core_personality_keys.add(k)
        elif kind == 'party':
            for row in data[key]:
                if row['id'] == 'black_panther_party':
                    row['editorialBasis']['nativeMatchingEligible'] = False
        elif kind == 'country':
            for row in data[key]:
                if row['id'] == 'japao_pos_guerra':
                    row['editorialBasis']['nativeMatchingEligible'] = False
        data['catalogVersion']='4.4.0'
        (ROOT/f'assets/data/{filename}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    shard_cache={}
    ext_path = ROOT/'assets/data/personalities_extended.json'
    if ext_path.exists():
        ext_data = json.loads(ext_path.read_text())
        for row in ext_data['entries']:
            skey = f'personality:{row["id"]}'
            assert skey not in rows, f'Duplicate extended personality {skey}'
            rows[skey] = row
    def resolve_dims(skey, basis):
        if basis.get('dimensionEvidence'):
            return basis['dimensionEvidence']
        shard = basis.get('dossierShard')
        if not shard:
            return {}
        if shard not in shard_cache:
            spath = ROOT/f'assets/data/dossiers/{shard}.json'
            shard_cache[shard] = json.loads(spath.read_text())['profiles'] if spath.exists() else {}
        return shard_cache[shard].get(skey, {})
    coverage=[]
    for key,row in rows.items():
        basis=row['editorialBasis']; dims=resolve_dims(key, basis)
        coverage.append(dict(key=key,name=row['name'],
            evidenceTier=basis.get('evidenceTier'),
            referenceCount=len(basis['sourceUrls']),
            missingNumericalDimensions=[d for d in DIMENSIONS if not has_coordinate(row,d,key.startswith('current:'))],
            states={d:dims.get(d,{}).get('status','unreviewed') for d in DIMENSIONS},
            primaryLinkedDimensions=sum(e.get('status')=='primary_supported' for e in dims.values()),
            reconstructedDimensions=sum(e.get('status')=='editorial_reconstruction' for e in dims.values()),
            institutionalVoteDimensions=sum(e.get('status')=='institutional_vote' for e in dims.values()),
            references=basis['sourceUrls']))
    counts=Counter()
    categories=defaultdict(Counter)
    def update_cat(cat, row):
        cat['subjects']+=1
        cat['numericallyComplete']+=not row['missingNumericalDimensions']
        cat['missingNumericalDimensions']+=len(row['missingNumericalDimensions'])
        cat['documentedComplete']+=all(s in ['primary_supported','editorial_reconstruction'] for s in row['states'].values())
    for row in coverage:
        counts['subjects']+=1
        counts['withReferences']+=bool(row['referenceCount'])
        counts['withPrimaryPassages']+=bool(row['primaryLinkedDimensions'])
        counts['primaryLinkedDimensions']+=row['primaryLinkedDimensions']
        counts['reconstructedDimensions']+=row['reconstructedDimensions']
        counts['institutionalVoteDimensions']+=row['institutionalVoteDimensions']
        counts.update(row['states'].values())
        update_cat(categories[row['key'].split(':',1)[0]], row)
        if row['key'] in core_personality_keys:
            update_cat(categories['personality_core'], row)
        if row.get('evidenceTier') == 'tier1_editorial_reconstruction':
            update_cat(categories['personality_tier1'], row)
        elif row.get('evidenceTier') == 'tier2_institutional_record':
            update_cat(categories['personality_tier2'], row)
        elif row.get('evidenceTier') == 'tier3_preliminary_curation':
            update_cat(categories['personality_tier3'], row)
    report=dict(date='2026-11-06',catalogVersion='4.4.0',
        notice='Inventário documental de todas as fichas (incluindo catálogo estendido em 3 níveis de evidência); revisão de trechos somente onde declarada. Não equivale a validação integral de todas as posições.',
        counts=dict(counts), competitor=dict(repository='https://github.com/RomanCypherpunk/12axes',
            license='Source-available; reutilização dos perfis e vetores não autorizada',
            used='Leitura de metadados e busca de referências; nenhum texto, resposta ou vetor importado.'),
        categories={k:dict(v) for k,v in categories.items()}, subjects=coverage)
    (ROOT/'docs/primary-coverage-audit-2026-11-05.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    queue = [dict(key=row['key'], name=row['name'], evidenceTier=row.get('evidenceTier'), hasBibliography=row['referenceCount']>0,
                  remainingDimensions=[d for d,status in row['states'].items() if status not in ['primary_supported','editorial_reconstruction','institutional_vote']],
                  missingNumericalDimensions=row['missingNumericalDimensions'],
                  nextAction='Localizar documento primário específico' if row['referenceCount']==0 else 'Ler edição e vincular trecho; separar doutrina, norma e prática')
             for row in coverage if row['missingNumericalDimensions'] or any(status not in ['primary_supported','editorial_reconstruction','institutional_vote'] for status in row['states'].values())]
    (ROOT/'docs/primary-review-queue-2026-11-05.json').write_text(json.dumps(dict(
        notice='Fila completa de pendências; não é uma declaração de revisão concluída.',subjects=queue),ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(report['counts'],ensure_ascii=False))

if __name__=='__main__': run()
