#!/usr/bin/env python3
"""Amplia a documentação das correntes e integra notas das personalidades.

A rodada não cria fontes novas. Para cada corrente, as dimensões já
parametrizadas que ainda não tinham verbete documental recebem uma
`síntese editorial` ancorada na fonte que a própria ficha já declara, usando
a nota doutrinária escrita para aquele eixo ou tríade. O status é distinto de
`primary_supported` para não confundir síntese temática com leitura literal
página a página.

Nas personalidades do núcleo, o script apenas transporta justificativas já
existentes para `coordinateNotes`/`compositionNotes`, de modo que a mesma
documentação apareça no perfil, no motor e na comparação.

Reprodutível e idempotente: executar novamente não duplica evidências nem
limitações.
"""
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "assets" / "data"

AXIS_LABELS = {
    "estrutura": "Estrutura Territorial e Federalismo",
    "representacao": "Representação Política e Democracia",
    "poder": "Poder Executivo e Freios Institucionais",
    "imigracao": "Imigração e Nacionalidade",
    "diplomacia": "Diplomacia e Soberania Internacional",
    "intervencao": "Intervenção e Planejamento Econômico",
    "economia": "Propriedade Econômica e Mercado",
    "controle": "Controle Social e Liberdades Civis",
    "comercio": "Comércio Exterior e Abertura Tarifária",
    "religiao": "Religião e Laicidade",
    "moral": "Costumes e Ética Social",
    "tecnologia": "Tecnologia e Inovação",
}

TRIAD_LABELS = {
    "0": "Economia (Controle, Regulação e Mercados)",
    "1": "Liberdade Individual (Liberdade, Segurança e Verdade)",
    "2": "Cultura (Tradição, Progresso e Liberdade)",
    "3": "Política Externa (Imperialismo, Isolacionismo e Globalismo)",
    "4": "Governo (Democracia, Autoridade e Anarquismo)",
    "5": "Igualdade (Oportunidade, Resultado e Responsabilidade Individual)",
}

GENERIC_METADATA = "Referência contextual do catálogo."
SYNTHESIS_LIMITATION = (
    "As dimensões assinaladas como síntese editorial partem de uma leitura "
    "temática da fonte registrada para a corrente; o localizador indica o eixo "
    "ou a tríade, não uma citação literal página a página."
)
BATCH = "documentation-synthesis-2026-11-13"


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def save(path: Path, data) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def entry_list(raw):
    for key in ("currents", "entries", "parties", "countries", "eras", "books"):
        if key in raw:
            return raw[key]
    raise ValueError("catálogo sem lista reconhecida")


def specific_metadata(value: str) -> bool:
    return bool(value) and not value.startswith(GENERIC_METADATA)


def collect_source_maps() -> tuple[dict[str, str], dict[str, str]]:
    """Reaproveita títulos e metadados já atribuídos a URLs em todo o acervo."""
    titles: dict[str, str] = {}
    metadata: dict[str, str] = {}
    for path in sorted(DATA.glob("*.json")):
        raw = load(path)
        if not isinstance(raw, dict):
            continue
        try:
            entries = entry_list(raw)
        except ValueError:
            continue
        for entry in entries:
            basis = entry.get("editorialBasis") or {}
            for url, title in (basis.get("sourceTitles") or {}).items():
                current = titles.get(url)
                if title and (not current or len(title) > len(current)):
                    titles[url] = title
            for url, meta in (basis.get("sourceMetadata") or {}).items():
                if not specific_metadata(meta):
                    continue
                current = metadata.get(url)
                if not current or len(meta) > len(current):
                    metadata[url] = meta
    return titles, metadata


def fill_source_labels(entry: dict, titles: dict[str, str], metadata: dict[str, str]) -> tuple[int, int]:
    basis = entry.setdefault("editorialBasis", {})
    source_urls = basis.setdefault("sourceUrls", [])
    source_titles = basis.setdefault("sourceTitles", {})
    source_metadata = basis.setdefault("sourceMetadata", {})
    added_titles = added_metadata = 0
    name = entry.get("name") or entry.get("id") or "verbete"

    for url in source_urls:
        if url not in source_titles and url in titles:
            source_titles[url] = titles[url]
            added_titles += 1
        if not specific_metadata(source_metadata.get(url, "")) and url in metadata:
            source_metadata[url] = metadata[url]
            added_metadata += 1
        if not source_metadata.get(url):
            source_metadata[url] = (
                f"Referência registrada para {name}; "
                "tipo documental e edição ainda não conferidos nesta rodada."
            )
            added_metadata += 1

    # Garante metadados para URLs usadas por evidências já existentes.
    for evidence in (basis.get("dimensionEvidence") or {}).values():
        for url in evidence.get("sourceUrls", []):
            if url in source_urls and not source_metadata.get(url):
                source_metadata[url] = (
                    f"Referência registrada para {name}; "
                    "tipo documental e edição ainda não conferidos nesta rodada."
                )
                added_metadata += 1
    return added_titles, added_metadata


def preferred_source_url(basis: dict) -> str | None:
    source_urls = basis.get("sourceUrls") or []
    if not source_urls:
        return None
    metadata = basis.get("sourceMetadata") or {}
    for url in source_urls:
        if specific_metadata(metadata.get(url, "")):
            return url
    return source_urls[0]


def source_title(basis: dict, url: str) -> str:
    title = (basis.get("sourceTitles") or {}).get(url)
    if title:
        return title
    host = urlparse(url).netloc
    return host or "Fonte registrada"


def enrich_currents(currents: list[dict]) -> dict[str, int]:
    added = Counter()
    entries_touched = 0
    for current in currents:
        basis = current.setdefault("editorialBasis", {})
        basis.setdefault("sourceUrls", [])
        basis.setdefault("sourceTitles", {})
        basis.setdefault("sourceMetadata", {})
        evidence = basis.setdefault("dimensionEvidence", {})
        url = preferred_source_url(basis)
        if not url:
            continue
        title = source_title(basis, url)
        before = len(evidence)

        for axis_id, profile in (current.get("axes") or {}).items():
            key = f"axis:{axis_id}"
            if key in evidence:
                continue
            if not isinstance(profile, dict) or profile.get("relevance", 0) <= 0:
                continue
            note = str(profile.get("note", "")).strip()
            if not note or note.startswith("Lacuna explícita"):
                continue
            label = AXIS_LABELS.get(axis_id, axis_id)
            evidence[key] = {
                "status": "editorial_synthesis",
                "locator": f"{title}: leitura temática do eixo {label}",
                "rationale": note,
                "sourceUrls": [url],
            }
            added["axes"] += 1

        for triad_id, profile in (current.get("triangles") or {}).items():
            key = f"triad:{triad_id}"
            if key in evidence:
                continue
            if not isinstance(profile, dict) or profile.get("relevance", 0) <= 0:
                continue
            note = str(profile.get("note", "")).strip()
            if not note or note.startswith("Lacuna explícita"):
                continue
            label = TRIAD_LABELS.get(str(triad_id), f"tríade {triad_id}")
            evidence[key] = {
                "status": "editorial_synthesis",
                "locator": f"{title}: leitura temática da {label}",
                "rationale": note,
                "sourceUrls": [url],
            }
            added["triads"] += 1

        limitations = basis.setdefault("limitations", [])
        if SYNTHESIS_LIMITATION not in limitations:
            limitations.append(SYNTHESIS_LIMITATION)

        if len(evidence) != before:
            entries_touched += 1
        current["documentationBatch"] = BATCH
        basis["empiricallyValidated"] = False
    added["entries"] = entries_touched
    return dict(added)


def enrich_personalities(personalities: list[dict]) -> dict[str, int]:
    added = Counter()
    for person in personalities:
        basis = person.setdefault("editorialBasis", {})
        evidence = basis.get("dimensionEvidence") or {}
        if not evidence:
            continue
        notes = person.setdefault("coordinateNotes", {})
        compositions = person.setdefault("compositionNotes", {})
        for key, item in evidence.items():
            rationale = str(item.get("rationale", "")).strip()
            if not rationale:
                continue
            if key.startswith("axis:"):
                axis_id = key[5:]
                if axis_id not in notes:
                    notes[axis_id] = rationale
                    added["axis_notes"] += 1
            elif key.startswith("triad:"):
                triad_id = key[6:]
                if triad_id not in compositions:
                    compositions[triad_id] = rationale
                    added["triad_notes"] += 1
        person["documentationBatch"] = BATCH
    return dict(added)


def main() -> None:
    titles, metadata = collect_source_maps()

    currents_path = DATA / "ideological_currents.json"
    currents_raw = load(currents_path)
    currents = currents_raw["currents"]
    for current in currents:
        fill_source_labels(current, titles, metadata)
    added_currents = enrich_currents(currents)
    save(currents_path, currents_raw)

    personalities_path = DATA / "personalities.json"
    personalities_raw = load(personalities_path)
    personalities = personalities_raw["entries"]
    for person in personalities:
        fill_source_labels(person, titles, metadata)
    added_people = enrich_personalities(personalities)
    save(personalities_path, personalities_raw)

    print("Correntes:")
    print(f"  evidências de eixo adicionadas: {added_currents.get('axes', 0)}")
    print(f"  evidências de tríade adicionadas: {added_currents.get('triads', 0)}")
    print(f"  fichas alteradas: {added_currents.get('entries', 0)}")
    print("Personalidades do núcleo:")
    print(f"  coordinateNotes adicionadas: {added_people.get('axis_notes', 0)}")
    print(f"  compositionNotes adicionadas: {added_people.get('triad_notes', 0)}")


if __name__ == "__main__":
    main()
