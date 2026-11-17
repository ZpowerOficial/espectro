#!/usr/bin/env python3
"""Importa um catálogo externo licenciado para o slot opcional do Espectro.

O script NÃO baixa nem redistribui dados de terceiros. Ele lê uma pasta que
você forneceu, exige confirmação explícita de direitos e grava apenas o arquivo
`assets/data/external_catalog.json`. Os arquivos editoriais locais não são
alterados.

Formato de entrada esperado (o mesmo usado pelo export do 12axes):

  ideologies.json + ideology-profiles.json
  personalities.json + personality-profiles.json
  countries.json + countries-profiles.json
  parties.json + parties-profiles.json

Cada perfil deve ter `vector` com os 12 eixos em 0..100 (percentual para a
esquerda). O importador converte para a escala local -1..1, sem inventar
tríades nem notas editoriais.

Uso:
  python3 tool/curation/import_external_catalog.py \
    --source-dir /caminho/do/export \
    --source-url https://exemplo.org/catalogo \
    --confirm-rights
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import unicodedata
from pathlib import Path

AXES = [
    "estrutura",
    "representacao",
    "poder",
    "imigracao",
    "diplomacia",
    "intervencao",
    "economia",
    "controle",
    "comercio",
    "religiao",
    "moral",
    "tecnologia",
]

SPECTRUM_BY_CATEGORY = {
    "esquerda radical": "radical_left",
    "esquerda": "left",
    "centro": "center",
    "direita": "right",
    "extrema direita": "far_right",
    "terceira posicao": "third_position",
    "libertario": "libertarian",
    "anarquismo": "anarchist",
}


def normalize(value: str) -> str:
    text = unicodedata.normalize("NFKD", value or "")
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def slug(value: str) -> str:
    text = normalize(value)
    return re.sub(r"[^a-z0-9]+", "_", text).strip("_") or "sem_nome"


def read_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def require_list(path: Path):
    value = read_json(path)
    if not isinstance(value, list):
        raise ValueError(f"{path}: esperada uma lista JSON")
    return value


def profile_map(path: Path, id_key: str) -> dict[str, dict[str, float]]:
    if not path.exists():
        raise FileNotFoundError(f"Perfil ausente: {path}")
    result: dict[str, dict[str, float]] = {}
    for row in require_list(path):
        if not isinstance(row, dict):
            continue
        identifier = row.get(id_key)
        vector = row.get("vector")
        if not isinstance(identifier, str) or not isinstance(vector, dict):
            continue
        result[identifier] = {
            axis: float(vector[axis])
            for axis in AXES
            if axis in vector and isinstance(vector[axis], (int, float))
        }
    return result


def to_mu(left_percent: float) -> float:
    """Converte percentual para a esquerda (0..100) em mu local (-1..1)."""
    return max(-1.0, min(1.0, 1.0 - 2.0 * (left_percent / 100.0)))


def basis(source_url: str, today: str) -> dict:
    return {
        "reviewedAt": today,
        "scope": (
            "Importação de catálogo externo licenciado. Não é uma revisão "
            "editorial local e não substitui as fichas já curadas."
        ),
        "coordinateMethod": (
            "Vetor de 12 eixos em percentual para a esquerda convertido para "
            "-1..1. O importador não cria tríades, notas por dimensão ou "
            "intensidade absoluta."
        ),
        "limitations": [
            "Sem notas editoriais locais por dimensão.",
            "Matching nativo desativado até revisão editorial.",
            "Sem as seis tríades; a cobertura é apenas de 12 eixos.",
        ],
        "sourceUrls": [source_url] if source_url else [],
        "sourceTitles": {source_url: "Catálogo externo"} if source_url else {},
        "sourceMetadata": {"import": "external_catalog"},
        "empiricallyValidated": False,
        "nativeMatchingEligible": False,
        "evidenceTier": "tier3_preliminary_curation",
        "classificationNote": "Dados importados; revisão pendente.",
    }


def short_description(text: str, fallback: str) -> str:
    clean = re.sub(r"\s+", " ", text or "").strip()
    return clean or fallback


def first_sentence(text: str, fallback: str) -> str:
    clean = short_description(text, fallback)
    match = re.match(r"(.+?[.!?])(?:\s|$)", clean)
    return match.group(1).strip() if match else clean


def local_seen(target: Path) -> tuple[set[str], set[str]]:
    """IDs e nomes já presentes no catálogo curado local."""
    ids: set[str] = set()
    names: set[str] = set()
    data_dir = target.parent

    currents_path = data_dir / "ideological_currents.json"
    if currents_path.exists():
        for row in read_json(currents_path).get("currents", []):
            ids.add(str(row.get("id", "")))
            names.add(normalize(str(row.get("name", ""))))

    for filename in [
        "personalities.json",
        "personalities_extended.json",
        "countries.json",
        "parties_movements.json",
        "historical_eras.json",
        "books_catalog.json",
    ]:
        path = data_dir / filename
        if not path.exists():
            continue
        for row in read_json(path).get("entries", []):
            ids.add(str(row.get("id", "")))
            names.add(normalize(str(row.get("name", ""))))

    if target.exists():
        external = read_json(target)
        for row in external.get("currents", []):
            ids.add(str(row.get("id", "")))
            names.add(normalize(str(row.get("name", ""))))
        for rows in (external.get("entries") or {}).values():
            for row in rows:
                ids.add(str(row.get("id", "")))
                names.add(normalize(str(row.get("name", ""))))

    return ids, names


def unique_id(raw: str, prefix: str, used: set[str]) -> str:
    base = f"{prefix}{slug(raw)}"
    candidate = base
    suffix = 2
    while candidate in used:
        candidate = f"{base}_{suffix}"
        suffix += 1
    used.add(candidate)
    return candidate


def convert_currents(
    source_dir: Path,
    used_ids: set[str],
    used_names: set[str],
    source_url: str,
    today: str,
) -> list[dict]:
    catalog_path = source_dir / "ideologies.json"
    if not catalog_path.exists():
        return []
    profiles = profile_map(source_dir / "ideology-profiles.json", "ideologyId")
    rows: list[dict] = []
    for item in require_list(catalog_path):
        if not isinstance(item, dict):
            continue
        source_id = str(item.get("id", ""))
        name = str(item.get("name", "")).strip()
        vector = profiles.get(source_id, {})
        if not name or len(vector) != len(AXES):
            continue
        if normalize(name) in used_names:
            continue
        category = str(item.get("category", "Centro")).strip() or "Centro"
        description = short_description(str(item.get("description", "")), name)
        phrase = short_description(str(item.get("phrase", "")), "")
        identifier = unique_id(source_id or name, "ext12_", used_ids)
        used_names.add(normalize(name))
        rows.append(
            {
                "id": identifier,
                "name": name,
                "family": category,
                "summary": description,
                "keyIdeas": [phrase] if phrase else [first_sentence(description, name)],
                "spectrumId": SPECTRUM_BY_CATEGORY.get(normalize(category), "center"),
                "axes": {
                    axis: {
                        "mu": round(to_mu(value), 4),
                        "sigma": 0.35,
                        "relevance": 0.7,
                        "note": (
                            "Vetor externo de 12 eixos convertido de 0–100 "
                            "para -1..1; sem nota editorial local."
                        ),
                    }
                    for axis, value in vector.items()
                },
                "triangles": {},
                "editorialBasis": basis(source_url, today),
            }
        )
    return rows


def convert_entries(
    source_dir: Path,
    catalog_file: str,
    profile_file: str,
    profile_key: str,
    prefix: str,
    used_ids: set[str],
    used_names: set[str],
    source_url: str,
    today: str,
    *,
    kind: str,
) -> list[dict]:
    catalog_path = source_dir / catalog_file
    if not catalog_path.exists():
        return []
    profiles = profile_map(source_dir / profile_file, profile_key)
    rows: list[dict] = []
    for item in require_list(catalog_path):
        if not isinstance(item, dict):
            continue
        source_id = str(item.get("id", ""))
        name = str(item.get("name", "")).strip()
        vector = profiles.get(source_id, {})
        if not name or len(vector) != len(AXES):
            continue
        if normalize(name) in used_names:
            continue
        description = short_description(str(item.get("description", "")), name)
        category = str(item.get("category", "")).strip() or kind
        if kind == "personality":
            subtitle = str(item.get("role", "")).strip() or category
            era = str(item.get("lifespan", "")).strip() or "Período não informado"
            origin = ""
        elif kind == "country":
            subtitle = category
            era = str(item.get("period", "")).strip() or (
                "Regime histórico" if item.get("historical") else "Contemporâneo"
            )
            origin = name
        else:
            subtitle = category
            era = str(item.get("period", "")).strip() or (
                "Organização histórica" if item.get("historical") else "Contemporâneo"
            )
            origin = str(item.get("countryId", "")).strip()
        identifier = unique_id(source_id or name, prefix, used_ids)
        used_names.add(normalize(name))
        rows.append(
            {
                "id": identifier,
                "name": name,
                "subtitle": subtitle,
                "category": category,
                "era": era,
                "origin": origin,
                "summary": description,
                "highlights": [],
                "quote": None,
                "axes": {
                    axis: round(to_mu(value), 4) for axis, value in vector.items()
                },
                "triangles": {},
                "editorialBasis": basis(source_url, today),
            }
        )
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source-dir",
        required=True,
        type=Path,
        help="Pasta com os JSONs do catálogo externo licenciado.",
    )
    parser.add_argument(
        "--target",
        type=Path,
        default=Path("assets/data/external_catalog.json"),
        help="Arquivo de destino (padrão: assets/data/external_catalog.json).",
    )
    parser.add_argument(
        "--source-url",
        default="",
        help="URL https da fonte/licença, registrada em cada ficha.",
    )
    parser.add_argument(
        "--confirm-rights",
        action="store_true",
        help="Confirma que você tem autorização para usar e redistribuir os dados.",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not args.confirm_rights:
        print(
            "Recusado: use --confirm-rights somente se você tem autorização "
            "escrita para usar e redistribuir este catálogo.",
            file=sys.stderr,
        )
        return 2
    if args.source_url and not args.source_url.startswith("https://"):
        print("--source-url deve começar com https://", file=sys.stderr)
        return 2
    if not args.source_dir.is_dir():
        print(f"Pasta inexistente: {args.source_dir}", file=sys.stderr)
        return 2

    today = dt.date.today().isoformat()
    used_ids, used_names = local_seen(args.target)

    currents = convert_currents(
        args.source_dir, used_ids, used_names, args.source_url, today
    )
    personalities = convert_entries(
        args.source_dir,
        "personalities.json",
        "personality-profiles.json",
        "personalityId",
        "ext12_per_",
        used_ids,
        used_names,
        args.source_url,
        today,
        kind="personality",
    )
    countries = convert_entries(
        args.source_dir,
        "countries.json",
        "countries-profiles.json",
        "countryId",
        "ext12_country_",
        used_ids,
        used_names,
        args.source_url,
        today,
        kind="country",
    )
    parties = convert_entries(
        args.source_dir,
        "parties.json",
        "parties-profiles.json",
        "partyId",
        "ext12_party_",
        used_ids,
        used_names,
        args.source_url,
        today,
        kind="party",
    )

    payload = {
        "schemaVersion": 1,
        "catalogVersion": f"external-{dt.datetime.now().strftime('%Y%m%d%H%M')}",
        "source": args.source_url or str(args.source_dir),
        "importedAt": dt.datetime.now(dt.timezone.utc).isoformat(),
        "currents": currents,
        "entries": {
            "personalities": personalities,
            "countries": countries,
            "parties": parties,
            "history": [],
            "books": [],
        },
    }

    report = {
        "currents": len(currents),
        "personalities": len(personalities),
        "countries": len(countries),
        "parties": len(parties),
        "books": 0,
        "note": "Livros externos são ignorados: o formato não traz vetores.",
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))

    if args.dry_run:
        return 0
    args.target.parent.mkdir(parents=True, exist_ok=True)
    args.target.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Gravado: {args.target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
