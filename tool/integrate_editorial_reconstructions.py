"""Replay reviewed editorial answers after older passage-only overrides.

The checked score artifact is produced by the real Flutter engine, not a second
Python implementation. Stale input or changed questions fail closed.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def validate_new_personality(profile):
    """An authority identity or a party label can never publish an empty profile."""
    entry = profile['catalogEntry']
    axes = json.loads((ROOT/'assets/data/twelve_axes.json').read_text())['axes']
    expected = {'axis:'+a['id'] for a in axes} | {'triad:'+str(i) for i in range(6)}
    if (profile.get('mode') != 'complete'
            or set(profile.get('dimensions', {})) != expected
            or len(profile.get('answers', [])) != 60):
        raise ValueError('New personality needs all 18 individually reconstructed dimensions and 60 answers')
    for field in ['id','name','summary','era','origin']:
        if not isinstance(entry.get(field), str) or not entry[field].strip():
            raise ValueError(f'Missing new-personality metadata: {field}')
    if not profile.get('scope') or not profile.get('limitations'):
        raise ValueError('New personality needs a dated scope and explicit limitations')
    for key, reading in profile['dimensions'].items():
        answers = [a for a in profile['answers'] if a['dimension'] == key]
        if (len(answers) != (2 if key.startswith('axis:') else 6)
                or not reading.get('sourceUrls') or not reading.get('locator')
                or not reading.get('rationale')):
            raise ValueError(f'New personality lacks documented reconstruction: {key}')
    # Full anchor/source/engine verification still occurs before writing assets.

def ensure_reconstructed_subjects(rows, catalogs):
    dossier = json.loads((ROOT/'tool/curation/editorial_reconstructions.json').read_text())
    for profile in dossier['profiles']:
        if 'catalogEntry' not in profile: continue
        key = profile['key']
        assert key == 'personality:'+profile['catalogEntry']['id']
        if key not in rows:
            validate_new_personality(profile)
            row = dict(profile['catalogEntry'], axes={}, triangles={})
            catalogs['personality'][2]['entries'].append(row)
            rows[key] = row
        else:
            rows[key].update(profile['catalogEntry'])

def apply_reconstructions(rows):
    dossier = json.loads((ROOT/'tool/curation/editorial_reconstructions.json').read_text())
    scores = json.loads((ROOT/'tool/curation/editorial_reconstruction_scores.json').read_text())
    provenance = scores['_provenance']
    assert provenance['input'] == dossier, 'Editorial scores stale: regenerate with Flutter'
    engine = (ROOT/'lib/domain/models/political_models.dart').read_text()
    assert f"kEspectroEngineVersion = '{provenance['engineVersion']}'" in engine
    assert f"kEspectroBankVersion = '{provenance['bankVersion']}'" in engine
    bank = {}
    for stem in ['twelve_axes','twelve_axes_extra','six_triangles','six_triangles_extra']:
        for q in json.loads((ROOT/f'assets/data/{stem}.json').read_text())['questions']:
            axis = stem.startswith('twelve')
            uid = ('axis:' if axis else 'tri:')+str(q['id'])
            bank[uid] = dict(statement=q['text'],
                weight=q['weight'] if axis else .75+.25*q['strength'],
                polarity=(-1 if q['agreePole']=='LEFT' else 1) if axis else q['multiplier'],
                dimension=q['axisId'] if axis else 'tri_'+str(q['category']))
    for uid, anchor in provenance['anchors'].items():
        assert bank[uid] == anchor, f'Anchor changed: {uid}; regenerate editorial scores'
    for profile in dossier['profiles']:
        key = profile['key']
        partial = profile.get('mode')=='supplement'
        assert key.startswith('personality:') or partial
        row = rows[key]
        result = scores[key]
        if not partial:
            assert len(result['axes']) == 12 and len(result['triangles']) == 6
            assert len(profile['dimensions']) == 18 and len(profile['answers']) == 60
        else:
            assert len(result['axes'])+len(result['triangles'])==len(profile['dimensions'])
        declared = {d['url']:d for d in dossier['sources'].values()}
        for answer in profile['answers']:
            assert answer['dimension'] in profile['dimensions']
            assert type(answer['answer']) is int and -2 <= answer['answer'] <= 2
            assert answer['sourceUrls'] and answer['rationale'] and answer['locator']
            assert answer['statement'] == bank[answer['questionUid']]['statement']
            assert set(answer['sourceUrls']).issubset(declared)
            assert answer['sourceUrls'] == profile['dimensions'][answer['dimension']]['sourceUrls']
        basis = row['editorialBasis']
        method=dossier['method']+' '+(dossier['selection'] if not partial else
            'Complementação parcial: dois itens por eixo ou por vértice das tríades indicadas. Demais coordenadas conservam sua origem e pendências anteriores.')
        basis.update(reviewedAt=dossier['reviewedAt'], scope=profile['scope'],
            coordinateMethod=method,
            limitations=profile['limitations'], empiricallyValidated=False,
            nativeMatchingEligible=False,
            reconstructionVersion=dossier['instrumentVersion'],
            reconstructionEngineVersion=provenance['engineVersion'])
        if not partial: basis['dimensionEvidence'] = {}
        for dimension, reading in profile['dimensions'].items():
            for url in reading['sourceUrls']:
                source = declared[url]
                if url not in basis['sourceUrls']: basis['sourceUrls'].append(url)
                basis['sourceTitles'][url] = source['title']
                basis['sourceMetadata'][url] = f'{source["author"]} · {source["date"]}. '+source.get('provenance','Texto primário em edição ou transcrição digital.')+' Trecho indicado consultado; a intensidade da resposta é reconstrução editorial, não declaração literal do autor.'
            answers = [a for a in profile['answers'] if a['dimension']==dimension]
            assert len(answers)==(2 if dimension.startswith('axis:') else 6)
            note = reading['rationale']+' '+reading['caveat']+' Coordenada derivada de respostas reconstruídas pelo motor; não mede a precisão histórica da inferência.'
            basis['dimensionEvidence'][dimension] = dict(
                status='editorial_reconstruction', locator=reading['locator'],
                rationale=note, sourceUrls=reading['sourceUrls'],
                reconstructedAnswers=[{k:a[k] for k in ['questionUid','statement','answer','rationale']} for a in answers])
            if key.startswith('current:'):
                field,dimension_id = ('axes',dimension[5:]) if dimension.startswith('axis:') else ('triangles',dimension[6:])
                value=result[field][dimension_id]
                row[field][dimension_id]=dict(mu=value,sigma=.65,relevance=.45,note=note)
            elif dimension.startswith('axis:'):
                row.setdefault('coordinateNotes',{})[dimension[5:]] = note
            else:
                row.setdefault('compositionNotes',{})[dimension[6:]] = note
        if not key.startswith('current:'):
            if partial:
                row['axes'].update(result['axes'])
                row['triangles'].update(result['triangles'])
            else:
                row['axes'] = result['axes']
                row['triangles'] = result['triangles']
        # Preserve absolute vertex support as well as the closed composition.
        if not partial:
            basis['reconstructedVertexScores'] = result['triadVertexScores']
            basis['reconstructedEngagement'] = result['triadEngagement']
        else:
            basis.setdefault('reconstructedVertexScores',{}).update(result['triadVertexScores'])
            basis.setdefault('reconstructedEngagement',{}).update(result['triadEngagement'])
        row['editorialReconstructionBatch'] = dossier['instrumentVersion']

if __name__=='__main__':
    raise SystemExit('Run tool/integrate_primary_readings.py (includes this replay).')
