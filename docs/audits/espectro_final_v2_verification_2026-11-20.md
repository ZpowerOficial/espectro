# ESPECTRO — Verificação Final pós-Decisão (`final_v2`)

**Branch:** `visual/art-direction-v2` (não mesclada em `main`, sem deploy)  
**Data da verificação:** 2026-11-21  
**Metodologia e motor preservados:** `git diff assets/ lib/domain/engine/ pubspec.yaml | wc -c` = `0` bytes.

---

## 1. Resumo das Decisões Aplicadas

### Item 1 — Paleta B aprovada: Íris Cartográfico Refinado + Latão
A identidade institucional da interface foi unificada sobre a Paleta B em [`lib/theme.dart`](file:///home/zpower/Downloads/espectro/lib/theme.dart), [`lib/widgets/common.dart`](file:///home/zpower/Downloads/espectro/lib/widgets/common.dart), [`lib/ui/charts/axis_colors.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/axis_colors.dart), [`lib/ui/features/home/espectro_home_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart), [`web/index.html`](file:///home/zpower/Downloads/espectro/web/index.html), [`web/privacidade.html`](file:///home/zpower/Downloads/espectro/web/privacidade.html) e [`tool/seo/generate_programmatic_seo.py`](file:///home/zpower/Downloads/espectro/tool/seo/generate_programmatic_seo.py):
- **Tema claro (`EspectroPalette.light`):** `canvas` `#F2F0EB`, `surface` `#FAF9F6`, `surfaceMuted` `#E6E3DC`, `ink` `#151822`, `inkSoft` `#3A4052`, `muted` `#545A6E` (5,35:1 sobre `surfaceMuted`), `line` `#D4D1C9`, `accent` `#44378F` (9,11:1 sobre `surface` e com texto branco `#FAF9F6`), `accentSoft` `#EAE7F6` (tinta `#44378F` com 7,89:1).
- **Tema escuro (`EspectroPalette.dark`):** `canvas` `#0B0F16`, `surface` `#121822`, `surfaceMuted` `#192130`, `ink` `#F2F4F8`, `inkSoft` `#BCC5D6`, `muted` `#8C97AE` (5,50:1 sobre `surfaceMuted`), `line` `#232D3F`, `accent` `#9A92F0` (6,57:1 sobre `surface`, 5,98:1 sobre `accentSoft` `#1F1D3A`), CTAs primários preenchidos em Latão `#E5A448` com tinta `#140D03` (8,94:1).
- **Ausência de halos/glows:** sem gradientes decorativos genéricos nem halos artificiais nos cartões e CTAs.
- **Cores de dados preservadas:** 12 eixos canônicos (`AxisColors`), espectros políticos (`studySpectra`) e `triadPalette` não foram alterados.

### Item 2 — Dual-Pole como padrão global e Primary-Anchor condicional nos Resultados
- **Home, Atlas e Comparador:** mantêm `AxisColorStrategy.dualPole`, preservando a leitura bipolar simétrica sem privilégio cromático artificial para nenhum dos polos (`home-1440-dark-12axes.png`, `compare-1440-light-12axes.png`).
- **Resultados pessoais ([`espectro_result_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart), [`diverging_axis_bar.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/diverging_axis_bar.dart), [`multidimensional_radar_chart.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/multidimensional_radar_chart.dart)):**
  - `AxisColorStrategy.primaryAnchor` envolve as seções dos 12 eixos pessoais (`_buildSection12Axes` e `_buildAxesTab`), com filtro no trilho de leitura (`_buildAxesRadarReadingRail`) exigindo `a.score.abs() >= 0.15`.
  - Somente eixos com inclinação efetivamente observada (`!isIndeterminate && score.abs() >= 0.15`) destacam o polo dominante na cor da âncora (ex.: `Estrutura · 75% Federal`, `Representação · 89% Democracia`, `Poder · 75% Segurança`).
  - Eixos equilibrados (`|score| < 0.15`, ex.: `Imigração · Equilibrado` visível em `result-axes-bars-1440-dark.png`) ou com dados insuficientes permanecem simetricamente neutros (`p.muted`), sem realce unilateral nem pílula ativa.

### Item 5 — Reformulação da publicidade mobile e Web (`lib/ui/ads/` e `EspectroScaffold`)
- **Remoção do banner fixo inferior e do fallback autopromocional:** removida `EspectroFloatingAdBar` de [`espectro_scaffold.dart`](file:///home/zpower/Downloads/espectro/lib/widgets/espectro_scaffold.dart) e de [`espectro_quiz_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_quiz_screen.dart), eliminando o retângulo cinza vazio colado à `NavigationBar` e qualquer rótulo enganoso `"AD · Espectro · Observatório..."`. Zero anúncios no questionário (`quizAdsCheck` vazio mesmo com mock `filled`).
- **Modelo de 5 estados em [`espectro_ad_state.dart`](file:///home/zpower/Downloads/espectro/lib/ui/ads/espectro_ad_state.dart), [`espectro_web_ad_slot_web.dart`](file:///home/zpower/Downloads/espectro/lib/ui/ads/espectro_web_ad_slot_web.dart) e [`espectro_banner_ad.dart`](file:///home/zpower/Downloads/espectro/lib/ui/ads/espectro_banner_ad.dart):**
  - Estados suportados: `loading`, `filled`, `unfillOptimized`, `unfilled`, `unavailable` (`parseWebAdStatus`).
  - Durante `loading`, a sonda DOM mantém `HtmlElementView` montado em `1 px` com `Opacity(opacity: 0.01)` para que o `RenderOpacity` do Flutter Web componha a `PlatformViewSurface` sem ocultar `offsetWidth` (`width: 350 px` no mobile `390×844`) antes do `_AdsByGoogleQueue.push({})`.
  - `unfilled` e `unavailable` (incluindo fallback offline após timeout de 5000 ms) colapsam integralmente para `const SizedBox.shrink()` (`0 px` no container Flutter) e ocultam o wrapper DOM.
  - `unfill-optimized` nunca recebe `display: none` forçado (`display: block` preservado no `<ins>` e wrapper): quando há altura observada `>= 20 px`, exibe a moldura e o rótulo discreto `"Publicidade"`; quando a altura é `0 px`, omite `"Publicidade"` mantendo o wrapper em `display: block` para conformidade com o AdSense.
  - Posicionamentos inline entre seções naturais: `home_mid_feed` (Home entre Beat 5 Bento Grid e Beat 6 `Caderno de campo`), `atlas_browse_inline` (Atlas), `profile_content_inline` (Ficha) e `methodology_inline` (Metodologia).
  - Páginas estáticas SEO ([`generate_programmatic_seo.py`](file:///home/zpower/Downloads/espectro/tool/seo/generate_programmatic_seo.py)) e [`web/index.html`](file:///home/zpower/Downloads/espectro/web/index.html) atualizadas com colapso `.ad-box:has(ins[data-ad-status="unfilled"]) { display: none !important; }` e regra separada `.ad-box:has(ins[data-ad-status="unfill-optimized"])` sem `display: none` (verificado em [`build/web/p/personality-karl_marx.html`](file:///home/zpower/Downloads/espectro/build/web/p/personality-karl_marx.html)).

### Correções metodológicas e visuais preservadas
- **Radar multidimensional (`Eixos (12)`):** composição ampliada (`maxWidth: 920`) lado a lado com trilho de leitura `LEITURA DO RADAR` e faixa sombreada de dispersão `±1 SE`.
- **Teia de 289 correntes:** preservação dos 27 âncoras de nível 1 e alocador em 4 camadas com margem segura em relação ao HUD.
- **Honestidade do resultado Expressa:** exibe exclusivamente `12 Eixos Bipolares (Expressa)` e `12/12 eixos bipolares observados`, sem mencionar `6 tríades` não medidas.
- **Exportações PNG reais 1:1 e 9:16:** download real em navegador emitindo `espectro-post.png` (`1080×1080`) e `espectro-story.png` (`1080×1920`) com assinatura de produção `https://espectro-politico.web.app/#/`.

---

## 2. Configuração Oficial de Anchor Ads (Google AdSense) — Referência Separada

Nenhuma barra âncora customizada foi implementada no código Flutter. Caso se opte por avaliar **Anchor Ads oficiais do Google AdSense** em produção:
1. No painel do Google AdSense, acessar **Anúncios → Visão geral → Por site → Editar** no domínio `espectro-politico.web.app`.
2. Em **Configurações de anúncios → Formatos de sobreposição**, habilitar **Anúncios âncora** gerenciados pelo Auto Ads do `adsbygoogle.js` (`ca-pub-1519935796466095`), sem criar container `Scaffold`/CSS próprio sobreposto.
3. **Atenção crítica no mobile Flutter Web (`NavigationBar` inferior):** manter âncoras inferiores desabilitadas (`data-overlays="bottom"` não ativado / restringir à borda superior quando disponível no console do AdSense) para impedir sobreposição sobre os destinos `Início · Testes · Atlas · Histórico`.
4. **Exclusão de fluxo interativo:** configurar exclusão de página no AdSense para a rota do questionário (`/#/quiz`) caso os anúncios automáticos interfiram na área útil de resposta.

---

## 3. Verificações Executadas após a Edição Final

| Verificação | Comando / Origem | Resultado observado |
|---|---|---|
| Análise estática | `dart analyze lib/ test/` (`task-24574`) | `No issues found!` |
| Suíte completa de testes | `flutter test --reporter=compact` (`task-24574`) | `+298 ~1: All other tests passed!` (0 falhas; 1 skip pré-existente) |
| Integridade metodológica | `git diff assets/ lib/domain/engine/ pubspec.yaml \| wc -c` | `0` bytes |
| Build Web | `flutter build web --no-wasm-dry-run` | `✓ Built build/web` |
| Portal SEO estático | `python3 tool/seo/generate_programmatic_seo.py` | `Generated 1502 static SEO pages + 8 spectrum pages + catalogo.html + llms.txt + sitemap.xml (1513 URLs).` |
| WebGL2 + Console | Chromium WebGL2 (`task-24574`, [`telemetry_final_v2.json`](file:///home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2/scratch/telemetry_final_v2.json)) | `webgl2Verified: true`, `appConsoleErrors: []`, `appPageErrors: []`, `offlineExpectedAborts: 1` |
| Questionário sem anúncios | `quizAdsCheck` (`#/quiz` mobile 390×844 com mock `filled`) | `platformViews: []`, `adsbygoogle: []`, `adSemantics: []` |
| AdSense `unfilled` (topo e costura) | `unfilled-dark`, `unfilled-scrolled-dark`, `unfilled-light` | `platformViews: []`, `adsbygoogle: []`, `adSemantics: []` |
| AdSense `filled` inline | `filled-dark`, `filled-light` (`slot: 8975287447`) | `status: "filled"`, `display: "block"`, `offsetHeight: 100`, `rect: 350×100`, label `"Publicidade"` |
| AdSense `unfill-optimized` | `unfill-optimized-open-dark` / `unfill-optimized-zero-dark` | `display: "block"`, `wrapperDisplay: "block"` em ambos; aberto com `offsetHeight: 120` + `"Publicidade"`; zerado com `offsetHeight: 0` + `adSemantics: []` |
| AdSense `offline` | `offline-dark` | `platformViews: []`, `adsbygoogle: []`, `adSemantics: []` após timeout, sem erros de aplicação |
| Exportações PNG produção | `completeExpressaAndCaptureResults` (`https://espectro-politico.web.app`) | `espectro-post.png` (`1080×1080`, `180094` bytes, `validPng: true`); `espectro-story.png` (`1080×1920`, `261690` bytes, `validPng: true`) |

---

## 4. Capturas Finais Inspecionadas (`final_v2`)

### Desktop (`1440×900`) — Paleta B, Dual-Pole vs Primary-Anchor, Radar e Teia
- [home-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/home-1440-light.png)
- [home-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/home-1440-dark.png)
- [home-1440-dark-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/home-1440-dark-12axes.png)
- [compare-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/compare-1440-light.png)
- [compare-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/compare-1440-dark.png)
- [compare-1440-light-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/compare-1440-light-12axes.png)
- [result-overview-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/result-overview-1440-light.png)
- [result-overview-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/result-overview-1440-dark.png)
- [result-axes-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/result-axes-1440-light.png)
- [result-axes-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/result-axes-1440-dark.png)
- [result-axes-bars-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/result-axes-bars-1440-dark.png)
- [teia-1440-dark-zoomed.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/teia-1440-dark-zoomed.png)

### Mobile (`390×844`) — Primeira Dobra, Questionário e Matriz AdSense 4 Estados
- [home-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/home-390-dark.png)
- [home-390-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/home-390-light.png)
- [quiz-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/quiz-390-dark.png)
- [ads-mobile-390-dark-unfilled.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-dark-unfilled.png)
- [ads-mobile-390-light-unfilled.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-light-unfilled.png)
- [ads-mobile-390-dark-unfilled-seam.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-dark-unfilled-seam.png)
- [ads-mobile-390-dark-filled-inline.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-dark-filled-inline.png)
- [ads-mobile-390-light-filled-inline.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-light-filled-inline.png)
- [ads-mobile-390-dark-unfill-optimized.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-dark-unfill-optimized.png)
- [ads-mobile-390-dark-offline.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/ads-mobile-390-dark-offline.png)

### Cartões Exportados (`https://espectro-politico.web.app/#/`)
- [final-export-prod-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/exports/final-export-prod-1x1.png) (`1080×1080`)
- [final-export-prod-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/exports/final-export-prod-9x16.png) (`1080×1920`)
