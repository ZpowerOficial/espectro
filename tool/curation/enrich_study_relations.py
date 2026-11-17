#!/usr/bin/env python3
"""Amplia as relações documentadas do Atlas sem criar vínculos por proximidade.

Três fontes de conexão, todas rastreáveis a um documento já registrado:

1. O título ou o metadado de uma fonte da corrente nomeia uma personalidade
   do catálogo. A relação é autoria/referência documental da corrente.
2. O título nomeia uma obra do catálogo. A relação é obra de referência.
3. Duas correntes registram a mesma URL como fonte. A relação explicita que
   compartilhar documento não prova acordo, influência ou filiação.

As personalidades do núcleo que ainda não tinham nenhuma relação recebem uma
conexão editorial com a tradição correspondente, ancorada na fonte primária da
própria ficha. O vínculo é declarado como leitura editorial, não autodeclaração.

Execução idempotente: relações já presentes no JSON estendido ou no arquivo
Dart curado não são duplicadas.
"""
from __future__ import annotations

import json
import re
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "assets" / "data"
RELATIONS_PATH = DATA / "study_relations_extended.json"
BASE_RELATIONS_PATH = ROOT / "lib" / "domain" / "models" / "study_relations.dart"
STUDY_SOURCES_PATH = ROOT / "lib" / "domain" / "models" / "study_sources.dart"

GENERIC_METADATA = "Referência contextual do catálogo."

# Conexões editoriais para as 50 personalidades do núcleo que ainda não
# apareciam em nenhuma relação. Cada item é (id da corrente, tipo).
CORE_PERSONALITY_CURRENTS: dict[str, list[tuple[str, str]]] = {
    "thomas_jefferson": [
        ("republicanismo_classico", "tradition"),
        ("agrarismo_populista", "tradition"),
        ("liberalismo_constitucional", "tradition"),
    ],
    "abraham_lincoln": [
        ("nacionalismo_civico", "tradition"),
        ("republicanismo_civico", "tradition"),
    ],
    "otto_von_bismarck": [
        ("conservadorismo_paternalista", "tradition"),
        ("nacional_conservadorismo_populista", "debate"),
    ],
    "mustafa_kemal_ataturk": [
        ("kemalismo", "tradition"),
        ("nacionalismo_civico", "tradition"),
    ],
    "franklin_d_roosevelt": [("social_liberalismo_keynesiano", "tradition")],
    "winston_churchill": [
        ("conservadorismo_one_nation", "tradition"),
        ("nacionalismo_civico", "debate"),
    ],
    "mahatma_gandhi": [
        ("gandhismo", "tradition"),
        ("pacifismo_radical", "tradition"),
    ],
    "charles_de_gaulle": [("soberanismo_gaullista", "tradition")],
    "clement_attlee": [("social_democracia", "tradition")],
    "konrad_adenauer": [
        ("democracia_crista", "tradition"),
        ("ordoliberalismo", "tradition"),
    ],
    "josip_broz_tito": [
        ("titoismo", "tradition"),
        ("socialismo_autogestionario", "tradition"),
    ],
    "olof_palme": [("social_democracia", "tradition")],
    "salvador_allende": [("socialismo_democratico", "tradition")],
    "lee_kuan_yew": [("capitalismo_de_estado", "tradition")],
    "deng_xiaoping": [
        ("marxismo_leninismo", "tradition"),
        ("capitalismo_de_estado", "debate"),
    ],
    "margaret_thatcher": [
        ("conservadorismo_fiscal", "tradition"),
        ("neoliberalismo_friedmaniano", "tradition"),
    ],
    "ronald_reagan": [
        ("conservadorismo_fiscal", "tradition"),
        ("neoliberalismo_friedmaniano", "tradition"),
    ],
    "nelson_mandela": [
        ("social_democracia", "tradition"),
        ("nacionalismo_de_esquerda", "tradition"),
    ],
    "mikhail_gorbachev": [
        ("social_democracia", "debate"),
        ("eurocomunismo", "debate"),
    ],
    "thomas_sankara": [
        ("sankarismo", "tradition"),
        ("socialismo_africano_ujamaa", "tradition"),
    ],
    "jose_bonifacio": [
        ("monarquismo_constitucional", "tradition"),
        ("nacionalismo_civico", "tradition"),
    ],
    "dom_pedro_ii": [("monarquismo_constitucional", "tradition")],
    "rui_barbosa": [
        ("liberalismo_constitucional", "tradition"),
        ("municipalismo_federalismo", "tradition"),
    ],
    "getulio_vargas": [
        ("varguismo", "tradition"),
        ("trabalhismo_desenvolvimentista", "tradition"),
    ],
    "plinio_salgado": [("integralismo_brasileiro", "tradition")],
    "luis_carlos_prestes": [("marxismo_leninismo", "tradition")],
    "juscelino_kubitschek": [
        ("dirigismo_estatal", "tradition"),
        ("centrismo_pragmatico", "tradition"),
    ],
    "carlos_lacerda": [("conservadorismo_liberal", "tradition")],
    "leonel_brizola": [
        ("brizolismo", "tradition"),
        ("trabalhismo_desenvolvimentista", "tradition"),
    ],
    "ulysses_guimaraes": [
        ("centrismo_pragmatico", "tradition"),
        ("social_liberalismo_keynesiano", "tradition"),
    ],
    "eneas_carneiro": [
        ("nacionalismo_civico", "tradition"),
        ("nacional_conservadorismo_populista", "debate"),
    ],
    "fhc": [
        ("social_democracia", "tradition"),
        ("social_liberalismo_keynesiano", "tradition"),
    ],
    "lula": [
        ("trabalhismo_desenvolvimentista", "tradition"),
        ("socialismo_democratico", "debate"),
    ],
    "jair_bolsonaro": [("nacional_conservadorismo_populista", "tradition")],
    "juan_domingo_peron": [("peronismo_justicialismo", "tradition")],
    "jose_mujica": [
        ("socialismo_democratico", "tradition"),
        ("ecologismo_politico", "debate"),
    ],
    "bernie_sanders": [("socialismo_democratico", "tradition")],
    "angela_merkel": [
        ("democracia_crista", "tradition"),
        ("ordoliberalismo", "tradition"),
    ],
    "emmanuel_macron": [
        ("terceira_via", "tradition"),
        ("liberalismo_social", "tradition"),
    ],
    "javier_milei": [
        ("anarcocapitalismo", "debate"),
        ("libertarianismo_minarquista", "tradition"),
        ("escola_austriaca", "tradition"),
    ],
    "nayib_bukele": [
        ("nacional_conservadorismo_populista", "debate"),
        ("autoritarismo_ordem", "debate"),
    ],
    "giorgia_meloni": [
        ("nacional_conservadorismo_populista", "tradition"),
        ("conservadorismo_tradicionalista", "tradition"),
    ],
    "viktor_orban": [
        ("nacional_conservadorismo_populista", "tradition"),
        ("conservadorismo_tradicionalista", "tradition"),
    ],
    "jacinda_ardern": [("social_democracia", "tradition")],
    "gabriel_boric": [("socialismo_democratico", "tradition")],
    "donald_trump": [
        ("nacional_conservadorismo_populista", "tradition"),
        ("paleoconservadorismo", "tradition"),
    ],
    "xi_jinping": [
        ("marxismo_leninismo", "tradition"),
        ("maoismo", "debate"),
    ],
    "barack_obama": [
        ("social_liberalismo_keynesiano", "tradition"),
        ("terceira_via", "tradition"),
    ],
    "yanis_varoufakis": [
        ("socialismo_democratico", "tradition"),
        ("eurocomunismo", "debate"),
    ],
    "ron_paul": [
        ("paleolibertarianismo", "tradition"),
        ("escola_austriaca", "tradition"),
    ],
}


def normalize(value: str) -> str:
    value = unicodedata.normalize("NFKD", value)
    value = value.encode("ascii", "ignore").decode("ascii").lower()
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def save(path: Path, data) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def all_entries() -> dict[str, list[dict]]:
    files = [
        ("current", "ideological_currents.json", "currents"),
        ("personality", "personalities.json", "entries"),
        ("personality", "personalities_extended.json", "entries"),
        ("book", "books_catalog.json", "entries"),
        ("party", "parties_movements.json", "entries"),
        ("history", "historical_eras.json", "entries"),
        ("country", "countries.json", "entries"),
    ]
    result: dict[str, list[dict]] = defaultdict(list)
    for kind, filename, key in files:
        raw = load(DATA / filename)
        result[kind].extend(raw[key])
    return result


def valid_keys(entries: dict[str, list[dict]]) -> set[str]:
    return {
        f"{kind}:{entry['id']}"
        for kind, rows in entries.items()
        for entry in rows
    }


def base_pairs() -> set[tuple[str, str]]:
    if not BASE_RELATIONS_PATH.exists():
        return set()
    source = BASE_RELATIONS_PATH.read_text(encoding="utf-8")
    return set(
        re.findall(
            r"sourceKey:\s*[\"']([^\"']+)[\"'],\s*targetKey:\s*[\"']([^\"']+)[\"']",
            source,
        )
    )


def current_person_name_map(entries: dict[str, list[dict]]) -> dict[str, dict]:
    names: dict[str, dict] = {}
    # O núcleo tem prioridade caso exista nome repetido no acervo estendido.
    for kind in ("personality",):
        for person in entries[kind]:
            names.setdefault(normalize(person["name"]), person)
    return names


def book_title_map(entries: dict[str, list[dict]]) -> dict[str, dict]:
    return {normalize(book["name"]): book for book in entries["book"]}


def persons_in(text: str, people: dict[str, dict]) -> set[str]:
    found: set[str] = set()
    for parenthetical in re.findall(r"\(([^)]+)\)", text):
        key = normalize(parenthetical)
        if key in people:
            found.add(people[key]["id"])
    key = normalize(text)
    if key in people:
        found.add(people[key]["id"])
    for part in re.split(r"\s+e\s+|\s*;\s*|\s*,\s*", text):
        key = normalize(part)
        if key in people:
            found.add(people[key]["id"])
    return found


def books_in(text: str, books: dict[str, dict]) -> set[str]:
    found: set[str] = set()
    candidates = {normalize(text), normalize(re.sub(r"\s*\([^)]*\)", "", text))}
    for candidate in candidates:
        if candidate in books:
            found.add(books[candidate]["id"])
        for title, book in books.items():
            if len(title) >= 9 and title in candidate and len(candidate) - len(title) < 28:
                found.add(book["id"])
    return found


def auto_relations(
    entries: dict[str, list[dict]],
    people: dict[str, dict],
    books: dict[str, dict],
    people_by_id: dict[str, dict],
) -> list[dict]:
    relations: list[dict] = []
    for current in entries["current"]:
        basis = current.get("editorialBasis") or {}
        urls = basis.get("sourceUrls") or []
        if not urls:
            continue
        titles = basis.get("sourceTitles") or {}
        metadata = basis.get("sourceMetadata") or {}
        for url in urls:
            texts = []
            if titles.get(url):
                texts.append(titles[url])
            meta = metadata.get(url, "")
            if meta and not meta.startswith(GENERIC_METADATA):
                texts.append(meta.split("·")[0])
            person_ids: set[str] = set()
            book_ids: set[str] = set()
            for text in texts:
                person_ids |= persons_in(text, people)
                book_ids |= books_in(text, books)
            for person_id in sorted(person_ids):
                relations.append(
                    {
                        "sourceKey": f"personality:{person_id}",
                        "targetKey": f"current:{current['id']}",
                        "label": "Referência documental da corrente",
                        "note": (
                            f"A fonte registrada para a corrente '{current['name']}' é "
                            f"atribuída a {people_by_id[person_id]['name']}. "
                            "O vínculo permite estudar a relação entre autor e tradição; "
                            "não equivale a filiação a todas as variantes nem a endosso "
                            "de toda a obra."
                        ),
                        "sourceUrl": url,
                        "kind": "tradition",
                    }
                )
            for book_id in sorted(book_ids):
                relations.append(
                    {
                        "sourceKey": f"current:{current['id']}",
                        "targetKey": f"book:{book_id}",
                        "label": "Obra de referência da corrente",
                        "note": (
                            f"Obra citada na documentação de '{current['name']}'. "
                            "A presença no acervo não certifica que o livro inteiro "
                            "corresponda à corrente nem que a obra esgote suas variantes."
                        ),
                        "sourceUrl": url,
                        "kind": "tradition",
                    }
                )
    return relations


def shared_source_relations(entries: dict[str, list[dict]]) -> list[dict]:
    by_url: dict[str, list[dict]] = defaultdict(list)
    for current in entries["current"]:
        for url in (current.get("editorialBasis") or {}).get("sourceUrls") or []:
            by_url[url].append(current)
    relations: list[dict] = []
    for url, currents in by_url.items():
        if len(currents) < 2:
            continue
        for index, left in enumerate(currents):
            for right in currents[index + 1 :]:
                relations.append(
                    {
                        "sourceKey": f"current:{left['id']}",
                        "targetKey": f"current:{right['id']}",
                        "label": "Fonte documental compartilhada",
                        "note": (
                            "As duas correntes registram o mesmo documento como "
                            "referência. Compartilhar a fonte não prova acordo "
                            "doutrinário, influência nem filiação; serve para leitura "
                            "comparada e para localizar divergências de interpretação."
                        ),
                        "sourceUrl": url,
                        "kind": "debate",
                    }
                )
    return relations


def parse_study_sources() -> list[tuple[str, str, list[str]]]:
    """Lê a lista curada de leituras primárias sem alterar o arquivo Dart."""
    if not STUDY_SOURCES_PATH.exists():
        return []
    source = STUDY_SOURCES_PATH.read_text(encoding="utf-8")
    parsed: list[tuple[str, str, list[str]]] = []
    for part in source.split("StudySource(")[1:]:
        block = part.split("\n  ),")[0]
        title_match = re.search(
            r"title:\s*((?:\"(?:[^\"\\]|\\.)*\")|(?:'(?:[^'\\]|\\.)*'))",
            block,
            re.S,
        )
        url_match = re.search(
            r"url:\s*((?:\"(?:[^\"\\]|\\.)*\")|(?:'(?:[^'\\]|\\.)*'))",
            block,
            re.S,
        )
        keys_match = re.search(r"keys:\s*\{(.*?)\}", block, re.S)
        if not (title_match and url_match and keys_match):
            continue
        title = title_match.group(1)[1:-1]
        url = url_match.group(1)[1:-1]
        keys = re.findall(
            r"[\"']((?:current|personality|book|party|history|country):[a-z0-9_]+)[\"']",
            keys_match.group(1),
        )
        parsed.append((title, url, keys))
    return parsed


def reading_list_relations(entries: dict[str, list[dict]]) -> list[dict]:
    """Conecta entidades que a lista curada já reúne sob a mesma leitura."""
    names = {
        f"{kind}:{entry['id']}": entry.get("name", entry["id"])
        for kind, rows in entries.items()
        for entry in rows
    }
    relations: list[dict] = []
    for title, url, keys in parse_study_sources():
        unique_keys = list(dict.fromkeys(keys))
        for index, left in enumerate(unique_keys):
            for right in unique_keys[index + 1 :]:
                if not (left.startswith("current:") or right.startswith("current:")):
                    continue
                if not left.startswith("current:") and right.startswith("current:"):
                    left, right = right, left
                if left == right:
                    continue
                if right.startswith("book:"):
                    label = "Leitura primária da obra"
                    note = (
                        "A obra consta entre as leituras primárias curadas para "
                        f"estudar {names.get(left, left)}. A lista não justifica "
                        "coordenadas numéricas nem esgota a obra."
                    )
                    kind = "tradition"
                else:
                    label = "Leitura primária compartilhada"
                    note = (
                        "A mesma leitura primária registrada no acervo é usada "
                        f"para estudar {names.get(left, left)} e "
                        f"{names.get(right, right)}. Compartilhar a lista é uma "
                        "escolha editorial de leitura; não prova acordo doutrinário, "
                        "influência nem filiação."
                    )
                    kind = "debate"
                relations.append(
                    {
                        "sourceKey": left,
                        "targetKey": right,
                        "label": label,
                        "note": note,
                        "sourceUrl": url,
                        "kind": kind,
                    }
                )
    return relations


def core_personality_relations(entries: dict[str, list[dict]]) -> list[dict]:
    people = {person["id"]: person for person in entries["personality"]}
    currents = {current["id"]: current for current in entries["current"]}
    relations: list[dict] = []
    for person_id, links in CORE_PERSONALITY_CURRENTS.items():
        person = people.get(person_id)
        if not person:
            continue
        basis = person.get("editorialBasis") or {}
        source_urls = basis.get("sourceUrls") or []
        if not source_urls:
            continue
        url = source_urls[0]
        for current_id, kind in links:
            current = currents.get(current_id)
            if not current:
                continue
            if kind == "debate":
                label = "Debate documentado com a tradição"
                note = (
                    f"O documento registrado permite estudar o diálogo e as tensões "
                    f"de {person['name']} com {current['name']}. A conexão é uma "
                    "escolha editorial de leitura; não equivale a endosso mútuo nem "
                    "a identidade doutrinária."
                )
            else:
                label = "Tradição de referência documentada"
                note = (
                    f"A fonte registrada para {person['name']} sustenta o recorte "
                    f"documental desta ficha. A conexão com {current['name']} é uma "
                    "escolha editorial de leitura; não é autodeclaração de filiação "
                    "nem reduz toda a trajetória a um rótulo."
                )
            relations.append(
                {
                    "sourceKey": f"personality:{person_id}",
                    "targetKey": f"current:{current_id}",
                    "label": label,
                    "note": note,
                    "sourceUrl": url,
                    "kind": kind,
                }
            )
    return relations


def dedupe_and_validate(
    candidates: list[dict], seen: set[tuple[str, str]], keys: set[str]
) -> list[dict]:
    accepted: list[dict] = []
    for relation in candidates:
        pair = (relation["sourceKey"], relation["targetKey"])
        if pair in seen or (pair[1], pair[0]) in seen:
            continue
        if relation["sourceKey"] not in keys or relation["targetKey"] not in keys:
            continue
        if not relation["sourceUrl"].startswith("https://"):
            continue
        if urlparse(relation["sourceUrl"]).scheme != "https":
            continue
        seen.add(pair)
        accepted.append(relation)
    return accepted


def main() -> None:
    entries = all_entries()
    people = current_person_name_map(entries)
    people_by_id = {person["id"]: person for person in entries["personality"]}
    books = book_title_map(entries)
    keys = valid_keys(entries)

    raw = load(RELATIONS_PATH)
    existing = raw["relations"]
    seen = {(relation["sourceKey"], relation["targetKey"]) for relation in existing}
    seen |= base_pairs()

    candidates = [
        *auto_relations(entries, people, books, people_by_id),
        *shared_source_relations(entries),
        *reading_list_relations(entries),
        *core_personality_relations(entries),
    ]
    accepted = dedupe_and_validate(candidates, seen, keys)
    accepted.sort(key=lambda item: (item["sourceKey"], item["targetKey"]))
    raw["relations"] = existing + accepted
    save(RELATIONS_PATH, raw)

    kinds = Counter(relation["label"] for relation in accepted)
    print(f"Relações existentes: {len(existing)}")
    print(f"Relações adicionadas: {len(accepted)}")
    for label, count in kinds.most_common():
        print(f"  {label}: {count}")
    print(f"Total: {len(raw['relations'])}")


if __name__ == "__main__":
    main()
