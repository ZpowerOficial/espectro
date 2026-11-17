"""Integrate authentic primary documentation across parties, countries, eras and books."""
from __future__ import annotations

import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tool' / 'curation'))

from party_documentation_data import PARTY_DOCUMENTATION
from country_documentation_data import COUNTRY_DOCUMENTATION
from era_documentation_data import ERA_DOCUMENTATION
from book_documentation_data import BOOK_DOCUMENTATION


def apply_documentation(file_path: Path, doc_map: dict[str, dict], update_spectrum: bool = False):
    raw = json.loads(file_path.read_text())
    entries = raw.get('entries', raw.get('parties', raw.get('countries', raw.get('eras', raw.get('books', [])))))
    
    updated_count = 0
    for entry in entries:
        eid = entry['id']
        if eid not in doc_map:
            continue
            
        doc = doc_map[eid]
        url = doc['url']
        title = doc['title']
        metadata = doc['metadata']
        scope = doc['scope']
        evidence_dict = doc.get('evidence', {})
        
        eb = entry.setdefault('editorialBasis', {})
        eb['reviewedAt'] = '2026-11-09'
        eb['scope'] = scope
        eb['coordinateMethod'] = (
            'Leitura documental por trecho, com direção qualitativa e estimativas numéricas editoriais separadas. '
            'Dimensões sem revisão não são declaradas como ausência de evidência histórica.'
        )
        eb['limitations'] = [
            'Este verbete reflete fontes primárias, manifestos, tratados ou textos constitucionais fundamentais; '
            'intensidades editoriais não constituem autodeclaração dos sujeitos históricos.'
        ]
        
        source_urls = eb.setdefault('sourceUrls', [])
        if url not in source_urls:
            source_urls.append(url)
            
        eb.setdefault('sourceTitles', {})[url] = title
        eb.setdefault('sourceMetadata', {})[url] = metadata
        eb['empiricallyValidated'] = False
        eb['nativeMatchingEligible'] = False
        
        dim_ev = eb.setdefault('dimensionEvidence', {})
        for dim, (loc, rat) in evidence_dict.items():
            dim_ev[dim] = {
                'status': 'primary_supported',
                'locator': f'{title}: {loc}',
                'rationale': rat,
                'sourceUrls': [url],
            }
            
        if update_spectrum and 'spectrumId' in doc:
            entry['spectrumId'] = doc['spectrumId']
            
        updated_count += 1
        
    file_path.write_text(json.dumps(raw, ensure_ascii=False, indent=2) + '\n')
    print(f'Updated {updated_count} entries in {file_path.name}')


def run():
    print('Applying party documentation...')
    apply_documentation(ROOT / 'assets/data/parties_movements.json', PARTY_DOCUMENTATION, update_spectrum=True)
    
    print('Applying country documentation...')
    apply_documentation(ROOT / 'assets/data/countries.json', COUNTRY_DOCUMENTATION)
    
    print('Applying era documentation...')
    apply_documentation(ROOT / 'assets/data/historical_eras.json', ERA_DOCUMENTATION)
    
    print('Applying book documentation...')
    apply_documentation(ROOT / 'assets/data/books_catalog.json', BOOK_DOCUMENTATION)
    
    print('All documentation integrated successfully!')


if __name__ == '__main__':
    run()
