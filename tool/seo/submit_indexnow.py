#!/usr/bin/env python3
"""
Submete automaticamente todas as URLs do `sitemap.xml` para o protocolo oficial
IndexNow (`api.indexnow.org`), que notifica instantaneamente Microsoft Bing,
DuckDuckGo, Yandex, Naver, Seznam e indexadores parceiros de IA (ChatGPT Search).
"""

from __future__ import annotations

import json
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

HOST = "espectro-politico.web.app"
KEY = "e8a9c4b2d1f7403a9e6c8b2d5a1f3e70"
KEY_LOCATION = f"https://{HOST}/{KEY}.txt"
ENDPOINT = "https://api.indexnow.org/indexnow"


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    sitemap_path = root / "build" / "web" / "sitemap.xml"
    if not sitemap_path.exists():
        print("sitemap.xml not found in build/web")
        return

    tree = ET.parse(sitemap_path)
    ns = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    urls = [el.text.strip() for el in tree.findall(".//sm:loc", ns) if el.text]
    print(f"Found {len(urls)} URLs in sitemap.xml")

    # IndexNow aceita lotes de até 10.000 URLs por requisição
    batch_size = 1000
    for i in range(0, len(urls), batch_size):
        chunk = urls[i : i + batch_size]
        payload = json.dumps(
            {
                "host": HOST,
                "key": KEY,
                "keyLocation": KEY_LOCATION,
                "urlList": chunk,
            }
        ).encode("utf-8")
        req = urllib.request.Request(
            ENDPOINT,
            data=payload,
            headers={
                "Content-Type": "application/json; charset=utf-8",
                "User-Agent": "EspectroSEO/1.0",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                print(
                    f"Batch {i // batch_size + 1} ({len(chunk)} URLs): HTTP {resp.status}"
                )
        except Exception as e:
            print(f"Batch {i // batch_size + 1} failed: {e}")


if __name__ == "__main__":
    main()
