"""Reproducible geometric coverage policy. No political or moral blacklist."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
def apply():
    p=ROOT/'assets/data/ideological_currents.json'
    data=json.loads(p.read_text())
    eligible=0
    for row in data['currents']:
        count=sum(v.get('relevance',0)>0 for v in row['axes'].values())+sum(v.get('relevance',0)>0 for v in row['triangles'].values())
        if 'editorialBasis' not in row or not row['editorialBasis']:
            row['editorialBasis'] = {
                'status': 'editorial_provisional',
                'reviewedAt': '2026-11-04',
                'scope': 'Parametrização doutrinária editorial representativa.',
                'sourceUrls': ['https://github.com/RomanCypherpunk/12axes'],
                'coordinateMethod': 'Inferências editoriais ordinais.',
                'limitations': [
                    'Leituras contextuais não justificam precisamente cada número.',
                    'O recorte não resume toda a trajetória da corrente.',
                    'Relações históricas são separadas da proximidade geométrica.'
                ],
                'empiricallyValidated': False,
            }
        basis=row['editorialBasis']
        if not basis.get('limitations'):
            basis['limitations'] = [
                'Leituras contextuais não justificam precisamente cada número.',
                'O recorte não resume toda a trajetória da corrente.',
                'Relações históricas são separadas da proximidade geométrica.'
            ]
        if not basis.get('sourceUrls'):
            basis['sourceUrls'] = ['https://github.com/RomanCypherpunk/12axes']
        basis['nativeMatchingEligible']=count>=8
        basis['diagnosticEligibilityMethod']='Mínimo editorial de 8 dimensões parametrizadas; o motor exige também 60% das dimensões válidas do usuário em comum. Não é certificação histórica ou psicométrica e não depende do espectro ou do caráter do regime.'
        eligible+=count>=8
    p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    print(f'Diagnostic coverage policy: {eligible} eligible of {len(data["currents"])}; no spectrum blacklist')
if __name__=='__main__': apply()
