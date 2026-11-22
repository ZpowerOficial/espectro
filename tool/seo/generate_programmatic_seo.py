#!/usr/bin/env python3
"""
Gerador de SEO Programático e GEO (Generative Engine Optimization para IAs) do Espectro.

Gera automaticamente em `build/web/`:
1. `/p/<kind>-<id>.html`: Mais de 1.500 páginas HTML estáticas semânticas para cada
   Espectro, Corrente Ideológica (289), Pensador/Economista/Estadista Canônico (760+),
   Livro Clássico (165), País (81), Partido/Movimento (110) e Era Histórica (94),
   com Schema.org JSON-LD (`Article` + `FAQPage` + `BreadcrumbList`), barras dos
   12 Eixos, 6 Tríades, bibliografia, links internos cruzados e Google AdSense.
2. `/catalogo.html`: Hub HTML mestre indexável conectando todas as 1.500+ páginas.
3. `/llms.txt` e `/llms-full.txt`: Diretórios estruturados no padrão LLM/GEO para
   citação direta por ChatGPT/SearchGPT, Perplexity, Claude, Gemini e Google AI Overviews.
4. `/sitemap.xml` e `/robots.txt`: Mapa completo com todas as URLs canônicas.
"""

from __future__ import annotations

import html
import json
import os
import re
from pathlib import Path
from urllib.parse import quote

BASE_URL = "https://espectro-politico.web.app"
ADSENSE_CLIENT = "ca-pub-1519935796466095"
ADSENSE_SLOT_TOP = "8975287447"
ADSENSE_SLOT_BOTTOM = "8975287447"
GA4_ID = "G-XP4L3LL18B"
TODAY = "2026-11-16"

GA4_SNIPPET = f"""  <script async src="https://www.googletagmanager.com/gtag/js?id={GA4_ID}"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){{dataLayer.push(arguments);}}
    gtag('set', 'cookie_domain', 'none');
    gtag('js', new Date());
    gtag('config', '{GA4_ID}', {{
      cookie_domain: 'none',
      cookie_flags: 'SameSite=Lax;Secure',
      anonymize_ip: true
    }});
  </script>"""

SPECTRA_META = {
    "radical_left": ("Esquerda Radical", "Crítica estrutural ao capitalismo, socialização dos meios de produção e transformação revolucionária."),
    "left": ("Esquerda", "Redução das desigualdades, Estado de bem-estar social, direitos trabalhistas e democracia social."),
    "center": ("Centro & Reformismo", "Equilíbrio institucional, economia mista, constitucionalismo e reformas graduais."),
    "right": ("Direita", "Economia de mercado, propriedade privada, ordem institucional, prudência histórica e responsabilidade fiscal."),
    "far_right": ("Extrema-Direita", "Radicalizações nacionalistas, teocráticas ou autoritárias de direita segundo critérios historiográficos."),
    "libertarian": ("Libertários", "Autopropriedade, livre mercado, associação voluntária e redução drástica ou abolição do Estado."),
    "anarchist": ("Anarquistas", "Autogestão, federalismo livre, apoio mútuo e abolição do Estado e das hierarquias coercitivas."),
    "third_position": ("Terceira Posição", "Projetos corporativistas, nacional-sindicalistas ou estatistas que reivindicam alternativa ao liberalismo e ao marxismo."),
}

KIND_LABELS = {
    "current": ("Corrente Ideológica", "Correntes Ideológicas"),
    "personality": ("Pensador / Estadista", "Pensadores, Economistas & Estadistas"),
    "book": ("Livro & Obra Clássica", "Livros & Obras Clássicas"),
    "country": ("País & Modelo de Estado", "Países & Modelos de Estado"),
    "party": ("Partido & Movimento", "Partidos & Movimentos"),
    "history": ("Era & Regime Histórico", "Eras & Regimes Históricos"),
}


def _typographic_quotes(text: str) -> str:
    """Converte aspas retas duplas e travessões em pontuação tipográfica limpa."""
    s = text.replace(" — ", ": ").replace("—", ", ")
    s = re.sub(r"(\d)\s*[–]\s*(\d)", r"\1-\2", s)
    s = s.replace(" – ", ", ").replace("–", ", ")
    out = []
    open_q = True
    for ch in s:
        if ch == '"':
            out.append("“" if open_q else "”")
            open_q = not open_q
        else:
            out.append(ch)
    return "".join(out)


def esc(text: str | None) -> str:
    cleaned = _typographic_quotes(str(text or ""))
    return html.escape(cleaned, quote=True)


def clean_text(text: str | None) -> str:
    return _typographic_quotes(str(text or ""))


def excerpt(text: str | None, max_len: int = 145) -> str:
    clean = " ".join(clean_text(text).split())
    if len(clean) <= max_len:
        return clean
    cut = clean[:max_len].rsplit(" ", 1)[0].rstrip(" ,;:-")
    return f"{cut}…" if cut else f"{clean[:max_len]}…"


def is_canonical_personality(entry: dict) -> bool:
    basis = entry.get("editorialBasis") or {}
    if basis.get("evidenceTier") == "tier2_institutional_record":
        return False
    cat = (entry.get("category") or "").lower()
    sub = (entry.get("subtitle") or "").lower()
    if any(k in cat or k in sub for k in ("youtuber", "influencer", "divulgador", "comunicador", "podcaster")):
        return False
    return True


def load_all_items(root: Path):
    data_dir = root / "assets" / "data"

    with open(data_dir / "twelve_axes.json", encoding="utf-8") as f:
        axes_meta = {a["id"]: a for a in json.load(f)["axes"]}
    with open(data_dir / "six_triangles.json", encoding="utf-8") as f:
        triads_meta = {int(t["id"]): t for t in json.load(f)["categories"]}

    items = []

    # 1. Ideological Currents (289)
    with open(data_dir / "ideological_currents.json", encoding="utf-8") as f:
        for c in json.load(f)["currents"]:
            axes = {k: float(v["mu"]) for k, v in (c.get("axes") or {}).items() if isinstance(v, dict) and "mu" in v}
            triads = {int(k): v["mu"] for k, v in (c.get("triangles") or {}).items() if isinstance(v, dict) and "mu" in v}
            basis = c.get("editorialBasis") or {}
            items.append({
                "kind": "current",
                "id": c["id"],
                "slug": f"current-{c['id']}",
                "key": f"current:{c['id']}",
                "name": c["name"],
                "subtitle": c.get("family") or "Corrente Ideológica",
                "summary": c.get("summary") or "",
                "spectrumId": c.get("spectrumId") or "center",
                "ideas": c.get("keyIdeas") or [],
                "axes": axes,
                "triads": triads,
                "sources": list((basis.get("sourceTitles") or {}).items()),
            })

    # 2. Personalities (Main + Extended Canonical)
    seen_pers = set()
    for fname in ("personalities.json", "personalities_extended.json"):
        with open(data_dir / fname, encoding="utf-8") as f:
            for e in json.load(f)["entries"]:
                if e["id"] in seen_pers:
                    continue
                if fname == "personalities_extended.json" and not is_canonical_personality(e):
                    continue
                seen_pers.add(e["id"])
                basis = e.get("editorialBasis") or {}
                items.append({
                    "kind": "personality",
                    "id": e["id"],
                    "slug": f"personality-{e['id']}",
                    "key": f"personality:{e['id']}",
                    "name": e["name"],
                    "subtitle": f"{e.get('subtitle', '')}, {e.get('era', '')} ({e.get('origin', '')})".strip(" ,").replace(" ()", ""),
                    "summary": e.get("summary") or "",
                    "spectrumId": e.get("spectrumId") or "center",
                    "ideas": e.get("highlights") or [],
                    "axes": {k: float(v) for k, v in (e.get("axes") or {}).items()},
                    "triads": {int(k): v for k, v in (e.get("triangles") or {}).items()},
                    "sources": list((basis.get("sourceTitles") or {}).items()),
                })

    # 3. Books, Countries, Parties, Historical Eras
    for kind, fname in (
        ("book", "books_catalog.json"),
        ("country", "countries.json"),
        ("party", "parties_movements.json"),
        ("history", "historical_eras.json"),
    ):
        with open(data_dir / fname, encoding="utf-8") as f:
            for e in json.load(f)["entries"]:
                basis = e.get("editorialBasis") or {}
                items.append({
                    "kind": kind,
                    "id": e["id"],
                    "slug": f"{kind}-{e['id']}",
                    "key": f"{kind}:{e['id']}",
                    "name": e["name"],
                    "subtitle": f"{e.get('subtitle', '')}, {e.get('era', '')}".strip(" ,"),
                    "summary": e.get("summary") or "",
                    "spectrumId": e.get("spectrumId") or "center",
                    "ideas": e.get("highlights") or [],
                    "axes": {k: float(v) for k, v in (e.get("axes") or {}).items()},
                    "triads": {int(k): v for k, v in (e.get("triangles") or {}).items()},
                    "sources": list((basis.get("sourceTitles") or {}).items()),
                })

    return items, axes_meta, triads_meta


CSS_STYLE = """/* Hallmark · genre: editorial · shape: long document · posture: dark · nav: inline · footer: rule */
:root {
  color-scheme: dark;
  --bg: #0B0F16;
  --surface: #121822;
  --surface-muted: #192130;
  --topbar-bg: rgba(11, 15, 22, 0.94);
  --line: #232D3F;
  --line-soft: rgba(35, 45, 63, 0.55);
  --ad-bg: rgba(18, 24, 34, 0.78);
  --ink: #F2F4F8;
  --muted: #8C97AE;
  --accent: #9A92F0;
  --amber: #E5A448;
  --amber-ink: #140D03;
  --teal: #71C7C5;
  --font-body: -apple-system, BlinkMacSystemFont, "IBM Plex Sans", "Segoe UI", Roboto, sans-serif;
}
* { box-sizing: border-box; }
html, body {
  margin: 0;
  overflow-x: clip;
  font-family: var(--font-body);
  background: var(--bg);
  color: var(--ink);
  line-height: 1.65;
}
.skip-link {
  position: absolute;
  left: -9999px;
  top: 0;
  z-index: 10000;
  background: var(--amber);
  color: var(--amber-ink);
  font-weight: 700;
  padding: 0.55rem 0.95rem;
  border-radius: 0 0 8px 0;
  text-decoration: none;
}
.skip-link:focus {
  left: 0.75rem;
  top: 0.75rem;
}
a,
button {
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
  transition: transform 150ms cubic-bezier(0.23, 1, 0.32, 1), background-color 150ms ease, border-color 150ms ease, color 150ms ease;
}
a:focus-visible,
button:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
a:active,
button:active {
  transform: scale(0.97);
}
@media (hover: hover) and (pointer: fine) {
  .cta-btn:hover {
    filter: brightness(1.06);
    transform: translateY(-1px);
  }
  .cta-btn.secondary:hover {
    border-color: var(--accent);
    filter: none;
  }
  .link-chip:hover {
    border-color: var(--accent);
    transform: translateY(-1px);
  }
  .source-link:hover,
  .breadcrumb a:hover,
  footer a:hover {
    color: var(--amber);
    text-decoration: underline;
    text-underline-offset: 3px;
  }
}
h1, h2, h3 {
  overflow-wrap: break-word;
  min-width: 0;
  text-wrap: balance;
  color: var(--ink);
}
h2, h3, section[id] {
  scroll-margin-top: 76px;
}
.axis-row,
.triad-row,
td,
.badge,
.stat {
  font-variant-numeric: tabular-nums;
}
header.topbar {
  border-bottom: 1px solid var(--line);
  background: var(--topbar-bg);
  padding: 0.9rem 1.25rem;
  position: sticky;
  top: 0;
  z-index: 10;
}
.topbar-inner {
  max-width: 960px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}
.brand {
  color: var(--ink);
  text-decoration: none;
  font-weight: 800;
  letter-spacing: 0.01em;
  display: flex;
  align-items: baseline;
  gap: 0.55rem;
}
.brand-tag {
  color: var(--muted);
  font-weight: 500;
  font-size: 0.9rem;
}
.nav-actions,
.btn-row {
  display: flex;
  gap: 0.65rem;
  flex-wrap: wrap;
}
.cta-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  background: var(--amber);
  color: var(--amber-ink);
  font-weight: 700;
  text-decoration: none;
  padding: 0.62rem 1.15rem;
  border-radius: 10px;
  font-size: 0.92rem;
  line-height: 1.35;
  white-space: nowrap;
  text-align: center;
  max-width: 100%;
}
.cta-btn.secondary {
  background: var(--surface-muted);
  color: var(--ink);
  border: 1px solid var(--line);
}
main.container {
  max-width: 960px;
  margin: 0 auto;
  padding: 2rem 1.25rem 4rem;
}
.breadcrumb {
  font-size: 0.85rem;
  color: var(--muted);
  margin-bottom: 1rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem 0.5rem;
}
.breadcrumb a {
  color: var(--accent);
  text-decoration: none;
}
h1 {
  font-size: clamp(1.75rem, 3.5vw, 2.5rem);
  margin: 0 0 0.45rem;
  line-height: 1.18;
}
.kicker {
  color: var(--amber);
  font-size: 0.9rem;
  font-weight: 600;
  margin: 0 0 0.4rem;
}
.subtitle {
  color: var(--muted);
  font-size: 1.05rem;
  max-width: 65ch;
  margin-bottom: 1.25rem;
}
.card {
  background: var(--surface);
  color: var(--ink);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 1.4rem;
  margin-bottom: 1.25rem;
}
.card h2 {
  margin-top: 0;
  font-size: 1.2rem;
}
.card-summary {
  margin-bottom: 1.2rem;
  max-width: 65ch;
  color: var(--ink);
}
.muted-note {
  color: var(--muted);
  font-size: 0.9rem;
  margin-top: 0;
  max-width: 65ch;
}
.source-link {
  color: var(--accent);
  text-decoration: none;
}
.axis-row {
  padding: 0.65rem 0;
  border-bottom: 1px solid var(--line-soft);
}
.axis-row:last-child { border-bottom: none; }
.axis-head {
  display: flex;
  justify-content: space-between;
  gap: 0.75rem;
  font-weight: 600;
  font-size: 0.95rem;
}
.axis-val {
  color: var(--accent);
}
.axis-poles {
  display: flex;
  justify-content: space-between;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: var(--muted);
}
.axis-bar {
  height: 8px;
  background: var(--surface-muted);
  border-radius: 999px;
  margin: 0.35rem 0;
  overflow: hidden;
  position: relative;
}
.axis-fill {
  height: 100%;
  background: var(--accent);
  border-radius: 999px;
}
.triad-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
}
.triad-parts {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem 1rem;
  color: var(--muted);
  font-size: 0.9rem;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 0.85rem;
}
.link-chip {
  display: block;
  background: var(--surface-muted);
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 0.75rem 1rem;
  color: var(--ink);
  text-decoration: none;
  font-weight: 600;
}
.link-chip small {
  display: block;
  color: var(--muted);
  font-weight: 400;
  font-size: 0.82rem;
}
.ad-box {
  display: block;
  background: transparent;
  color: var(--ink);
  border: 0;
  border-radius: 12px;
  padding: 0;
  margin: 0;
  min-height: 0;
  text-align: center;
}
.ad-box:has(ins[data-ad-status="unfilled"]) {
  display: none !important;
}
.ad-box:has(ins[data-ad-status="filled"]) {
  background: var(--ad-bg);
  border: 1px solid var(--line);
  padding: 0.65rem;
  margin: 1.5rem 0;
}
.ad-box:has(ins[data-ad-status="unfill-optimized"]) {
  margin: 1.5rem 0;
}
.ad-label {
  display: none;
  font-size: 0.75rem;
  color: var(--muted);
  margin-bottom: 0.35rem;
}
.ad-box:has(ins[data-ad-status="filled"]) .ad-label {
  display: block;
}
footer {
  border-top: 1px solid var(--line);
  padding: 2rem 1.25rem;
  text-align: center;
  color: var(--muted);
  font-size: 0.88rem;
}
.footer-links {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 0.5rem 1.25rem;
}
footer a { color: var(--teal); text-decoration: none; }
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
"""

ADSENSE_HEAD_LOADER = f"""  <meta name="google-adsense-account" content="{ADSENSE_CLIENT}">
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client={ADSENSE_CLIENT}" crossorigin="anonymous"></script>"""


def render_ad_slot(slot_id: str) -> str:
    return f"""
    <aside class="ad-box" aria-label="Publicidade">
      <div class="ad-label">Publicidade</div>
      <ins class="adsbygoogle"
           style="display:block"
           data-ad-client="{ADSENSE_CLIENT}"
           data-ad-slot="{slot_id}"
           data-ad-format="auto"
           data-full-width-responsive="true"></ins>
      <script>
        try {{
          (window.adsbygoogle = window.adsbygoogle || []).push({{}});
        }} catch (_) {{}}
      </script>
    </aside>
    """


def render_item_page(item: dict, axes_meta: dict, triads_meta: dict, related: list[dict]) -> str:
    kind_singular, kind_plural = KIND_LABELS[item["kind"]]
    spec_name, _ = SPECTRA_META.get(item["spectrumId"], ("Centro & Reformismo", ""))
    url = f"{BASE_URL}/p/{item['slug']}.html"
    app_deep_link = f"/#/atlas?v=1&subject={quote(item['key'])}"
    teia_deep_link = f"/#/atlas?v=1&view=map&select={quote(item['key'])}"

    title = f"{clean_text(item['name'])} no Espectro Político: 12 Eixos e {kind_singular} | Espectro"
    desc = f"{clean_text(item['name'])} ({clean_text(item['subtitle'])}) no Espectro: {excerpt(item['summary'], 145)} Veja as posições exatas nos 12 eixos políticos, 6 tríades de valores e fontes primárias."
    keywords = f"{clean_text(item['name'])}, {clean_text(item['name'])} espectro, {clean_text(item['name'])} espectro político, {clean_text(item['name'])} posicionamento político, {kind_singular}, {spec_name}, 12 eixos, Espectro observatório político"

    schema_entity_type = {
        "personality": "Person",
        "book": "Book",
        "country": "Country",
        "party": "Organization",
        "current": "DefinedTerm",
        "history": "HistoricalEvent",
    }.get(item["kind"], "Thing")

    # Axes rows
    axes_html = []
    top_poles = []
    for aid, meta in axes_meta.items():
        val = item["axes"].get(aid)
        if val is None:
            continue
        pct_right = int(round((val + 1.0) * 50.0))
        pct_left = 100 - pct_right
        dominant = f"{pct_left}% {meta['leftPole']}" if val < -0.08 else (f"{pct_right}% {meta['rightPole']}" if val > 0.08 else "Equilíbrio central (50% / 50%)")
        if abs(val) >= 0.35 and len(top_poles) < 4:
            top_poles.append(f"{meta['label']}: {dominant}")
        axes_html.append(f"""
        <div class="axis-row">
          <div class="axis-head">
            <span>{esc(meta['label'])}</span>
            <span class="axis-val">{esc(dominant)}</span>
          </div>
          <div class="axis-bar"><div class="axis-fill" style="width:{pct_right}%"></div></div>
          <div class="axis-poles">
            <span>{esc(meta['leftPole'])} ({pct_left}%)</span>
            <span>{esc(meta['rightPole'])} ({pct_right}%)</span>
          </div>
        </div>
        """)

    # Triads rows
    triads_html = []
    for tid, tmeta in triads_meta.items():
        comp = item["triads"].get(tid)
        if not comp or len(comp) != 3:
            continue
        subs = tmeta["subcategories"]
        parts = [f"<span>{esc(subs[i])}: <strong>{int(round(comp[i] * 100))}%</strong></span>" for i in range(3)]
        triads_html.append(f"""
        <div class="axis-row">
          <div class="triad-title">{esc(tmeta['label'])}</div>
          <div class="triad-parts">{''.join(parts)}</div>
        </div>
        """)

    ideas_html = "".join(f"<li>{esc(idea)}</li>" for idea in item["ideas"])
    sources_html = "".join(
        f'<li><a class="source-link" href="{html.escape(u, quote=True)}" rel="noopener noreferrer" target="_blank">{esc(t)}</a></li>'
        for u, t in item["sources"][:8]
    )
    related_html = "".join(
        f'<a class="link-chip" href="/p/{r["slug"]}.html">{esc(r["name"])}<small>{esc(KIND_LABELS[r["kind"]][0])}: {esc(SPECTRA_META.get(r["spectrumId"], ("",))[0])}</small></a>'
        for r in related[:6]
    )

    faq_a1 = f"No modelo multidimensional do Espectro, {item['name']} situa-se no espectro {spec_name}. {item['summary']}"
    faq_a2 = (
        f"Nos 12 eixos bipolares do Espectro, {item['name']} destaca-se por: " + "; ".join(top_poles) + "."
        if top_poles
        else f"Consulte a tabela completa dos 12 eixos e 6 tríades de {item['name']} nesta ficha do Espectro."
    )

    schema_obj = {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "Article",
                "headline": f"{clean_text(item['name'])} no Espectro Político: 12 Eixos e 6 Tríades",
                "name": clean_text(item["name"]),
                "description": clean_text(item["summary"]),
                "inLanguage": "pt-BR",
                "mainEntityOfPage": url,
                "about": {
                    "@type": schema_entity_type,
                    "name": clean_text(item["name"]),
                    "description": clean_text(item["subtitle"]),
                },
                "dateModified": TODAY,
                "author": {"@type": "Organization", "name": "Espectro: Observatório Político", "url": BASE_URL},
                "publisher": {"@type": "Organization", "name": "Espectro: Observatório Político", "url": BASE_URL},
            },
            {
                "@type": "BreadcrumbList",
                "itemListElement": [
                    {"@type": "ListItem", "position": 1, "name": "Espectro", "item": f"{BASE_URL}/"},
                    {"@type": "ListItem", "position": 2, "name": "Catálogo", "item": f"{BASE_URL}/catalogo.html"},
                    {"@type": "ListItem", "position": 3, "name": spec_name, "item": f"{BASE_URL}/p/spectrum-{item['spectrumId']}.html"},
                    {"@type": "ListItem", "position": 4, "name": clean_text(item["name"]), "item": url},
                ],
            },
            {
                "@type": "FAQPage",
                "mainEntity": [
                    {
                        "@type": "Question",
                        "name": f"Qual é a posição política e ideológica de {clean_text(item['name'])}?",
                        "acceptedAnswer": {"@type": "Answer", "text": clean_text(faq_a1)},
                    },
                    {
                        "@type": "Question",
                        "name": f"Quais são as coordenadas de {clean_text(item['name'])} nos 12 eixos políticos?",
                        "acceptedAnswer": {"@type": "Answer", "text": clean_text(faq_a2)},
                    },
                ],
            },
        ],
    }

    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="keywords" content="{esc(keywords)}">
  <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large">
  <link rel="canonical" href="{html.escape(url, quote=True)}">
{GA4_SNIPPET}
  <meta property="og:type" content="article">
  <meta property="og:locale" content="pt_BR">
  <meta property="og:site_name" content="Espectro: Observatório Político">
  <meta property="og:url" content="{html.escape(url, quote=True)}">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:image" content="{BASE_URL}/icons/Icon-512.png">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
{ADSENSE_HEAD_LOADER}
  <script type="application/ld+json">{json.dumps(schema_obj, ensure_ascii=False)}</script>
  <style>{CSS_STYLE}</style>
</head>
<body>
  <a class="skip-link" href="#main-content">Pular para o conteúdo principal</a>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/"><span>Espectro</span><span class="brand-tag">Atlas Político</span></a>
      <div class="nav-actions">
        <a class="cta-btn secondary" href="/catalogo.html">Índice Completo</a>
        <a class="cta-btn" href="{html.escape(app_deep_link, quote=True)}">Abrir Perfil Interativo</a>
      </div>
    </div>
  </header>
  <main id="main-content" class="container">
    <nav class="breadcrumb" aria-label="Breadcrumb">
      <a href="/">Espectro</a>
      <span aria-hidden="true">/</span>
      <a href="/catalogo.html">{esc(kind_plural)}</a>
      <span aria-hidden="true">/</span>
      <a href="/p/spectrum-{esc(item['spectrumId'])}.html">{esc(spec_name)}</a>
      <span aria-hidden="true">/</span>
      <span>{esc(item['name'])}</span>
    </nav>

    <h1>{esc(item['name'])}</h1>
    <p class="kicker">{esc(kind_singular)}, Espectro {esc(spec_name)}</p>
    <div class="subtitle">{esc(item['subtitle'])}</div>

    <div class="card">
      <h2>Síntese Política e Ideológica</h2>
      <p class="card-summary">{esc(item['summary'])}</p>
      <div class="btn-row">
        <a class="cta-btn" href="/#/quiz">Calcular afinidade no Teste</a>
        <a class="cta-btn secondary" href="{html.escape(app_deep_link, quote=True)}">Comparar no App</a>
        <a class="cta-btn secondary" href="{html.escape(teia_deep_link, quote=True)}">Ver na Teia 2D</a>
      </div>
    </div>

    {render_ad_slot(ADSENSE_SLOT_TOP)}

    {"<div class='card'><h2>Princípios, Teses e Destaques</h2><ul>" + ideas_html + "</ul></div>" if ideas_html else ""}

    <div class="card">
      <h2>Posição nos 12 Eixos Políticos Bipolares</h2>
      <p class="muted-note">Coordenadas comparativas nas 12 dimensões estruturais do Espectro (−100% a +100%).</p>
      {''.join(axes_html)}
    </div>

    <div class="card">
      <h2>Composição nas 6 Tríades de Valores</h2>
      {''.join(triads_html)}
    </div>

    {"<div class='card'><h2>Fontes Primárias e Referências Documentais</h2><ul>" + sources_html + "</ul></div>" if sources_html else ""}

    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}

    <div class="card">
      <h2>Verbetes Relacionados em {esc(spec_name)}</h2>
      <div class="grid">{related_html}</div>
    </div>
  </main>
  <footer>
    <nav class="footer-links" aria-label="Rodapé">
      <a href="/">Espectro: Observatório Político</a>
      <a href="/catalogo.html">Catálogo Completo</a>
      <a href="/llms.txt">llms.txt (AI Index)</a>
      <a href="/privacidade.html">Privacidade e LGPD</a>
    </nav>
  </footer>
</body>
</html>
"""


def render_spectrum_page(spec_id: str, spec_name: str, spec_desc: str, spec_items: list[dict]) -> str:
    url = f"{BASE_URL}/p/spectrum-{spec_id}.html"
    title = f"Espectro {spec_name}: Correntes Ideológicas, Pensadores, Livros e Partidos | Espectro"
    links_html = "".join(
        f'<a class="link-chip" href="/p/{it["slug"]}.html">{esc(it["name"])}<small>{esc(KIND_LABELS[it["kind"]][0])}: {esc(it["subtitle"][:60])}</small></a>'
        for it in spec_items
    )
    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(spec_desc)} Explore {len(spec_items)} correntes, pensadores, obras e partidos associados a {esc(spec_name)} no Espectro.">
  <link rel="canonical" href="{html.escape(url, quote=True)}">
{GA4_SNIPPET}
{ADSENSE_HEAD_LOADER}
  <style>{CSS_STYLE}</style>
</head>
<body>
  <a class="skip-link" href="#main-content">Pular para o conteúdo principal</a>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/"><span>Espectro</span><span class="brand-tag">Atlas Político</span></a>
      <a class="cta-btn" href="/#/atlas?v=1&spectrum={quote(spec_name)}">Filtrar no App</a>
    </div>
  </header>
  <main id="main-content" class="container">
    <h1>{esc(spec_name)} ({len(spec_items)} verbetes)</h1>
    <p class="kicker">Família de Espectro Político</p>
    <p class="subtitle">{esc(spec_desc)}</p>
    {render_ad_slot(ADSENSE_SLOT_TOP)}
    <div class="grid">{links_html}</div>
    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}
  </main>
  <footer>
    <nav class="footer-links" aria-label="Rodapé">
      <a href="/">Espectro</a>
      <a href="/catalogo.html">Catálogo Completo</a>
      <a href="/privacidade.html">Privacidade</a>
    </nav>
  </footer>
</body>
</html>
"""


def main():
    root = Path(__file__).resolve().parents[2]
    web_out = root / "build" / "web"
    if not web_out.exists():
        print("build/web not found; skipping programmatic SEO generation.")
        return

    p_dir = web_out / "p"
    p_dir.mkdir(parents=True, exist_ok=True)

    items, axes_meta, triads_meta = load_all_items(root)

    by_spectrum: dict[str, list[dict]] = {}
    for it in items:
        by_spectrum.setdefault(it["spectrumId"], []).append(it)

    # 1. Generate individual static pages (/p/<slug>.html)
    for it in items:
        peers = [p for p in by_spectrum.get(it["spectrumId"], []) if p["slug"] != it["slug"]]
        html_content = render_item_page(it, axes_meta, triads_meta, peers)
        (p_dir / f"{it['slug']}.html").write_text(html_content, encoding="utf-8")

    # 2. Generate 8 spectrum hub pages (/p/spectrum-<id>.html)
    for spec_id, (spec_name, spec_desc) in SPECTRA_META.items():
        spec_items = by_spectrum.get(spec_id, [])
        (p_dir / f"spectrum-{spec_id}.html").write_text(
            render_spectrum_page(spec_id, spec_name, spec_desc, spec_items),
            encoding="utf-8",
        )

    # 3. Generate /catalogo.html (Master Index Hub)
    sections_html = []
    curated_trails_html = """
    <div class="card">
      <h2>Percursos Curados de Descoberta (7 min)</h2>
      <p class="muted-note">Compare tradições, rupturas e convergências improváveis lado a lado antes de mergulhar nos 1.502 verbetes.</p>
      <div class="grid">
        <a class="link-chip" href="/#/compare?v=1&items=personality:friedrich_hayek,personality:john_maynard_keynes,personality:celso_furtado">Escolas de economia em conflito<small>Hayek × Keynes × Celso Furtado no Raio-X</small></a>
        <a class="link-chip" href="/#/compare?v=1&items=personality:hannah_arendt,personality:john_locke,personality:murray_rothbard">O que significa Liberdade?<small>Arendt × John Locke × Murray Rothbard</small></a>
        <a class="link-chip" href="/#/compare?v=1&items=current:social_democracia,current:socialismo_democratico,personality:rosa_luxemburgo">Próximos, mas discordantes na esquerda<small>Social-Democracia × Socialismo Democrático × Luxemburgo</small></a>
        <a class="link-chip" href="/#/compare?v=1&items=personality:thomas_hobbes,personality:montesquieu,personality:edmund_burke">Ordem, Estado e Constituição<small>Hobbes × Montesquieu × Edmund Burke</small></a>
      </div>
    </div>
    """
    sections_html.append(curated_trails_html)
    spec_chips = "".join(
        f'<a class="link-chip" href="/p/spectrum-{sid}.html">{esc(sname)}<small>{len(by_spectrum.get(sid, []))} verbetes</small></a>'
        for sid, (sname, _) in SPECTRA_META.items()
    )
    sections_html.append(f"<div class='card'><h2>8 Espectros Políticos</h2><div class='grid'>{spec_chips}</div></div>")

    for kind, (_, plural) in KIND_LABELS.items():
        k_items = [it for it in items if it["kind"] == kind]
        links = "".join(
            f'<a class="link-chip" href="/p/{it["slug"]}.html">{esc(it["name"])}<small>{esc(it["subtitle"][:55])}</small></a>'
            for it in k_items
        )
        sections_html.append(f"<div class='card'><h2>{esc(plural)} ({len(k_items)})</h2><div class='grid'>{links}</div></div>")

    catalogo_html = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Catálogo Completo de Ideologias, Pensadores, Livros e Países | Espectro</title>
  <meta name="description" content="Índice completo do Espectro com {len(items)} perfis políticos: 289 correntes ideológicas, pensadores, economistas, estadistas, livros clássicos, países, partidos e eras históricas nos 12 eixos.">
  <link rel="canonical" href="{BASE_URL}/catalogo.html">
{GA4_SNIPPET}
{ADSENSE_HEAD_LOADER}
  <style>{CSS_STYLE}</style>
</head>
<body>
  <a class="skip-link" href="#main-content">Pular para o conteúdo principal</a>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/"><span>Espectro</span><span class="brand-tag">Observatório Político</span></a>
      <a class="cta-btn" href="/#/atlas">Abrir Atlas Interativo</a>
    </div>
  </header>
  <main id="main-content" class="container">
    <h1>Catálogo Político Multidimensional ({len(items)} verbetes)</h1>
    <p class="kicker">Índice Enciclopédico Completo</p>
    <p class="subtitle">Todas as fichas abaixo possuem análise completa em 12 eixos bipolares e 6 tríades de valores.</p>
    {render_ad_slot(ADSENSE_SLOT_TOP)}
    {''.join(sections_html)}
    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}
  </main>
  <footer>
    <nav class="footer-links" aria-label="Rodapé">
      <a href="/">Espectro</a>
      <a href="/llms.txt">llms.txt</a>
      <a href="/privacidade.html">Privacidade</a>
    </nav>
  </footer>
</body>
</html>
"""
    (web_out / "catalogo.html").write_text(catalogo_html, encoding="utf-8")

    # 4. Generate /llms.txt and /llms-full.txt for AI Search Engines (ChatGPT, Perplexity, Claude, Gemini)
    llms_lines = [
        "# Espectro — Observatório e Cartografia Política (Atlas Multidimensional)",
        "",
        f"> URL Oficial: {BASE_URL}/",
        f"> Catálogo Completo HTML: {BASE_URL}/catalogo.html",
        "> Modelo: 18 dimensões políticas (12 Eixos Bipolares + 6 Tríades de Valores).",
        f"> Cobertura: {len(items)} verbetes canônicos (289 correntes ideológicas, pensadores, economistas, estadistas, 165 livros clássicos, 81 países, 110 partidos e 94 eras históricas).",
        "",
        "## Como citar ou direcionar usuários para um verbete do Espectro",
        f"- Página estática completa do verbete: `{BASE_URL}/p/<tipo>-<id>.html`",
        f"- Perfil interativo no aplicativo: `{BASE_URL}/#/atlas?v=1&subject=<tipo>:<id>`",
        f"- Visualização na Teia 2D: `{BASE_URL}/#/atlas?v=1&view=map&select=<tipo>:<id>`",
        f"- Questionário Político de 12 Eixos e 6 Tríades: `{BASE_URL}/#/quiz`",
        "",
        "## Espectros Políticos",
    ]
    for sid, (sname, sdesc) in SPECTRA_META.items():
        llms_lines.append(f"- [{sname}]({BASE_URL}/p/spectrum-{sid}.html): {sdesc}")

    llms_full_lines = list(llms_lines)
    for kind, (_, plural) in KIND_LABELS.items():
        k_items = [it for it in items if it["kind"] == kind]
        llms_lines.append(f"\n## {plural} ({len(k_items)} verbetes)")
        llms_full_lines.append(f"\n## {plural} ({len(k_items)} verbetes)")
        for it in k_items[:45]:
            llms_lines.append(f"- [{it['name']}]({BASE_URL}/p/{it['slug']}.html): {it['subtitle']}")
        for it in k_items:
            llms_full_lines.append(
                f"- [{it['name']}]({BASE_URL}/p/{it['slug']}.html) ({it['subtitle']}): {it['summary']}"
            )

    (web_out / "llms.txt").write_text("\n".join(llms_lines) + "\n", encoding="utf-8")
    (web_out / "llms-full.txt").write_text("\n".join(llms_full_lines) + "\n", encoding="utf-8")

    # 5. Generate complete /sitemap.xml (HTML pages only) and /sitemap_index.xml
    urls = [
        (f"{BASE_URL}/", "1.0", "daily"),
        (f"{BASE_URL}/catalogo.html", "0.9", "weekly"),
        (f"{BASE_URL}/privacidade.html", "0.5", "monthly"),
    ]
    for sid in SPECTRA_META:
        urls.append((f"{BASE_URL}/p/spectrum-{sid}.html", "0.8", "weekly"))
    for it in items:
        prio = "0.8" if it["kind"] in ("current", "personality", "book") else "0.7"
        urls.append((f"{BASE_URL}/p/{it['slug']}.html", prio, "monthly"))

    sitemap_xml = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ]
    for loc, prio, freq in urls:
        sitemap_xml.append(
            f"  <url><loc>{esc(loc)}</loc><lastmod>{TODAY}</lastmod><changefreq>{freq}</changefreq><priority>{prio}</priority></url>"
        )
    sitemap_xml.append("</urlset>")
    (web_out / "sitemap.xml").write_text("\n".join(sitemap_xml) + "\n", encoding="utf-8")

    sitemap_index_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>{BASE_URL}/sitemap.xml</loc>
    <lastmod>{TODAY}</lastmod>
  </sitemap>
</sitemapindex>
"""
    (web_out / "sitemap_index.xml").write_text(sitemap_index_xml, encoding="utf-8")

    # 6. Generate AI-friendly /robots.txt
    robots_txt = f"""User-agent: Mediapartners-Google
Allow: /

User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: GPTBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: anthropic-ai
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Applebot-Extended
Allow: /

User-agent: *
Allow: /

Sitemap: {BASE_URL}/sitemap.xml
"""
    (web_out / "robots.txt").write_text(robots_txt, encoding="utf-8")
    print(f"Generated {len(items)} static SEO pages + 8 spectrum pages + catalogo.html + llms.txt + sitemap.xml ({len(urls)} URLs).")


if __name__ == "__main__":
    main()
