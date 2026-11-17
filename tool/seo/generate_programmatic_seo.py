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


def esc(text: str | None) -> str:
    return html.escape(str(text or ""), quote=True)


def excerpt(text: str | None, max_len: int = 145) -> str:
    clean = " ".join(str(text or "").split())
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
                    "subtitle": f"{e.get('subtitle', '')} · {e.get('era', '')} ({e.get('origin', '')})".strip(" ·()"),
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
                    "subtitle": f"{e.get('subtitle', '')} · {e.get('era', '')}".strip(" ·"),
                    "summary": e.get("summary") or "",
                    "spectrumId": e.get("spectrumId") or "center",
                    "ideas": e.get("highlights") or [],
                    "axes": {k: float(v) for k, v in (e.get("axes") or {}).items()},
                    "triads": {int(k): v for k, v in (e.get("triangles") or {}).items()},
                    "sources": list((basis.get("sourceTitles") or {}).items()),
                })

    return items, axes_meta, triads_meta


CSS_STYLE = """
:root {
  --bg: #0C1018;
  --surface: #131A26;
  --surface-muted: #1A2333;
  --line: #243044;
  --ink: #F3F5F8;
  --muted: #9BA6B8;
  --accent: #E0A82E;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "IBM Plex Sans", "Segoe UI", Roboto, sans-serif;
  background: var(--bg);
  color: var(--ink);
  line-height: 1.65;
}
header.topbar {
  border-bottom: 1px solid var(--line);
  background: rgba(19, 26, 38, 0.94);
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
  letter-spacing: 0.06em;
  display: flex;
  align-items: center;
  gap: 0.6rem;
}
.cta-btn {
  display: inline-block;
  background: var(--accent);
  color: #0B0F17;
  font-weight: 700;
  text-decoration: none;
  padding: 0.55rem 1.1rem;
  border-radius: 10px;
  font-size: 0.92rem;
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
.eyebrow {
  color: var(--accent);
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}
h1 {
  font-size: clamp(1.75rem, 3.5vw, 2.5rem);
  margin: 0.35rem 0 0.5rem;
  line-height: 1.2;
}
.subtitle {
  color: var(--muted);
  font-size: 1.05rem;
  margin-bottom: 1.25rem;
}
.card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 1.4rem;
  margin-bottom: 1.25rem;
}
.axis-row {
  padding: 0.65rem 0;
  border-bottom: 1px solid rgba(36, 48, 68, 0.6);
}
.axis-row:last-child { border-bottom: none; }
.axis-poles {
  display: flex;
  justify-content: space-between;
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
  font-size: 0.8rem;
}
.ad-box {
  background: rgba(19, 26, 38, 0.7);
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 0.5rem;
  margin: 1.25rem 0;
  text-align: center;
  min-height: 68px;
}
.ad-label {
  font-size: 0.68rem;
  color: var(--muted);
  letter-spacing: 0.08em;
  text-transform: uppercase;
  margin-bottom: 0.2rem;
}
footer {
  border-top: 1px solid var(--line);
  padding: 2rem 1.25rem;
  text-align: center;
  color: var(--muted);
  font-size: 0.88rem;
}
footer a { color: var(--accent); text-decoration: none; }
"""


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
      <script>(adsbygoogle = window.adsbygoogle || []).push({{}});</script>
    </aside>
    """


def render_item_page(item: dict, axes_meta: dict, triads_meta: dict, related: list[dict]) -> str:
    kind_singular, kind_plural = KIND_LABELS[item["kind"]]
    spec_name, _ = SPECTRA_META.get(item["spectrumId"], ("Centro & Reformismo", ""))
    url = f"{BASE_URL}/p/{item['slug']}.html"
    app_deep_link = f"/#/atlas?v=1&subject={quote(item['key'])}"
    teia_deep_link = f"/#/atlas?v=1&view=map&select={quote(item['key'])}"

    title = f"{item['name']} no Espectro Político — 12 Eixos, {kind_singular} & Análise | Espectro"
    desc = f"{item['name']} ({item['subtitle']}) no Espectro: {excerpt(item['summary'], 145)} Veja as posições exatas nos 12 eixos políticos, 6 tríades de valores e fontes primárias."
    keywords = f"{item['name']}, {item['name']} espectro, {item['name']} espectro político, {item['name']} posicionamento político, {kind_singular}, {spec_name}, 12 eixos, Espectro observatório político"

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
          <div style="display:flex;justify-content:space-between;font-weight:600;font-size:0.95rem">
            <span>{esc(meta['label'])}</span>
            <span style="color:var(--accent)">{esc(dominant)}</span>
          </div>
          <div class="axis-bar"><div class="axis-fill" style="width:{pct_right}%"></div></div>
          <div class="axis-poles">
            <span>← {esc(meta['leftPole'])} ({pct_left}%)</span>
            <span>{esc(meta['rightPole'])} ({pct_right}%) →</span>
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
        parts = [f"{esc(subs[i])}: <strong>{int(round(comp[i] * 100))}%</strong>" for i in range(3)]
        triads_html.append(f"""
        <div class="axis-row">
          <div style="font-weight:600;margin-bottom:0.25rem">{esc(tmeta['label'])}</div>
          <div style="color:var(--muted);font-size:0.9rem">{' · '.join(parts)}</div>
        </div>
        """)

    ideas_html = "".join(f"<li>{esc(idea)}</li>" for idea in item["ideas"])
    sources_html = "".join(
        f'<li><a href="{esc(u)}" rel="noopener noreferrer" target="_blank" style="color:var(--accent)">{esc(t)}</a></li>'
        for u, t in item["sources"][:8]
    )
    related_html = "".join(
        f'<a class="link-chip" href="/p/{r["slug"]}.html">{esc(r["name"])}<small>{esc(KIND_LABELS[r["kind"]][0])} · {esc(SPECTRA_META.get(r["spectrumId"], ("",))[0])}</small></a>'
        for r in related[:12]
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
                "headline": f"{item['name']} no Espectro Político — 12 Eixos e 6 Tríades",
                "name": item["name"],
                "description": item["summary"],
                "inLanguage": "pt-BR",
                "mainEntityOfPage": url,
                "about": {
                    "@type": schema_entity_type,
                    "name": item["name"],
                    "description": item["subtitle"],
                },
                "dateModified": TODAY,
                "author": {"@type": "Organization", "name": "Espectro — Observatório Político", "url": BASE_URL},
                "publisher": {"@type": "Organization", "name": "Espectro — Observatório Político", "url": BASE_URL},
            },
            {
                "@type": "BreadcrumbList",
                "itemListElement": [
                    {"@type": "ListItem", "position": 1, "name": "Espectro", "item": f"{BASE_URL}/"},
                    {"@type": "ListItem", "position": 2, "name": "Catálogo", "item": f"{BASE_URL}/catalogo.html"},
                    {"@type": "ListItem", "position": 3, "name": spec_name, "item": f"{BASE_URL}/p/spectrum-{item['spectrumId']}.html"},
                    {"@type": "ListItem", "position": 4, "name": item["name"], "item": url},
                ],
            },
            {
                "@type": "FAQPage",
                "mainEntity": [
                    {
                        "@type": "Question",
                        "name": f"Qual é a posição política e ideológica de {item['name']}?",
                        "acceptedAnswer": {"@type": "Answer", "text": faq_a1},
                    },
                    {
                        "@type": "Question",
                        "name": f"Quais são as coordenadas de {item['name']} nos 12 eixos políticos?",
                        "acceptedAnswer": {"@type": "Answer", "text": faq_a2},
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
  <link rel="canonical" href="{esc(url)}">
{GA4_SNIPPET}
  <meta property="og:type" content="article">
  <meta property="og:locale" content="pt_BR">
  <meta property="og:site_name" content="Espectro — Observatório Político">
  <meta property="og:url" content="{esc(url)}">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:image" content="{BASE_URL}/icons/Icon-512.png">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
  <meta name="google-adsense-account" content="{ADSENSE_CLIENT}">
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client={ADSENSE_CLIENT}"
     crossorigin="anonymous"></script>
  <script type="application/ld+json">{json.dumps(schema_obj, ensure_ascii=False)}</script>
  <style>{CSS_STYLE}</style>
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/">ESPECTRO · ATLAS POLÍTICO</a>
      <div style="display:flex;gap:0.6rem;flex-wrap:wrap">
        <a class="cta-btn secondary" href="/catalogo.html">Índice Completo</a>
        <a class="cta-btn" href="{esc(app_deep_link)}">Abrir Perfil Interativo →</a>
      </div>
    </div>
  </header>
  <main class="container">
    <nav aria-label="Breadcrumb" style="font-size:0.85rem;color:var(--muted);margin-bottom:1rem">
      <a href="/" style="color:var(--accent)">Espectro</a> ›
      <a href="/catalogo.html" style="color:var(--accent)">{esc(kind_plural)}</a> ›
      <a href="/p/spectrum-{esc(item['spectrumId'])}.html" style="color:var(--accent)">{esc(spec_name)}</a> ›
      <span>{esc(item['name'])}</span>
    </nav>

    <div class="eyebrow">{esc(kind_singular)} · Espectro {esc(spec_name)}</div>
    <h1>{esc(item['name'])}</h1>
    <div class="subtitle">{esc(item['subtitle'])}</div>

    <div class="card">
      <h2 style="margin-top:0;font-size:1.2rem">Síntese Política e Ideológica</h2>
      <p style="margin-bottom:1.2rem">{esc(item['summary'])}</p>
      <div style="display:flex;gap:0.75rem;flex-wrap:wrap">
        <a class="cta-btn" href="/#/quiz">Descubra sua afinidade com {esc(item['name'])} no Teste do Espectro →</a>
        <a class="cta-btn secondary" href="{esc(app_deep_link)}">Comparar {esc(item['name'])} no App Interativo</a>
        <a class="cta-btn secondary" href="{esc(teia_deep_link)}">Ver na Teia de Ideias 2D</a>
      </div>
    </div>

    {render_ad_slot(ADSENSE_SLOT_TOP)}

    {"<div class='card'><h2 style='margin-top:0;font-size:1.2rem'>Princípios, Teses e Destaques</h2><ul>" + ideas_html + "</ul></div>" if ideas_html else ""}

    <div class="card">
      <h2 style="margin-top:0;font-size:1.2rem">Posição nos 12 Eixos Políticos Bipolares</h2>
      <p style="color:var(--muted);font-size:0.9rem;margin-top:0">Coordenadas comparativas nas 12 dimensões estruturais do Espectro (−100% a +100%).</p>
      {''.join(axes_html)}
    </div>

    <div class="card">
      <h2 style="margin-top:0;font-size:1.2rem">Composição nas 6 Tríades de Valores</h2>
      {''.join(triads_html)}
    </div>

    {"<div class='card'><h2 style='margin-top:0;font-size:1.2rem'>Fontes Primárias e Referências Documentais</h2><ul>" + sources_html + "</ul></div>" if sources_html else ""}

    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}

    <div class="card">
      <h2 style="margin-top:0;font-size:1.2rem">Verbetes Relacionados no Espectro {esc(spec_name)}</h2>
      <div class="grid">{related_html}</div>
    </div>
  </main>
  <footer>
    <p><a href="/">Espectro — Observatório Político</a> · <a href="/catalogo.html">Catálogo Completo</a> · <a href="/llms.txt">llms.txt (AI Index)</a> · <a href="/privacidade.html">Privacidade &amp; LGPD</a></p>
  </footer>
</body>
</html>
"""


def render_spectrum_page(spec_id: str, spec_name: str, spec_desc: str, spec_items: list[dict]) -> str:
    url = f"{BASE_URL}/p/spectrum-{spec_id}.html"
    title = f"Espectro {spec_name} — Correntes Ideológicas, Pensadores, Livros e Partidos | Espectro"
    links_html = "".join(
        f'<a class="link-chip" href="/p/{it["slug"]}.html">{esc(it["name"])}<small>{esc(KIND_LABELS[it["kind"]][0])} · {esc(it["subtitle"][:60])}</small></a>'
        for it in spec_items
    )
    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(spec_desc)} Explore {len(spec_items)} correntes, pensadores, obras e partidos associados a {esc(spec_name)} no Espectro.">
  <link rel="canonical" href="{esc(url)}">
{GA4_SNIPPET}
  <meta name="google-adsense-account" content="{ADSENSE_CLIENT}">
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client={ADSENSE_CLIENT}"
     crossorigin="anonymous"></script>
  <style>{CSS_STYLE}</style>
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/">ESPECTRO · ATLAS POLÍTICO</a>
      <a class="cta-btn" href="/#/atlas?v=1&spectrum={quote(spec_name)}">Filtrar {esc(spec_name)} no App →</a>
    </div>
  </header>
  <main class="container">
    <div class="eyebrow">Família de Espectro Político</div>
    <h1>{esc(spec_name)} ({len(spec_items)} verbetes)</h1>
    <p class="subtitle">{esc(spec_desc)}</p>
    {render_ad_slot(ADSENSE_SLOT_TOP)}
    <div class="grid">{links_html}</div>
    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}
  </main>
  <footer>
    <p><a href="/">Espectro</a> · <a href="/catalogo.html">Catálogo Completo</a> · <a href="/privacidade.html">Privacidade</a></p>
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
  <title>Catálogo Completo de Ideologias, Pensadores, Livros e Países — Espectro</title>
  <meta name="description" content="Índice completo do Espectro com {len(items)} perfis políticos: 289 correntes ideológicas, pensadores, economistas, estadistas, livros clássicos, países, partidos e eras históricas nos 12 eixos.">
  <link rel="canonical" href="{BASE_URL}/catalogo.html">
{GA4_SNIPPET}
  <meta name="google-adsense-account" content="{ADSENSE_CLIENT}">
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client={ADSENSE_CLIENT}"
     crossorigin="anonymous"></script>
  <style>{CSS_STYLE}</style>
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/">ESPECTRO · OBSERVATÓRIO POLÍTICO</a>
      <a class="cta-btn" href="/#/atlas">Abrir Atlas Interativo →</a>
    </div>
  </header>
  <main class="container">
    <div class="eyebrow">Índice Enciclopédico Completo</div>
    <h1>Catálogo Político Multidimensional ({len(items)} verbetes)</h1>
    <p class="subtitle">Todas as fichas abaixo possuem análise completa em 12 eixos bipolares e 6 tríades de valores.</p>
    {render_ad_slot(ADSENSE_SLOT_TOP)}
    {''.join(sections_html)}
    {render_ad_slot(ADSENSE_SLOT_BOTTOM)}
  </main>
  <footer>
    <p><a href="/">Espectro</a> · <a href="/llms.txt">llms.txt</a> · <a href="/privacidade.html">Privacidade</a></p>
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
