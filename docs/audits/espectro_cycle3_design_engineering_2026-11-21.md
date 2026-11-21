# ESPECTRO — Ciclo 3: Design Engineering, Acabamento Mobile & Finish Gate

**Branch:** `visual/art-direction-v2` (não mesclada em `main`, sem deploy)  
**Data:** 2026-11-21  
**Integridade do motor e catálogo:** `git diff assets/ lib/domain/engine/ pubspec.yaml | wc -c` = `0` bytes  
**Paleta e anúncios preservados:** Paleta B (Íris + Latão), Dual-Pole vs. Primary-Anchor e módulo AdSense 5 estados mantidos integralmente intactos.

---

## 1. Skills Instaladas e Lentes Utilizadas

As três skills abertas distribuídas via GitHub foram instaladas localmente fora do repositório em `/home/zpower/Downloads/.agents/skills/`:
- **Emil Design Engineering:** [`emil-design-eng/SKILL.md`](file:///home/zpower/Downloads/.agents/skills/emil-design-eng/SKILL.md) (684 linhas) — física de transição (`Cubic(0.23, 1, 0.32, 1)`), escala tátil no pressionamento, eliminação de `ease-in` em entradas/saídas e velocidade percebida.
- **Vercel Web Design Guidelines:** [`web-design-guidelines/SKILL.md`](file:///home/zpower/Downloads/.agents/skills/web-design-guidelines/SKILL.md) (51 linhas) + [`references/command.md`](file:///home/zpower/Downloads/.agents/skills/web-design-guidelines/references/command.md) (191 linhas) — foco, skip links, `scroll-margin-top`, tipografia (`…`, `tabular-nums`), `prefers-reduced-motion`, `color-scheme` e `touch-action`.
- **Taste Skill:** [`taste-skill/SKILL.md`](file:///home/zpower/Downloads/.agents/skills/taste-skill/SKILL.md) (381 linhas) — bordas equilibradas, remoção de redundâncias e acabamento de produto real em navegador.
- **Anti UI Slop / ThinkUI:** aplicados como lentes críticas para reduzir empilhamento genérico de pílulas no mobile, evitar elementos estáticos disfarçados de botões e priorizar conteúdo acionável na primeira dobra.

---

## 2. Revisão Emil Design Engineering (Formato Obrigatório)

| Before | After | Why |
| --- | --- | --- |
| [`theme.dart:666`](file:///home/zpower/Downloads/espectro/lib/theme.dart#L663-L667) — `reverseCurve: Curves.easeInQuad` nas transições de rota | `reverseCurve: EspectroMotion.easeOut` (`Cubic(0.23, 1, 0.32, 1)`) | `ease-in` atrasa o início do retorno visual e dá sensação de lentidão; `ease-out` responde de imediato ao toque |
| [`espectro_home_screen.dart:3487-3489`](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart#L3484-L3490) — `360 ms` e `switchOutCurve: Curves.easeInCubic` no alternador do cartão | `260 ms` com `switchInCurve` e `switchOutCurve` em `EspectroMotion.easeOut` | Mantém alternância frequente abaixo de `300 ms` com saída ágil |
| [`espectro_quiz_screen.dart:866-885`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_quiz_screen.dart#L864-L893) — `AnimatedSwitcher` ignorava preferência de redução de movimento | Consulta `MediaQuery.disableAnimationsOf(context)`, zera duração e retorna `child` sem deslocamento quando ativo | Respeita acessibilidade de movimento reduzido sem perder fluidez padrão (`EspectroMotion.fast`) |
| [`diverging_axis_bar.dart:185-189`](file:///home/zpower/Downloads/espectro/lib/ui/charts/diverging_axis_bar.dart#L182-L190) — `550 ms` `Curves.easeOutCubic` fixo | `420 ms` (ou `Duration.zero` com `disableAnimationsOf`) usando `EspectroMotion.easeOut` | Reduz latência visual ao abrir resultados e respeita `prefers-reduced-motion` |
| [`common.dart:262-265`](file:///home/zpower/Downloads/espectro/lib/widgets/common.dart#L262-L265), [`espectro_suites_screen.dart:74-78`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_suites_screen.dart#L74-L80), [`espectro_intro_screen.dart:188-193`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_intro_screen.dart#L188-L195) e CTAs da Ficha — `scale: 0.98` genérico / ausência de `TactilePress` nos cards de seleção e Ficha | `AppButton` preenchido/contornado em `TactilePress(scale: 0.97)`; cards selecionáveis em `TactilePress(scale: 0.988)` | Dá resposta tátil proporcional à massa do componente ao pressionar |
| [`web/index.html:193-196`](file:///home/zpower/Downloads/espectro/web/index.html#L193-L216), [`web/privacidade.html:70-73`](file:///home/zpower/Downloads/espectro/web/privacidade.html#L90-L103), [`generate_programmatic_seo.py`](file:///home/zpower/Downloads/espectro/tool/seo/generate_programmatic_seo.py#L238-L250) — apenas `opacity: 0.85` em `:active` | `transition: transform 150ms cubic-bezier(0.23, 1, 0.32, 1), background-color 150ms ease, border-color 150ms ease, color 150ms ease;` + `transform: scale(0.97)` sem `transition: all` | Evita animação indiscriminada de propriedades e reproduz sensação física consistente |

---

## 3. Auditoria Vercel Web Design Guidelines (`file:line`)

- [atlas_explorer_screen.dart:277-315](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart#L277-L315) — Compactação de estatísticas no mobile (`< 720 px`) com `FontFeature.tabularFigures()` mantendo `MetricInfoBadge`; placeholder com padrão concreto e reticências tipográficas (`'Ex.: Marx, liberalismo, Brasil, O Príncipe…'`).
- [atlas_explorer_screen.dart:419-468](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart#L419-L468) — Trilho horizontal único (`atlas-mobile-filter-rail`) no mobile com fade direito de `24 px` e filtro `Salvos` imediatamente visível após `Tudo`.
- [study_profile_screen.dart:218-246](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_profile_screen.dart#L218-L246) — TabBar em largura `< 430 px` ajustada (`horizontal: 10`, `fontSize: 11.5`) para exibir `'Fontes e limites'` sem corte horizontal em `390 px`.
- [study_identity.dart:319-340](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_identity.dart#L319-L340) — `subject.kindLabel` e `'· 18/18 dim.'` agrupados em `Wrap` dedicado com `FontFeature.tabularFigures()`, eliminando middot órfão em `390 px` sem gerar `RenderFlex overflow` em `320 px` nem com fonte `2x`.
- [study_profile_screen.dart:375-451](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_profile_screen.dart#L375-L451) — Metadados estáticos (`s.coverageLabel`, `evidenceTierBadge`) separados da fila de CTAs e botão do espectro equipado com ícone direcional (`Icons.explore_outlined`).
- [methodology_screen.dart:149-209](file:///home/zpower/Downloads/espectro/lib/ui/features/methodology/methodology_screen.dart#L149-L209) — Eliminação do segundo título hero redundante e diferenciação visual de `'Limites do catálogo'` (`surfaceMuted`, filete lateral `p.warning`, ícone informativo), além de `FontFeature.tabularFigures()` nas fórmulas e parâmetros (`line 81`, `lines 262-399`).
- [history_evolution_screen.dart:64-100](file:///home/zpower/Downloads/espectro/lib/ui/features/history/history_evolution_screen.dart#L64-L100), [history_evolution_screen.dart:192-239](file:///home/zpower/Downloads/espectro/lib/ui/features/history/history_evolution_screen.dart#L192-L239) — Removido botão redundante `'Voltar'` no AppBar de rota raiz da barra inferior, estilizado botão destrutivo `'Excluir'` com `colorScheme.error`, aplicado `FontFeature.tabularFigures()` em datas/cobertura e adicionado card orientador quando há apenas 1 avaliação.
- [espectro_result_screen.dart:505](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L505), [espectro_result_screen.dart:3836](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L3836), [study_map_screen.dart:1107](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_map_screen.dart#L1107), [study_map_screen.dart:1665](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_map_screen.dart#L1665) — Reticências ASCII `...` substituídas por `…`.
- [web/index.html:161-230](file:///home/zpower/Downloads/espectro/web/index.html#L161-L230), [web/privacidade.html:42-152](file:///home/zpower/Downloads/espectro/web/privacidade.html#L42-L152), [generate_programmatic_seo.py:197-263](file:///home/zpower/Downloads/espectro/tool/seo/generate_programmatic_seo.py#L197-L263) — Tokens alinhados a `#0B0F16`/`#121822`/`#192130`/`#232D3F`/`#F2F4F8`/`#8C97AE`, `color-scheme: dark`, `.skip-link` + `id="main-content"`, `scroll-margin-top: 76px`, `touch-action: manipulation`, `font-variant-numeric: tabular-nums` e `scroll-behavior: auto !important` em `prefers-reduced-motion`.

---

## 4. Finish Gate (Anti UI Slop / ThinkUI)

- **Primeira dobra do Atlas mobile (`390×844`):** Antes, 4 caixas de contagem em 3 linhas + chips em 4 linhas empurravam `'Tradições e espectros'` para fora da tela; agora `'Tradições e espectros'` (`Esquerda radical`, `Esquerda`, `Centro`) e o início de `'Percursos de Descoberta'` aparecem logo abaixo da busca na primeira tela.
- **Cabeçalho e abas da Ficha (`390×844`):** `'Visão geral · Dimensões · Conexões · Fontes e limites'` cabe integralmente na largura mobile sem recorte na última aba, e `'Personalidade · 18/18 dim.'` permanece agrupado na mesma linha abaixo do selo do espectro.
- **Metodologia e Histórico:** Removido o bloco duplo de título na Metodologia (`Limites do catálogo` claramente marcado como nota epistêmica antes das seções numeradas); no Histórico mobile, o título raiz não exibe seta redundante de retorno acima da `NavigationBar` e orienta o usuário com apenas 1 registro salvo.
- **Regressões e limites:** As capturas de golden do teste Flutter continuam carregando `IBMPlexMono` com fallback para `Σ` em fórmulas unicode na Metodologia em `1440px` (comportamento pré-existente do loader de fontes de teste; em Chromium Web renderiza normalmente).

---

## 5. Verificações Executadas após a Edição Final

| Verificação | Comando / Origem | Resultado |
|---|---|---|
| Análise estática | `dart analyze lib/ test/` (`task-24835`) | `No issues found!` |
| Atualização de goldens | `flutter test --update-goldens test/ui/figma_layout_test.dart` (`task-24835`) | `6/6` passaram |
| Suíte completa de testes | `flutter test --reporter=compact` (`task-24835`) | `+301 ~1: All other tests passed!` (0 falhas; 1 skip pré-existente) |
| Integridade metodológica | `git diff assets/ lib/domain/engine/ pubspec.yaml \| wc -c` | `0` bytes |
| Build Web | `flutter build web --no-wasm-dry-run` (`task-24851`) | `✓ Built build/web` |
| Portal SEO estático | `python3 tool/seo/generate_programmatic_seo.py` (`task-24851`) | `Generated 1502 static SEO pages + 8 spectrum pages + catalogo.html + llms.txt + sitemap.xml (1513 URLs).` |
| Chromium WebGL2 QA | `node .../final_verification_webgl_qa.mjs` ([`telemetry_final_v2.json`](file:///home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2/scratch/telemetry_final_v2.json)) | `webgl2Verified: true`, `appConsoleErrors: []`, `appPageErrors: []`, `offlineExpectedAborts: 1`, `quizAdsCheck` vazio, matriz AdSense 4 estados verde, `espectro-post.png` (`1080×1080`, `197155` bytes) e `espectro-story.png` (`1080×1920`, `276736` bytes) |

---

## 6. Comparações Visuais Before / After (`cycle3_craft`)

| Tela / Resolução | Antes | Depois |
|---|---|---|
| Atlas Mobile `390×844` Dark | [before/atlas-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/atlas-390-dark.png) | [after/atlas-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/atlas-390-dark.png) |
| Atlas Desktop `1440×900` Dark | [before/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/atlas-1440-dark.png) | [after/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/atlas-1440-dark.png) |
| Ficha Karl Marx `390×844` Light | [before/marx-390-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/marx-390-light.png) | [after/marx-390-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/marx-390-light.png) |
| Ficha Karl Marx `1440×900` Dark | [before/marx-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/marx-1440-dark.png) | [after/marx-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/marx-1440-dark.png) |
| Metodologia `390×844` Light | [before/metodo-390-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/metodo-390-light.png) | [after/metodo-390-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/metodo-390-light.png) |
| Metodologia `1440×900` Dark | [before/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/metodo-1440-dark.png) | [after/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/metodo-1440-dark.png) |
| Histórico `390×844` Dark | [before/historico-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/historico-390-dark.png) | [after/historico-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/historico-390-dark.png) |
| Histórico `1440×900` Dark | [before/historico-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/historico-1440-dark.png) | [after/historico-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/historico-1440-dark.png) |
| Modalidades `1440×900` Dark | [before/modalidades-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/modalidades-1440-dark.png) | [after/modalidades-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/modalidades-1440-dark.png) |
| Profundidade `1440×900` Dark | [before/profundidade-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/before/profundidade-1440-dark.png) | [after/profundidade-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle3_craft/after/profundidade-1440-dark.png) |

### Cartões Exportados (`final_v2` pós-Ciclo 3)
- [final-export-prod-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/exports/final-export-prod-1x1.png) (`1080×1080`)
- [final-export-prod-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/final_v2/exports/final-export-prod-9x16.png) (`1080×1920`)
