"""Build `assets/data/personalities_extended.json` and lazy-loaded `assets/data/dossiers/shard_XX.json`.

Combines:
- Tier 2 (`tier2_institutional_record`): Brazilian federal deputies & senators scored strictly
  from their own documented plenary nominal `Sim`/`Não` votes (never imputed by party label).
- Tier 3 (`tier3_preliminary_curation`): Curated global and Brazilian historical/contemporary
  thinkers, jurists, economists, and statesmen with explicit preliminary curation labels.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
sys.path.insert(0, str(ROOT / 'tool/curation'))

from build_legislative_profiles import build_legislative_profiles  # noqa: E402
from tier3_archetypes import materialize_tier3, normalize_text  # noqa: E402
from tier3_part1_brazil import BRAZIL_SPECS  # noqa: E402
from tier3_part2_americas import AMERICAS_SPECS  # noqa: E402
from tier3_part3a_europe_classics import EUROPE_CLASSICS_SPECS  # noqa: E402
from tier3_part3b_europe_modern_thinkers import EUROPE_MODERN_THINKERS_SPECS  # noqa: E402
from tier3_part4a_europe_west_leaders import EUROPE_WEST_LEADERS_SPECS  # noqa: E402
from tier3_part4b_europe_south_east_leaders import EUROPE_SOUTH_EAST_LEADERS_SPECS  # noqa: E402
from tier3_part5a_asia_philosophers_leaders import ASIA_SPECS  # noqa: E402
from tier3_part5b_mena_africa_oceania import MENA_AFRICA_OCEANIA_SPECS  # noqa: E402
from tier3_part6a_nobel_economists_jurists import NOBEL_ECONOMISTS_JURISTS_SPECS  # noqa: E402
from tier3_part6b_social_political_theorists import SOCIAL_POLITICAL_THEORISTS_SPECS  # noqa: E402
from tier3_part6c_world_statesmen_history import WORLD_STATESMEN_HISTORY_SPECS  # noqa: E402
from tier3_part6d_brazil_jurists_intellectuals import BRAZIL_JURISTS_INTELLECTUALS_SPECS  # noqa: E402
from tier3_part6e_libertarian_conservative_global import LIBERTARIAN_CONSERVATIVE_GLOBAL_SPECS  # noqa: E402

SHARD_COUNT = 16
VALID_SPECTRA = {
    'radical_left', 'left', 'center', 'right',
    'far_right', 'anarchist', 'libertarian', 'third_position',
}


def shard_for_key(subject_key: str) -> str:
    bucket = int(hashlib.md5(subject_key.encode('utf-8')).hexdigest()[:8], 16) % SHARD_COUNT
    return f'shard_{bucket:02d}'


def run() -> dict:
    core_data = json.loads((ROOT / 'assets/data/personalities.json').read_text())
    core_entries = core_data['entries']
    used_ids: set[str] = {row['id'] for row in core_entries}
    seen_names: set[str] = {normalize_text(row['name']) for row in core_entries}

    tier2_pairs = build_legislative_profiles(set(used_ids), set(seen_names))
    for entry, _ in tier2_pairs:
        assert entry['id'] not in used_ids, f"Duplicate Tier 2 ID: {entry['id']}"
        used_ids.add(entry['id'])
        seen_names.add(normalize_text(entry['name']))
        bare = re.sub(r'\s*\([A-Z]{2}\)$', '', entry['name'])
        seen_names.add(normalize_text(bare))

    all_tier3_specs = (
        BRAZIL_SPECS
        + BRAZIL_JURISTS_INTELLECTUALS_SPECS
        + AMERICAS_SPECS
        + EUROPE_CLASSICS_SPECS
        + EUROPE_MODERN_THINKERS_SPECS
        + EUROPE_WEST_LEADERS_SPECS
        + EUROPE_SOUTH_EAST_LEADERS_SPECS
        + ASIA_SPECS
        + MENA_AFRICA_OCEANIA_SPECS
        + NOBEL_ECONOMISTS_JURISTS_SPECS
        + SOCIAL_POLITICAL_THEORISTS_SPECS
        + WORLD_STATESMEN_HISTORY_SPECS
        + LIBERTARIAN_CONSERVATIVE_GLOBAL_SPECS
    )

    seen_vectors: set[str] = set()
    tier3_pairs: list[tuple[dict, dict]] = []
    skipped_overlaps = 0
    for spec in all_tier3_specs:
        norm_name = normalize_text(spec[0])
        if norm_name in seen_names:
            skipped_overlaps += 1
            continue
        seen_names.add(norm_name)
        entry, dim_ev = materialize_tier3(spec, used_ids, seen_vectors)
        tier3_pairs.append((entry, dim_ev))

    extended_entries: list[dict] = []
    shards: dict[str, dict[str, dict]] = {f'shard_{i:02d}': {} for i in range(SHARD_COUNT)}
    tier_counts = Counter()
    spectrum_counts = Counter()

    for entry, dim_ev in (tier2_pairs + tier3_pairs):
        assert len(entry['summary'].strip()) >= 45, f"Short summary on {entry['id']}"
        assert len(entry['highlights']) >= 3, f"Too few highlights on {entry['id']}"
        assert entry['spectrumId'] in VALID_SPECTRA, f"Invalid spectrum {entry['spectrumId']} on {entry['id']}"
        subject_key = f"personality:{entry['id']}"
        shard_id = shard_for_key(subject_key)
        entry.pop('coordinateNotes', None)
        entry.pop('compositionNotes', None)
        basis = entry['editorialBasis']
        basis.pop('dimensionEvidence', None)
        basis['dossierShard'] = shard_id
        shards[shard_id][subject_key] = dim_ev
        extended_entries.append(entry)
        tier_counts[basis['evidenceTier']] += 1
        spectrum_counts[entry['spectrumId']] += 1

    dossiers_dir = ROOT / 'assets/data/dossiers'
    dossiers_dir.mkdir(parents=True, exist_ok=True)
    for shard_id, profiles in sorted(shards.items()):
        shard_payload = {
            'schemaVersion': 1,
            'catalogVersion': '4.4.0',
            'shard': shard_id,
            'profiles': profiles,
        }
        (dossiers_dir / f'{shard_id}.json').write_text(
            json.dumps(shard_payload, ensure_ascii=False, separators=(',', ':')) + '\n'
        )

    extended_payload = {
        'schemaVersion': 1,
        'catalogVersion': '4.4.0',
        'entries': extended_entries,
    }
    (ROOT / 'assets/data/personalities_extended.json').write_text(
        json.dumps(extended_payload, ensure_ascii=False, separators=(',', ':')) + '\n'
    )

    summary = {
        'coreTier1': len(core_entries),
        'extendedTotal': len(extended_entries),
        'tier2Institutional': tier_counts['tier2_institutional_record'],
        'tier3Preliminary': tier_counts['tier3_preliminary_curation'],
        'skippedOverlaps': skipped_overlaps,
        'grandTotalPersonalities': len(core_entries) + len(extended_entries),
        'spectraExtended': dict(spectrum_counts),
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return summary


if __name__ == '__main__':
    run()
