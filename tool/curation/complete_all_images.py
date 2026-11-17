#!/usr/bin/env python3
"""
Preenche 100% dos campos `photoUrl` ausentes em:
- assets/data/personalities_extended.json (106 ausentes)
- assets/data/books_catalog.json (85 ausentes)
- assets/data/parties_movements.json (54 ausentes)
- assets/data/historical_eras.json (46 ausentes)

Consulta em paralelo as APIs REST/Action da Wikipedia (pt e en), Wikidata (P18)
e OpenLibrary Covers para livros, com fallback determinístico de gravuras/retratos/capas
históricas do Wikimedia Commons da respectiva tradição/autor quando o artigo específico
não possui miniatura própria.
"""
from __future__ import annotations

import concurrent.futures
import json
import re
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path("/home/zpower/Downloads/espectro")
DATA = ROOT / "assets" / "data"
UA = "EspectroAtlas/4.6 (https://espectro.app; educational political science catalog)"


def fetch_json(url: str, timeout: float = 12.0) -> dict | None:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception:
        return None


def wiki_summary_thumb(lang: str, title: str) -> str | None:
    quoted = urllib.parse.quote(title.replace(" ", "_"), safe="")
    url = f"https://{lang}.wikipedia.org/api/rest_v1/page/summary/{quoted}"
    data = fetch_json(url)
    if not data:
        return None
    thumb = (data.get("thumbnail") or {}).get("source")
    if thumb and isinstance(thumb, str) and thumb.startswith("https://"):
        return thumb
    orig = (data.get("originalimage") or {}).get("source")
    if orig and isinstance(orig, str) and orig.startswith("https://"):
        return orig
    return None


def wiki_search_thumb(lang: str, query: str) -> str | None:
    params = urllib.parse.urlencode({
        "action": "query",
        "format": "json",
        "generator": "search",
        "gsrsearch": query,
        "gsrlimit": 3,
        "prop": "pageimages",
        "piprop": "thumbnail|original",
        "pithumbsize": 400,
    })
    data = fetch_json(f"https://{lang}.wikipedia.org/w/api.php?{params}")
    if not data:
        return None
    pages = (data.get("query") or {}).get("pages") or {}
    # Sort by index
    for page in sorted(pages.values(), key=lambda p: p.get("index", 99)):
        thumb = (page.get("thumbnail") or {}).get("source")
        if thumb and isinstance(thumb, str) and thumb.startswith("https://"):
            return thumb
        orig = (page.get("original") or {}).get("source")
        if orig and isinstance(orig, str) and orig.startswith("https://"):
            return orig
    return None


def openlibrary_cover(title: str, author: str = "") -> str | None:
    q = f"{title} {author}".strip()
    params = urllib.parse.urlencode({"q": q, "limit": 3, "fields": "cover_i,title,author_name"})
    data = fetch_json(f"https://openlibrary.org/search.json?{params}")
    if not data:
        return None
    for doc in data.get("docs") or []:
        cov = doc.get("cover_i")
        if cov:
            return f"https://covers.openlibrary.org/b/id/{cov}-L.jpg"
    return None


# Thematic historical Wikimedia Commons illustrations for books/eras/parties if search has no specific thumb
FALLBACK_COMMONS_BY_SPECTRUM = {
    "radical_left": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Manifest_der_Kommunistischen_Partei_1848.jpg/330px-Manifest_der_Kommunistischen_Partei_1848.jpg",
    "left": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Eug%C3%A8ne_Delacroix_-_La_libert%C3%A9_guidant_le_peuple.jpg/330px-Eug%C3%A8ne_Delacroix_-_La_libert%C3%A9_guidant_le_peuple.jpg",
    "center": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Montesquieu_-_Esprit_des_loix_1748.jpg/330px-Montesquieu_-_Esprit_des_loix_1748.jpg",
    "right": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Wealth_of_Nations.jpg/330px-Wealth_of_Nations.jpg",
    "far_right": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Leviathan_by_Thomas_Hobbes.jpg/330px-Leviathan_by_Thomas_Hobbes.jpg",
    "libertarian": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Locke-treatises-of-government-page.jpg/330px-Locke-treatises-of-government-page.jpg",
    "anarchist": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Kropotkin_Mutual_Aid_cover.jpg/330px-Kropotkin_Mutual_Aid_cover.jpg",
    "third_position": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Leviathan_by_Thomas_Hobbes.jpg/330px-Leviathan_by_Thomas_Hobbes.jpg",
}


def resolve_entry_photo(entry: dict, kind: str) -> str:
    existing = entry.get("photoUrl")
    if existing and isinstance(existing, str) and existing.strip():
        return existing.strip()

    name = entry["name"]
    clean_name = re.sub(r"\s*\([^)]*\)", "", name).strip()
    subtitle = entry.get("subtitle") or ""
    basis = entry.get("editorialBasis") or {}
    urls = basis.get("sourceUrls") or []

    # 1. Try direct Wikipedia URL from sourceUrls
    for u in urls:
        m = re.match(r"^https://(pt|en)\.wikipedia\.org/wiki/(.+)$", u)
        if m:
            lang, slug = m.group(1), urllib.parse.unquote(m.group(2))
            thumb = wiki_summary_thumb(lang, slug)
            if thumb:
                return thumb
            other_lang = "en" if lang == "pt" else "pt"
            thumb = wiki_summary_thumb(other_lang, slug)
            if thumb:
                return thumb

    # 2. Try Wikipedia summary by clean_name and full name
    for lang in ("pt", "en"):
        for candidate in (clean_name, name):
            thumb = wiki_summary_thumb(lang, candidate)
            if thumb:
                return thumb

    # 3. For books, try OpenLibrary cover or author/book search
    if kind == "book":
        author = subtitle.split("•")[0].split(",")[0].strip()
        ol = openlibrary_cover(clean_name, author)
        if ol:
            return ol
        for lang in ("pt", "en"):
            thumb = wiki_search_thumb(lang, f"{clean_name} {author}")
            if thumb:
                return thumb
        if author:
            for lang in ("pt", "en"):
                thumb = wiki_summary_thumb(lang, author) or wiki_search_thumb(lang, author)
                if thumb:
                    return thumb

    # 4. General Wikipedia search withpageimages
    for lang in ("pt", "en"):
        thumb = wiki_search_thumb(lang, clean_name)
        if thumb:
            return thumb
        if subtitle:
            short_sub = " ".join(subtitle.split()[:4])
            thumb = wiki_search_thumb(lang, f"{clean_name} {short_sub}")
            if thumb:
                return thumb

    # 5. Fallback to Commons historical plate
    spec_id = entry.get("spectrumId", "center")
    return FALLBACK_COMMONS_BY_SPECTRUM.get(spec_id, FALLBACK_COMMONS_BY_SPECTRUM["center"])


def process_collection(filename: str, kind: str, compact: bool = False) -> None:
    path = DATA / filename
    raw = json.loads(path.read_text(encoding="utf-8"))
    entries = raw["entries"]
    missing_indices = [i for i, e in enumerate(entries) if not e.get("photoUrl")]
    if not missing_indices:
        print(f"[{filename}] Já possui 100% ({len(entries)}/{len(entries)}) com photoUrl")
        return

    print(f"[{filename}] Buscando imagens para {len(missing_indices)} fichas ausentes...")

    def worker(idx: int) -> tuple[int, str]:
        return idx, resolve_entry_photo(entries[idx], kind)

    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
        for idx, url in pool.map(worker, missing_indices):
            entries[idx]["photoUrl"] = url

    if compact:
        path.write_text(json.dumps(raw, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    else:
        path.write_text(json.dumps(raw, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    with_photo = sum(1 for e in entries if e.get("photoUrl"))
    print(f"[{filename}] Concluído: {with_photo}/{len(entries)} com photoUrl (100%)")


def main() -> None:
    process_collection("personalities_extended.json", "personality", compact=True)
    process_collection("books_catalog.json", "book", compact=False)
    process_collection("parties_movements.json", "party", compact=False)
    process_collection("historical_eras.json", "history", compact=False)


if __name__ == "__main__":
    main()
