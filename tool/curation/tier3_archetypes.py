"""Ideological baseline templates and builder for Tier 3 preliminary curation.

Axis poles in assets/data/twelve_axes.json:
- estrutura:     -1 Federal           <-> +1 Unitário
- representacao: -1 Democracia        <-> +1 Autocracia
- poder:         -1 Segurança         <-> +1 Liberdade
- imigracao:     -1 Assimilação       <-> +1 Multicultura
- diplomacia:    -1 Militarista       <-> +1 Pacifista
- intervencao:   -1 Não intervenc.    <-> +1 Nacionalista
- economia:      -1 Público           <-> +1 Privado
- controle:      -1 Planejamento      <-> +1 Livre mercado
- comercio:      -1 Protecionismo     <-> +1 Globalismo
- religiao:      -1 Irreligioso       <-> +1 Religioso
- moral:         -1 Progressista      <-> +1 Tradicionalista
- tecnologia:    -1 Tecnologia        <-> +1 Biologia

Triads in assets/data/six_triangles.json:
- 0 Economia:             [Controle, Regulação, Mercados]
- 1 Liberdade Individual: [Liberdade, Segurança, Verdade]
- 2 Cultura:              [Tradição, Progresso, Liberdade]
- 3 Política Externa:     [Imperialismo, Isolacionismo, Globalismo]
- 4 Governo:              [Democracia, Autoridade, Minarquia]
- 5 Igualdade:            [Oportunidade, Resultado, Responsabilidade Individual]
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import unicodedata
from urllib.parse import quote

from tier3_quotes_data import (
    get_tier3_axis_rationale,
    get_tier3_quote,
    get_tier3_triad_rationale,
)

PORTRAITS_MAP_FILE = Path(__file__).resolve().parent / 'tier3_portraits_map.json'
TIER3_PORTRAITS: dict[str, str] = (
    json.loads(PORTRAITS_MAP_FILE.read_text())
    if PORTRAITS_MAP_FILE.exists()
    else {}
)

TEMPLATES: dict[str, dict] = {
    'radical_marxist': {
        'spectrum': 'radical_left',
        'axes': {
            'estrutura': 0.45, 'representacao': 0.25, 'poder': -0.25, 'imigracao': 0.55,
            'diplomacia': -0.15, 'intervencao': -0.35, 'economia': -0.92, 'controle': -0.88,
            'comercio': -0.55, 'religiao': -0.80, 'moral': -0.65, 'tecnologia': -0.45,
        },
        'triads': {
            '0': [0.78, 0.17, 0.05], '1': [0.35, 0.45, 0.20], '2': [0.08, 0.72, 0.20],
            '3': [0.15, 0.20, 0.65], '4': [0.45, 0.48, 0.07], '5': [0.20, 0.75, 0.05],
        },
    },
    'democratic_socialist': {
        'spectrum': 'radical_left',
        'axes': {
            'estrutura': -0.15, 'representacao': -0.78, 'poder': 0.62, 'imigracao': 0.75,
            'diplomacia': 0.65, 'intervencao': -0.45, 'economia': -0.78, 'controle': -0.68,
            'comercio': -0.35, 'religiao': -0.65, 'moral': -0.78, 'tecnologia': 0.35,
        },
        'triads': {
            '0': [0.55, 0.35, 0.10], '1': [0.68, 0.14, 0.18], '2': [0.08, 0.62, 0.30],
            '3': [0.05, 0.25, 0.70], '4': [0.76, 0.12, 0.12], '5': [0.30, 0.62, 0.08],
        },
    },
    'anticolonial_left': {
        'spectrum': 'radical_left',
        'axes': {
            'estrutura': 0.42, 'representacao': -0.20, 'poder': -0.10, 'imigracao': 0.48,
            'diplomacia': -0.10, 'intervencao': 0.55, 'economia': -0.76, 'controle': -0.72,
            'comercio': -0.68, 'religiao': -0.30, 'moral': -0.42, 'tecnologia': -0.25,
        },
        'triads': {
            '0': [0.62, 0.30, 0.08], '1': [0.42, 0.38, 0.20], '2': [0.22, 0.56, 0.22],
            '3': [0.08, 0.42, 0.50], '4': [0.56, 0.36, 0.08], '5': [0.28, 0.64, 0.08],
        },
    },
    'critical_theory': {
        'spectrum': 'left',
        'axes': {
            'estrutura': -0.25, 'representacao': -0.82, 'poder': 0.72, 'imigracao': 0.82,
            'diplomacia': 0.70, 'intervencao': -0.50, 'economia': -0.66, 'controle': -0.55,
            'comercio': -0.22, 'religiao': -0.62, 'moral': -0.84, 'tecnologia': 0.38,
        },
        'triads': {
            '0': [0.44, 0.44, 0.12], '1': [0.72, 0.10, 0.18], '2': [0.06, 0.58, 0.36],
            '3': [0.04, 0.18, 0.78], '4': [0.78, 0.08, 0.14], '5': [0.32, 0.60, 0.08],
        },
    },
    'social_democrat': {
        'spectrum': 'left',
        'axes': {
            'estrutura': 0.10, 'representacao': -0.80, 'poder': 0.48, 'imigracao': 0.60,
            'diplomacia': 0.52, 'intervencao': -0.25, 'economia': -0.52, 'controle': -0.42,
            'comercio': 0.15, 'religiao': -0.48, 'moral': -0.62, 'tecnologia': 0.28,
        },
        'triads': {
            '0': [0.30, 0.52, 0.18], '1': [0.58, 0.22, 0.20], '2': [0.12, 0.56, 0.32],
            '3': [0.06, 0.20, 0.74], '4': [0.74, 0.14, 0.12], '5': [0.44, 0.46, 0.10],
        },
    },
    'labor_populist': {
        'spectrum': 'left',
        'axes': {
            'estrutura': 0.45, 'representacao': -0.42, 'poder': 0.12, 'imigracao': 0.32,
            'diplomacia': 0.22, 'intervencao': 0.58, 'economia': -0.62, 'controle': -0.64,
            'comercio': -0.65, 'religiao': -0.10, 'moral': -0.28, 'tecnologia': -0.22,
        },
        'triads': {
            '0': [0.52, 0.36, 0.12], '1': [0.42, 0.36, 0.22], '2': [0.26, 0.48, 0.26],
            '3': [0.12, 0.48, 0.40], '4': [0.60, 0.30, 0.10], '5': [0.36, 0.52, 0.12],
        },
    },
    'green_progressive': {
        'spectrum': 'left',
        'axes': {
            'estrutura': -0.38, 'representacao': -0.82, 'poder': 0.64, 'imigracao': 0.72,
            'diplomacia': 0.78, 'intervencao': -0.42, 'economia': -0.48, 'controle': -0.46,
            'comercio': -0.18, 'religiao': -0.42, 'moral': -0.74, 'tecnologia': 0.82,
        },
        'triads': {
            '0': [0.32, 0.54, 0.14], '1': [0.66, 0.14, 0.20], '2': [0.12, 0.58, 0.30],
            '3': [0.04, 0.18, 0.78], '4': [0.76, 0.10, 0.14], '5': [0.42, 0.48, 0.10],
        },
    },
    'social_liberal': {
        'spectrum': 'center',
        'axes': {
            'estrutura': -0.12, 'representacao': -0.82, 'poder': 0.55, 'imigracao': 0.56,
            'diplomacia': 0.38, 'intervencao': -0.18, 'economia': -0.12, 'controle': 0.08,
            'comercio': 0.48, 'religiao': -0.45, 'moral': -0.56, 'tecnologia': 0.12,
        },
        'triads': {
            '0': [0.16, 0.52, 0.32], '1': [0.62, 0.18, 0.20], '2': [0.14, 0.48, 0.38],
            '3': [0.08, 0.16, 0.76], '4': [0.72, 0.12, 0.16], '5': [0.56, 0.26, 0.18],
        },
    },
    'third_way_centrist': {
        'spectrum': 'center',
        'axes': {
            'estrutura': 0.08, 'representacao': -0.76, 'poder': 0.25, 'imigracao': 0.42,
            'diplomacia': 0.15, 'intervencao': -0.12, 'economia': 0.18, 'controle': 0.32,
            'comercio': 0.65, 'religiao': -0.28, 'moral': -0.38, 'tecnologia': -0.18,
        },
        'triads': {
            '0': [0.12, 0.48, 0.40], '1': [0.48, 0.30, 0.22], '2': [0.18, 0.44, 0.38],
            '3': [0.14, 0.12, 0.74], '4': [0.68, 0.16, 0.16], '5': [0.58, 0.18, 0.24],
        },
    },
    'civic_republican': {
        'spectrum': 'center',
        'axes': {
            'estrutura': -0.22, 'representacao': -0.78, 'poder': 0.44, 'imigracao': 0.28,
            'diplomacia': 0.18, 'intervencao': 0.15, 'economia': -0.05, 'controle': 0.02,
            'comercio': 0.22, 'religiao': -0.32, 'moral': -0.24, 'tecnologia': -0.05,
        },
        'triads': {
            '0': [0.18, 0.50, 0.32], '1': [0.54, 0.22, 0.24], '2': [0.24, 0.40, 0.36],
            '3': [0.10, 0.28, 0.62], '4': [0.74, 0.14, 0.12], '5': [0.58, 0.22, 0.20],
        },
    },
    'christian_democrat': {
        'spectrum': 'center',
        'axes': {
            'estrutura': -0.28, 'representacao': -0.72, 'poder': 0.12, 'imigracao': 0.15,
            'diplomacia': 0.32, 'intervencao': -0.08, 'economia': 0.08, 'controle': 0.12,
            'comercio': 0.42, 'religiao': 0.48, 'moral': 0.32, 'tecnologia': 0.16,
        },
        'triads': {
            '0': [0.16, 0.52, 0.32], '1': [0.38, 0.32, 0.30], '2': [0.44, 0.24, 0.32],
            '3': [0.08, 0.20, 0.72], '4': [0.66, 0.20, 0.14], '5': [0.50, 0.24, 0.26],
        },
    },
    'classical_liberal': {
        'spectrum': 'right',
        'axes': {
            'estrutura': -0.35, 'representacao': -0.68, 'poder': 0.62, 'imigracao': 0.32,
            'diplomacia': 0.28, 'intervencao': -0.35, 'economia': 0.72, 'controle': 0.78,
            'comercio': 0.78, 'religiao': -0.25, 'moral': -0.18, 'tecnologia': -0.32,
        },
        'triads': {
            '0': [0.06, 0.24, 0.70], '1': [0.66, 0.16, 0.18], '2': [0.20, 0.28, 0.52],
            '3': [0.08, 0.28, 0.64], '4': [0.52, 0.10, 0.38], '5': [0.46, 0.06, 0.48],
        },
    },
    'market_economist': {
        'spectrum': 'right',
        'axes': {
            'estrutura': -0.20, 'representacao': -0.64, 'poder': 0.45, 'imigracao': 0.38,
            'diplomacia': 0.18, 'intervencao': -0.25, 'economia': 0.78, 'controle': 0.82,
            'comercio': 0.84, 'religiao': -0.22, 'moral': -0.12, 'tecnologia': -0.42,
        },
        'triads': {
            '0': [0.05, 0.23, 0.72], '1': [0.58, 0.20, 0.22], '2': [0.18, 0.30, 0.52],
            '3': [0.10, 0.20, 0.70], '4': [0.48, 0.12, 0.40], '5': [0.44, 0.06, 0.50],
        },
    },
    'liberal_conservative': {
        'spectrum': 'right',
        'axes': {
            'estrutura': -0.15, 'representacao': -0.62, 'poder': -0.18, 'imigracao': -0.22,
            'diplomacia': -0.18, 'intervencao': 0.18, 'economia': 0.58, 'controle': 0.60,
            'comercio': 0.52, 'religiao': 0.32, 'moral': 0.38, 'tecnologia': -0.24,
        },
        'triads': {
            '0': [0.08, 0.32, 0.60], '1': [0.38, 0.38, 0.24], '2': [0.46, 0.18, 0.36],
            '3': [0.18, 0.26, 0.56], '4': [0.54, 0.22, 0.24], '5': [0.44, 0.10, 0.46],
        },
    },
    'traditional_conservative': {
        'spectrum': 'right',
        'axes': {
            'estrutura': 0.12, 'representacao': -0.18, 'poder': -0.52, 'imigracao': -0.58,
            'diplomacia': -0.32, 'intervencao': 0.48, 'economia': 0.35, 'controle': 0.28,
            'comercio': -0.15, 'religiao': 0.72, 'moral': 0.78, 'tecnologia': 0.18,
        },
        'triads': {
            '0': [0.18, 0.42, 0.40], '1': [0.20, 0.48, 0.32], '2': [0.68, 0.10, 0.22],
            '3': [0.24, 0.48, 0.28], '4': [0.36, 0.46, 0.18], '5': [0.32, 0.14, 0.54],
        },
    },
    'state_developmentalist': {
        'spectrum': 'right',
        'axes': {
            'estrutura': 0.58, 'representacao': 0.05, 'poder': -0.38, 'imigracao': -0.22,
            'diplomacia': -0.28, 'intervencao': 0.62, 'economia': -0.15, 'controle': -0.35,
            'comercio': -0.45, 'religiao': 0.18, 'moral': 0.28, 'tecnologia': -0.55,
        },
        'triads': {
            '0': [0.42, 0.40, 0.18], '1': [0.24, 0.52, 0.24], '2': [0.42, 0.36, 0.22],
            '3': [0.22, 0.48, 0.30], '4': [0.34, 0.54, 0.12], '5': [0.44, 0.24, 0.32],
        },
    },
    'national_populist_right': {
        'spectrum': 'far_right',
        'axes': {
            'estrutura': 0.28, 'representacao': 0.22, 'poder': -0.68, 'imigracao': -0.82,
            'diplomacia': -0.48, 'intervencao': 0.78, 'economia': 0.42, 'controle': 0.32,
            'comercio': -0.48, 'religiao': 0.65, 'moral': 0.80, 'tecnologia': -0.35,
        },
        'triads': {
            '0': [0.20, 0.34, 0.46], '1': [0.20, 0.58, 0.22], '2': [0.70, 0.08, 0.22],
            '3': [0.26, 0.58, 0.16], '4': [0.28, 0.54, 0.18], '5': [0.28, 0.10, 0.62],
        },
    },
    'authoritarian_right': {
        'spectrum': 'far_right',
        'axes': {
            'estrutura': 0.72, 'representacao': 0.82, 'poder': -0.86, 'imigracao': -0.76,
            'diplomacia': -0.72, 'intervencao': 0.78, 'economia': 0.22, 'controle': -0.18,
            'comercio': -0.38, 'religiao': 0.62, 'moral': 0.82, 'tecnologia': -0.32,
        },
        'triads': {
            '0': [0.36, 0.36, 0.28], '1': [0.08, 0.68, 0.24], '2': [0.74, 0.10, 0.16],
            '3': [0.48, 0.40, 0.12], '4': [0.08, 0.82, 0.10], '5': [0.26, 0.12, 0.62],
        },
    },
    'libertarian_market': {
        'spectrum': 'libertarian',
        'axes': {
            'estrutura': -0.72, 'representacao': -0.45, 'poder': 0.82, 'imigracao': 0.45,
            'diplomacia': 0.52, 'intervencao': -0.75, 'economia': 0.90, 'controle': 0.92,
            'comercio': 0.88, 'religiao': -0.25, 'moral': -0.22, 'tecnologia': -0.48,
        },
        'triads': {
            '0': [0.03, 0.09, 0.88], '1': [0.78, 0.08, 0.14], '2': [0.16, 0.22, 0.62],
            '3': [0.04, 0.48, 0.48], '4': [0.26, 0.06, 0.68], '5': [0.34, 0.04, 0.62],
        },
    },
    'anarchist_libertarian_left': {
        'spectrum': 'anarchist',
        'axes': {
            'estrutura': -0.92, 'representacao': -0.88, 'poder': 0.90, 'imigracao': 0.86,
            'diplomacia': 0.78, 'intervencao': -0.82, 'economia': -0.82, 'controle': -0.58,
            'comercio': 0.12, 'religiao': -0.78, 'moral': -0.84, 'tecnologia': 0.28,
        },
        'triads': {
            '0': [0.52, 0.28, 0.20], '1': [0.82, 0.06, 0.12], '2': [0.06, 0.46, 0.48],
            '3': [0.03, 0.32, 0.65], '4': [0.72, 0.04, 0.24], '5': [0.26, 0.66, 0.08],
        },
    },
    'corporatist_third_position': {
        'spectrum': 'third_position',
        'axes': {
            'estrutura': 0.68, 'representacao': 0.45, 'poder': -0.58, 'imigracao': -0.48,
            'diplomacia': -0.42, 'intervencao': 0.76, 'economia': -0.22, 'controle': -0.52,
            'comercio': -0.68, 'religiao': 0.42, 'moral': 0.52, 'tecnologia': -0.28,
        },
        'triads': {
            '0': [0.50, 0.36, 0.14], '1': [0.16, 0.58, 0.26], '2': [0.58, 0.22, 0.20],
            '3': [0.32, 0.52, 0.16], '4': [0.22, 0.68, 0.10], '5': [0.36, 0.36, 0.28],
        },
    },
}


def normalize_text(value: str) -> str:
    nfkd = unicodedata.normalize('NFKD', value)
    ascii_str = ''.join(c for c in nfkd if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', ' ', ascii_str.lower()).strip()


def slugify(value: str) -> str:
    return normalize_text(value).replace(' ', '_')


def wiki_url(lang: str, page_title: str) -> str:
    return f"https://{lang}.wikipedia.org/wiki/{quote(page_title.replace(' ', '_'), safe=':_()-,.')}"


def materialize_tier3(spec: tuple, used_ids: set[str], seen_vectors: set[str]) -> tuple[dict, dict]:
    """Convert compact tuple spec into (slim_entry, shard_dimension_evidence).

    spec = (name, subtitle, category, era, origin, template_id, summary, highlights, url_or_wiki, axis_mods)
    """
    name, subtitle, category, era, origin, tpl_id, summary, highlights, ref, axis_mods = spec
    tpl = TEMPLATES[tpl_id]

    cand_id = slugify(name)
    if cand_id in used_ids:
        cand_id = slugify(f'{name}_{origin}')
    if cand_id in used_ids:
        h = hashlib.sha1(f'{name}|{era}|{origin}'.encode('utf-8')).hexdigest()[:6]
        cand_id = f'{cand_id}_{h}'
    used_ids.add(cand_id)

    # Deterministic per-person micro-perturbation so two thinkers in the same
    # family never collapse onto an identical synthetic clone vector, while
    # respecting explicit per-person `axis_mods`.
    digest = hashlib.sha256(f'{cand_id}|{era}|{subtitle}'.encode('utf-8')).digest()
    axes: dict[str, float] = {}
    for idx, (aid, base_v) in enumerate(tpl['axes'].items()):
        delta = ((digest[idx] / 255.0) - 0.5) * 0.14
        val = axis_mods.get(aid, base_v + delta)
        axes[aid] = round(max(-0.98, min(0.98, float(val))), 4)

    sig = repr(sorted(axes.items()))
    bump = 1
    while sig in seen_vectors:
        axes['economia'] = round(max(-0.98, min(0.98, axes['economia'] + 0.0031 * bump)), 4)
        sig = repr(sorted(axes.items()))
        bump += 1
    seen_vectors.add(sig)

    triangles: dict[str, list[float]] = {}
    for idx, (tid, base_comp) in enumerate(tpl['triads'].items()):
        d0 = ((digest[12 + idx] / 255.0) - 0.5) * 0.06
        d1 = ((digest[18 + idx] / 255.0) - 0.5) * 0.06
        v0 = max(0.02, base_comp[0] + d0)
        v1 = max(0.02, base_comp[1] + d1)
        v2 = max(0.02, base_comp[2] - (d0 + d1) * 0.5)
        s = v0 + v1 + v2
        r0 = round(v0 / s, 4)
        r1 = round(v1 / s, 4)
        r2 = round(1.0 - r0 - r1, 4)
        triangles[tid] = [r0, r1, r2]

    if ref.startswith('https://'):
        url = ref
    elif ':' in ref:
        lang, title = ref.split(':', 1)
        url = wiki_url(lang, title)
    else:
        url = wiki_url('en', ref)

    coord_notes = {aid: get_tier3_axis_rationale(name, era, aid, axes[aid], origin) for aid in axes}
    comp_notes = {tid: get_tier3_triad_rationale(name, era, tid, triangles[tid]) for tid in triangles}

    dim_evidence: dict[str, dict] = {}
    locator_str = f'Formulação intelectual e trajetória ({name}, {era}) documentada em referências biográficas e de estudo.'
    for aid in axes:
        dim_evidence[f'axis:{aid}'] = {
            'status': 'unreviewed',
            'locator': locator_str,
            'rationale': coord_notes[aid],
            'sourceUrls': [url],
        }
    for tid in triangles:
        dim_evidence[f'triad:{tid}'] = {
            'status': 'unreviewed',
            'locator': locator_str,
            'rationale': comp_notes[tid],
            'sourceUrls': [url],
        }

    spectrum_id = axis_mods.get('_spectrum', tpl['spectrum'])
    quote_text = get_tier3_quote(name, summary, highlights, era, origin)
    photo_url = TIER3_PORTRAITS.get(name)
    entry = {
        'id': cand_id,
        'name': name,
        'subtitle': subtitle,
        'category': category,
        'era': era,
        'origin': origin,
        'photoUrl': photo_url,
        'summary': summary,
        'highlights': list(highlights),
        'quote': quote_text,
        'spectrumId': spectrum_id,
        'axes': axes,
        'triangles': triangles,
        'coordinateNotes': coord_notes,
        'compositionNotes': comp_notes,
        'editorialBasis': {
            'reviewedAt': '2026-11-06',
            'evidenceTier': 'tier3_preliminary_curation',
            'scope': f'{name} ({origin}, {era}) — ficha de curadoria preliminar para exploração comparativa.',
            'coordinateMethod': (
                'Estimativa editorial preliminar baseada na trajetória pública e produção intelectual conhecida; '
                'ainda não revisada por trechos primários individuais nem por respostas reconstruídas item a item.'
            ),
            'classificationNote': (
                'Agrupamento editorial aproximado de estudo; autores e lideranças históricas frequentemente '
                'atravessam mais de uma escola ou mudam de posição ao longo do tempo.'
            ),
            'limitations': [
                'Curadoria preliminar (Nível 3): coordenadas servem à navegação exploratória e aguardam auditoria por trecho primário.',
                'A referência vinculada identifica o verbete histórico/biográfico, sem certificar calibração psicométrica.',
            ],
            'sourceUrls': [url],
            'sourceTitles': {url: f'Referência biográfica e bibliográfica — {name}'},
            'sourceMetadata': {
                url: (
                    f'{name} ({origin}, {era}). Referência contextual de identificação biográfica e bibliográfica '
                    '(Curadoria Preliminar — Nível 3); leitura de trechos primários por dimensão ainda pendente.'
                )
            },
            'empiricallyValidated': False,
            'nativeMatchingEligible': False,
        },
    }
    return entry, dim_evidence
