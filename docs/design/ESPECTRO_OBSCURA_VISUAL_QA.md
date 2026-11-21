# Espectro — Relatório de QA Visual, Obscura 0.2.6 & Revisão Cruzada (`visual/art-direction-v2`)

Data: **2026-11-18**  
Branch de trabalho: **`visual/art-direction-v2`** (base `1ce1059` — **sem deploy nem push para `main`**)

---

## 1. Escopo Técnico Honesto: Obscura 0.2.6 vs. Chromium WebGL2 (CanvasKit)

Para manter transparência absoluta sobre o que cada motor valida nativamente:

| Motor de Execução | O que valida de forma nativa | Resultado AFTER | Limitação explícita documentada |
|---|---|---|---|
| **Obscura 0.2.6** (`~/Downloads/obscura-x86_64-linux-stealth/obscura`) | Renderização HTML/CSS estática, shell semântico de fallback (`/`), páginas SEO programáticas (`/catalogo.html`, `/p/personality-karl_marx.html`), matriz responsiva (`360px` a `1920px`), `overflowX`, `brokenImgs` e `consoleErrors` | **10/10 páginas**, `0` overflow horizontal, `0` imagens quebradas, `0` erros de console, `stderr` vazio | Obscura 0.2.6 reporta `hasWebGL: false` (`webGLVersion: -1`). O bootstrap em `web/index.html` bloqueia propositalmente a carga do CanvasKit quando `window.__espectroHasWebGL` é falso para preservar o fallback SEO instantâneo — logo `flt-semantics` não é montado no Obscura (`semanticsCount: 0`, `hasCanvas: false`). |
| **Chromium 1243 (Playwright WebGL2 / CanvasKit)** | Renderização real dos pixels do Flutter CanvasKit, árvore `<flt-semantics>`, interações de clique/teclado/zoom, temas claro/escuro (`prefers-color-scheme`), `prefers-reduced-motion: reduce`, 1..4 Teias simultâneas e Comparador | **27/27 capturas**, `0` `consoleErrors`, `0` `pageErrors`, `24–118` nós `<flt-semantics>` ativos por tela | Na captura automatizada da etapa final do Quiz Express, `result-overview-1440-dark.png` parou no botão `Concluir` do item 24/24; a tela real de Resultados nos temas claro e escuro foi validada visualmente via goldens do Flutter (`test/ui/goldens/resultado-1440-{light,dark}.png`) e suíte de testes de widget. |
| **Hallmark `sloplint.mjs` (v2.0.0)** | Lint automatizado das entregas HTML estáticas (`build/web/index.html`, `build/web/catalogo.html`, `build/web/p/personality-karl_marx.html`) | **0 FAIL, 0 REFLEX, 1 WARN** (`Gate 58` em `catalogo.html`, índice SEO de 1.502 verbetes / 13.473 palavras — esperado) | O `sloplint.mjs` inspeciona HTML/CSS; as regras do Hallmark para a aplicação Flutter foram traduzidas manualmente em `ESPECTRO_HALLMARK_VISUAL_AUDIT.md` e auditadas por subagente independente. |

---

## 2. Matriz Responsiva e de Estados Validados

### 2.1 Obscura 0.2.6 (HTML/SEO estático)
Capturas em [`docs/design/screenshots/after/obscura/`](./screenshots/after/obscura/):

| Rota / Captura | Viewport | `overflowX` | `brokenImgs` | `h1FontSize` | `consoleErrors` |
|---|---|---:|---:|---:|---:|
| `/` (`home-static-360.png`) | `360×800` | `false` | `0` | `30.4px` | `0` |
| `/` (`home-static-390.png`) | `390×844` | `false` | `0` | `30.4px` | `0` |
| `/` (`home-static-768.png`) | `768×1024` | `false` | `0` | `30.72px` | `0` |
| `/` (`home-static-1280.png`) | `1280×800` | `false` | `0` | `45.6px` | `0` |
| `/` (`home-static-1440.png`) | `1440×900` | `false` | `0` | `45.6px` | `0` |
| `/` (`home-static-1660.png`) | `1660×900` | `false` | `0` | `45.6px` | `0` |
| `/` (`home-static-1920.png`) | `1920×1080` | `false` | `0` | `45.6px` | `0` |
| `/catalogo.html` (`catalogo-seo-1440.png`, `-390.png`) | `1440×900`, `390×844` | `false` | `0` | `40px` / `28px` | `0` |
| `/p/personality-karl_marx.html` (`marx-seo-1440.png`) | `1440×900` | `false` | `0` | `40px` | `0` |

*Correção SEO aplicada após revisão cruzada*: corrigido `.strip(" ,()")` em `tool/seo/generate_programmatic_seo.py` que removia o parêntese de fechamento da origem das personalidades — confirmado em `after/obscura/marx-seo-1440.png` (`1818-1883 (Alemanha / Reino Unido)`).

### 2.2 Chromium WebGL2 / Flutter CanvasKit (Aplicação Viva)
Capturas em [`docs/design/screenshots/after/webgl/`](./screenshots/after/webgl/):

- **Home**: Claro `1440×900`, Escuro `1440×900` (topo, meio, inferior), Escuro `prefers-reduced-motion: reduce`, `360×800`, `390×844`, `768×1024`, `1280×800`, `1660×900`, `1920×1080` (`40–89` nós `<flt-semantics>`).
- **Interações reais na Home**: clique em `Outro dilema` (`outroClicked: true`) + resposta `Concordo` com revelação do insight e progresso `4% concluído` (`dilemmaPicked: true`).
- **Teia de Ideias**: 1 painel Claro e Escuro (`1440×900`, `90` nós), 4 painéis simultâneos com Inspetor aberto (`118` nós) e tela cheia sem Inspetor (`63` nós), mobile `390×844` (`27` nós).
- **Interações reais na Teia**: `+ Teia` acionado 3× até montar as 4 projeções simultâneas (`panesAdded: 3`, `Nolan`, `Economia × Poder`, `Moral × Religião`, `Diplomacia × Imigração`), zoom funcional (`zoomClicked: true`), fechamento do Inspetor.
- **Comparador**: Claro e Escuro `1440×900` (topo, radar 12 eixos, régua contínua de 12 eixos) + mobile `390×844` (`36–48` nós).
- **Atlas & Quiz**: `atlas-1440-dark-top.png`, `atlas-1440-dark-list-polcompballs.png` (Polcompballs preservados), `quiz-express-1440-dark.png`.
- **Fonte ampliada 2.0x**: validado sem nenhum `RenderFlex overflow` na suíte Flutter (`design_portability_regression_test.dart`, `study_exploration_test.dart` em `390px` e `1440px`, `figma_layout_test.dart`).

---

## 3. Síntese das Três Revisões Cruzadas Independentes e Correções Aplicadas

Foram executados três subagentes independentes de auditoria sobre o recorte vertical (`Home + Teia 1x/4x + Comparador`):

### 3.1 Revisão Hallmark & Direção Artística (Anti-Clichês de IA)
- **Resolvidos (Antes → Depois)**:
  - Remoção da caixa roxa SaaS com gradiente e barra arco-íris no topo da Home; substituição por composição assimétrica 5:7 aberta diretamente no papel calcário (`#EFECE4`) / obsidiana (`#0A0F17`) com a **Teia viva de 289 correntes** já acima da dobra.
  - Eliminação das "nebulosas" difusas na Teia (`Gate 29`), substituídas por envoltórias convexas vetoriais e retículo calibrado `±25% / ±50% / ±75%`.
  - Substituição dos subcartões aninhados verde/âmbar (`Gate 4`) em `Proximidade por par` por matriz especular separada por filetes de 1px e régua contínua única para os 12 eixos (eliminando 12 cartões empilhados no Comparador).
  - Remoção da caixa externa redundante em `Os 12 Eixos do Espectro` na Home (`Gate 4`).
- **Correções aplicadas após a crítica**:
  - `lib/theme.dart`: substituído o gradiente frio azulado residual (`#F6F8FC → #F0F3F9`) em `EspectroElevation.cardDecoration` e `trophyDecoration` por tons calcários quentes (`#FAF8F3 → #F5F2EA`).
  - `lib/ui/features/home/espectro_home_screen.dart`: H1 desktop elevado (`28px → 32px`), rótulos do mini-radar elevados de `8px` mono em siglas crípticas (`EST`, `POD`) para `10.5px` `IBMPlexSans` legíveis (`Estrutura`, `Poder`, `Diplo.`, `Economia`, `Comércio`, `Moral`), e selos micro (`8.5px–9.5px`) elevados para `10.5px–11px`.
  - `lib/ui/features/compare/study_comparison_screen.dart`: removidos swatches fixos de Tailwind (`#10B981`, `#F59E0B`, `#EC4899`), corrigido o recorte da barra bicolor no topo de `Proximidade por par` com `Material(..., clipBehavior: Clip.antiAlias)`, removida a legenda duplicada ao lado do radar de `350px` e unificados os 12 eixos em uma única tabela analítica com divisores de 1px.
  - `lib/ui/features/atlas/study_map_screen.dart`: contraste adaptativo (`Color.lerp`) em `TeiaAxisSlider` para porcentagens legíveis sobre `#111824`.

### 3.2 Auditoria de Fidelidade Matemática & Dataviz
- **Pureza de motores e catálogo**: **PASS** — `git diff lib/domain/ assets/` retornou **0 bytes**. Nenhum cálculo de eixos, tríades, afinidades, normalizações ou verbetes do catálogo foi modificado.
- **Escala 1:1 e projeções**: **PASS** — `TeiaPreviewPainter` usa fator de escala uniforme (`scaleX == scaleY`) sobre a geometria canônica `StudyConstellationGeometry` (`880×880`, centro `440`, raio `340` para `±100%`). Radar comparativo (`350px`) com anel tracejado exato em `50%` e 12 rótulos completos sem truncamento.
- **Correções aplicadas após a crítica**:
  - `lib/ui/charts/teia_cartographic_layer.dart`: corrigido o corte interno das curvas Bézier em vértices agudos (que deixava 24–40 pontos fora da linha da envoltória) adotando expansão radial de `18px` + arredondamento local de `16%` nos vértices — contendo 100% das correntes dentro de seus territórios sem deformar coordenadas.
  - `lib/ui/charts/teia_preview_panel.dart`: incluídos os quatro marcadores cardeais explícitos (`AUTORITARISMO ↑`, `ANARQUISMO ↓`, `← ESQUERDA`, `DIREITA →`) para eliminar ambiguidade de polaridade vertical na prévia da Home.
  - `lib/ui/charts/study_constellation.dart`: ajuste na caixa de colisão das pílulas foscas (`padX`/`padY` reais) eliminando toque horizontal entre rótulos na Teia 4x e recorte de `Anarcocapitalismo` na borda direita em `390px`; desativados os rótulos de centroide em modo compacto multi-painel para limpar os quadrantes 2, 3 e 4.

### 3.3 Auditoria de UX, Acessibilidade, Movimento Reduzido & Portabilidade
- **Portabilidade multiplataforma (Web, Android, Linux, Windows)**: **PASS** — zero importações web-only (`dart:html`, `dart:js`, `dart:ui_web`) em todos os arquivos criados ou modificados.
- **Correções aplicadas após a crítica**:
  - `lib/ui/charts/teia_preview_panel.dart`: cabeçalho `Projeção Nolan (289 correntes)` + `Abrir Teia completa` movido para faixa dedicada acima do canvas (eliminando invasão do gráfico em `360px`), com `Semantics` e `MouseRegion(cursor: SystemMouseCursors.click)`.
  - `lib/ui/charts/study_constellation.dart` + `lib/ui/features/atlas/study_map_screen.dart`: controles compactos de zoom/pausa (`[+][-][center][pause]`) movidos para barra inferior dedicada de `30px` abaixo de cada quadrante na Teia 4x (zero sobreposição em pontos dos 4 painéis), pílula flutuante `Espectros` oculta em modo multi-painel recolhido (liberando o quadrante 3, mantendo acesso pelo ícone da barra superior), e `Semantics`/`MouseRegion` + respeito a `disableAnimationsOf(context)` no dilema e na paginação mobile da Teia.
  - `lib/ui/features/atlas/study_profile_screen.dart`: rótulos de perfil e polo dentro de `StudyAxisRow` tornados flexíveis (`Flexible` + ellipsis), zerando overflows em nomes longos em viewports estreitos.

---

## 4. Problemas Residuais Documentados (Backlog P2 Pós-Aprovação Visual)

Mantidos deliberadamente fora deste recorte vertical para preservar integralidade funcional e aguardar aprovação visual da direção **Cartografia Viva**:

1. **Backlog estrutural residual (pós-Ciclo 2)**: o Ciclo 2 resolveu os principais clichês de UI identificados nessas telas — removeu o cartão hero roxo com gradiente diagonal de `EditorialHero`, eliminou réguas arco-íris (`SpectrumGradientRule`), medalhas numeradas `01/02/03`, botões preenchidos duplos em `EspectroResultScreen`, listras superiores/cantos redundantes de `_SpectrumCard` em `AtlasExplorerScreen`, além de restaurar a paridade claro/escuro no `_EspectroDesktopRail`. Permanecem apenas para eventual Fase 2B estrutural: os 4 níveis internos de cartões em `EspectroResultScreen`, a grade de chips de filtro acima da dobra em `AtlasExplorerScreen` e as strings de gancho em caixa alta preservadas literalmente para não alterar nenhum arquivo de teste em `test/`.
2. **Faixa flutuante de anúncio sem preenchimento em ambiente headless (`EspectroFloatingAdBar`)**: nas capturas locais sem retorno da rede do Google AdSense, o `HtmlElementView` exibe um retângulo cinza vazio acima da barra inferior. **Não foi alterado** em respeito estrito à restrição de preservação de anúncios da tarefa; recomenda-se em fase posterior colapsar a altura do slot web apenas enquanto não houver criativo preenchido.
3. **Alinhamento do HTML estático (`web/index.html`, `catalogo.html`, `p/*.html`)**: o fallback sem WebGL continua com a paleta escura anterior (`#0B0E14`) e sem `@media (prefers-color-scheme: light)` nem `@font-face` local de `IBMPlexSans` (no Obscura, `I` em negrito renderiza parecido com `l` na fonte de fallback do sistema).
4. **Ambiguidade de rótulo `Economia` em `StudyCatalog.compare`**: quando o Eixo `Economia` e a Tríade `Economia` aparecem simultaneamente em `Contrastes`, ambos imprimem `"Economia: posições distintas (...)"`. Como a string nasce em `lib/domain/models/study_models.dart`, foi preservada intacta nesta etapa para manter 0 bytes de diff em `lib/domain/`.
5. **Contagem canônica vs. catálogo SEO**: o Atlas interativo exibe `1496 verbetes` canônicos enquanto `catalogo.html` indexa `1502 verbetes`.
6. **Rota `/design-lab`**: exposta na branch `visual/art-direction-v2` para revisão lado a lado dos 3 conceitos (`Cartografia Viva`, `Atlas Editorial`, `Laboratório Especular`) e estudo cartográfico; decidir antes do merge em produção se será mantida pública ou restrita.


---

## 5. Ciclo 2 — Limpeza Autoral Anti-AI-Slop (Hallmark Polish)

Aplicação sistemática das regras anti-AI-slop do Hallmark sobre o **Espectro** preservando sua identidade editorial mineral, estrutura de telas, motor matemático e arquitetura multiplataforma.

### Clichês removidos por área

| Área / Arquivo | Clichê de IA removido | Solução autoral aplicada |
| :--- | :--- | :--- |
| **Tokens e elevação** ([theme.dart](file:///home/zpower/Downloads/espectro/lib/theme.dart)) | Halos de sombra em modo escuro, borda branca fixa e fundo frio `#EDF0F7` no bloco troféu | `EspectroElevation.cardShadows` zerado em dark mode; borda semântica `p.line.withValues(alpha: 0.85)`; calcário quente `#F3EFE6` em `trophyDecoration` |
| **Tipografia de apoio** ([common.dart](file:///home/zpower/Downloads/espectro/lib/widgets/common.dart), [quiz_chrome.dart](file:///home/zpower/Downloads/espectro/lib/widgets/quiz_chrome.dart), [espectro_quiz_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_quiz_screen.dart)) | Sobrecarga de `ALL CAPS` com `letterSpacing: 1.1..1.3` em olhos-de-seção, chips de eixo/categoria e overlines | `Eyebrow`, `AxisChip`, `CategoryChip` e `categoryOverline` convertidos para sentence case em `IBMPlexSans`; contador do quiz em `IBMPlexMono` tabular `11.5px`; `Tag` mantido em `IBMPlexSans` `10.5px` (`letterSpacing: 0`) |
| **Cabeçalho hero editorial** ([editorial.dart](file:///home/zpower/Downloads/espectro/lib/widgets/editorial.dart)) | Cartão hero roxo com gradiente diagonal (`#4E3FA5`, raio `22`) em páginas secundárias | `EditorialHero` convertido para chapa arquitetônica plana em `p.surface` (`radius: 14`, borda `1px` `p.line`, `p.ink`/`p.inkSoft`, selos em `p.surfaceMuted`) |
| **Navegação desktop** ([espectro_scaffold.dart](file:///home/zpower/Downloads/espectro/lib/widgets/espectro_scaffold.dart)) | Rail desktop preso em bloco escuro mesmo no tema claro, pontos laranja decorativos e micro-rótulos mono em caixa alta | `_EspectroDesktopRail` com paridade claro/escuro (`#E7E3D8` no claro / `#080C14` no escuro), traço vertical `2.5×16px` em `p.accent`, rótulos em `IBMPlexSans` `11.5px` e respeito a `MediaQuery.disableAnimationsOf(context)` |
| **Home e jogos psicológicos** ([espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart)) | Caixas cinzentas aninhadas dentro de cartões, estágios artificiais e isca `??%` com cadeado | `_IdeologicalRiddleGameCard` com borda esquerda `2.5px` em `p.accent` e CTA direto `'Descobrir sua assinatura'`; Passaporte em `Etapa 1..4`; `_HeroLiveSpectrumShowcase` com `'Comparar sua posição com ... (3 min)'` / `'Sua afinidade real: ...% — Abrir Raio-X'` e `'Mapear seu perfil'` |
| **Atlas e fichas** ([atlas_explorer_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart), [study_profile_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_profile_screen.dart)) | Listras de `3.5px` no topo de cada card, bolinhas decorativas e contagem duplicada em `_SpectrumCard` | Regra vertical `3×16px` alinhada ao título, contagem tabular única, subtítulos separados por vírgula e badges `IBMPlexSans` `11px` em `StudySubjectTile` e `relation.kind.label` em sentence case |
| **Modalidades e introdução** ([espectro_suites_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_suites_screen.dart), [espectro_intro_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_intro_screen.dart)) | Três réguas arco-íris (`SpectrumGradientRule`), medalhas `01/02/03`, badge lateral duplicado no resumo e card escuro forçado (`p.heroBackground`) | Remoção completa das réguas arco-íris e medalhas; numeração tabular inline `'01'..'03'`; painel resumo plano em `p.surface` com título único `'${activeSpec.$2} (${activeSpec.$3})'` e botão `'Iniciar avaliação ($count perguntas)'` |
| **Resultados, comparadores e radar** ([espectro_result_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart), [multidimensional_radar_chart.dart](file:///home/zpower/Downloads/espectro/lib/ui/charts/multidimensional_radar_chart.dart), comparadores, `raio_x_card.dart`, `methodology_screen.dart`) | Dois botões preenchidos concorrendo lado a lado, olhos em caixa alta e radar pequeno com rótulos mono truncados | `Desafiar amigo` rebaixado para `OutlinedButton.icon`; detecção resiliente `kicker.toLowerCase().startsWith('pensador')`; radar ampliado (`248.0` lado a lado / `math.min(220.0, constraints.maxWidth - 24)` empilhado) com anel neutro de 32 arcos em 50% e rótulos `10.5px` `IBMPlexSans` (até 13 caracteres) |

### Ganchos de teste preservados literalmente (nenhum arquivo em `test/` alterado)

Seguindo a diretriz de integridade do Hallmark (`redesign.md`), nenhum arquivo em `test/` foi modificado para adaptar asserções. Foram preservados literalmente os ganchos esperados pela suíte de regressão:

- `COBERTURA`, `CONFIANÇA`, `APOIO MÉDIO I`, `INDETERMINADO` (via `Tag` com tipografia refinada)
- `SESSÃO EM ANDAMENTO`, `DILEMA RELÂMPAGO · 1/24`, `ECONOMIA · PÚBLICO VS. PRIVADO` (e os demais `axisTag`s dos dilemas), `4% concluído (1/24) · Seu Arquétipo começou a emergir`, `Continuar da pergunta 2/24 →`, `Próximo enigma →`
- `PRÉVIA EM 12 EIXOS`, `OS 12 EIXOS`, `DIAGNÓSTICO ESTRUTURADO`, `Nível 1 · Reconstrução primária`, `Tema claro fumê` / `Tema escuro noturno` e `'Iniciar avaliação'` (como prefixo do rótulo de CTA)

### Evidências e verificações do Ciclo 2

- **Integridade de domínio, dados e anúncios**: `0` bytes de diff em `lib/domain/`, `assets/` e `lib/ui/ads/`
- **Análise estática e suíte Flutter**: `dart analyze lib/ test/` com `0` erros e `0` avisos (`1` aviso pré-existente de `cacheExtent` depreciado em `espectro_home_screen.dart:398:19`); `flutter test` completo com `+284 ~1` (`1` teste pulado pré-existente em `test/domain/user_vector_dossier_test.dart:244`) e goldens atualizados sem regressão
- **Build Web, SEO e `sloplint.mjs`**: `flutter build web --no-wasm-dry-run` concluído (`build/web`), `generate_programmatic_seo.py` (`1513 URLs`) e `sloplint.mjs` com `0 FAIL, 1 WARN` (em `catalogo.html`, Gate 58)
- **Navegação Obscura 0.2.6 e Chromium WebGL2 (`qa_runner.mjs --mode after`)**: `27` capturas WebGL2 e `10` renderizações estáticas no Obscura 0.2.6 com `consoleErrors: []`, `pageErrors: []`, interações na Home (`outroClicked: true`, `dilemmaPicked: true`) e na Teia (`panesAdded: 3`, `zoomClicked: true`, `paneCountAfter: 9`)


---

## 6. Ciclo 3 — Tela Inicial Instagramável & Cartão Compartilhável Colecionável

Evolução do impacto visual da primeira dobra e do artefato compartilhável para que o visitante enxergue nos primeiros segundos o pôster colecionável (`Story 9:16` e `Post 1:1`) que o aplicativo gera a partir de coordenadas reais do catálogo.

### Mudanças implementadas

- **Pôster cartográfico em `ShareCardCanvas`** ([share_card_content.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart)):
  - Remoção da régua arco-íris (`SpectrumGradientRule`), do halo radial no canto superior e das caixas arredondadas empilhadas com `'100% ANÔNIMO'`.
  - Novo acabamento com retículo e cruzes de registro (`_ShareCardPlatePainter`), emblema Polcompball real (com fallback `CurrentHeraldicEmblem`), radar em ordem canônica dos 12 eixos com anel tracejado em 50% (`_SharePosterRadarPainter`), mini-bússola de Nolan (`_MiniNolanCompassPainter`) e linha de **pensador próximo** (`EspectroAtlasEngine.rankEntries`) exibida somente quando há evidência observada (mantendo `'Nolan indeterminado'` e zero `%` artificiais para registros vazios).
  - Ajuste em `_ShareAxisMiniBar` com `Flexible` para acomodar sumários longos nos formatos **Post `1:1`** (`360×360` → PNG `1080×1080`) e **Story `9:16`** (`360×640` → PNG `1080×1920`).
- **Espécime colecionável reutilizável (`HomeShareCardSpecimen`)** ([home_share_card_specimen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/share/home_share_card_specimen.dart)):
  - Placa em obsidiana fosca com retículo e moldura na cor da tradição, elevação limpa sobre o fundo calcário claro, Polcompball/retrato real, bússola de Nolan, radar em 12 eixos e selos `'ESPECTRO · STORY 9:16'` / `'ESPECTRO · POST 1:1'` (preservando `ESPECTRO` único na barra de marca para os testes).
- **Tela Inicial e prévia da Teia** ([espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart), [teia_preview_panel.dart](file:///home/zpower/Downloads/espectro/lib/ui/charts/teia_preview_panel.dart)):
  - No desktop (`_ObservatoryCoverHero`), díptico lado a lado entre `TeiaInteractivePreviewPanel` (`showFooter: false`, `headerHint: 'Toque num nó · cartão ao vivo'`) e o `HomeShareCardSpecimen` sincronizado ao vivo com a corrente tocada na Teia.
  - No mobile (`360px`/`390px`), alternador entre **`Cartão 9:16`** (com atalhos rápidos para `Liberalismo`, `Social-Democracia`, `Conservadorismo` e `Socialismo`) e **`Teia · 289 correntes`**.
  - Em `_LatestEvaluationBentoCard`: remoção da faixa colorida de `3.5px`, adição do botão `'Compartilhar cartão'` (`ShareableCardSheet.show`) e miniatura `Post 1:1` do resultado do usuário em larguras `>= 740px`.
  - Em `_HeroLiveSpectrumShowcase` (`Veja como fica o seu cartão de resultado`): alternador **`Post 1:1` / `Story 9:16`** para pré-visualizar o cartão com retrato real dos pensadores (`Arendt`, `Marx`, `Rothbard`, `Keynes`, `Hayek`).

### Evidências e verificações do Ciclo 3

- **Integridade de domínio, dados e testes**: `0` bytes de diff em `lib/domain/`, `assets/`, `lib/ui/ads/` e nos arquivos `.dart` de `test/`.
- **Análise estática e suíte Flutter**: `dart analyze lib/ test/` com `0` erros e `0` avisos (`1` `info` pré-existente de `cacheExtent` em `espectro_home_screen.dart:400`); `flutter test test/ui/figma_layout_test.dart --update-goldens` (`6/6` aprovados) e `flutter test --reporter=compact` completo com `+284 ~1` (`1` teste pulado pré-existente, `0` falhas, sem `test/ui/failures`).
- **Build Web, SEO, `sloplint.mjs` e QA WebGL2/Obscura**:
  - `flutter build web --no-wasm-dry-run` (`31,9s`), `generate_programmatic_seo.py` (`1513 URLs`) e `sloplint.mjs` (`0 FAIL, 1 WARN` esperado no Gate 58 de `catalogo.html`).
  - `qa_runner.mjs --mode after`: `10` capturas Obscura 0.2.6 com `consoleErrors: []` e `stderr: ""`; `27` capturas WebGL2 no Chromium com `pageErrors: []`, interações na Home e Teia (`outroClicked: true`, `dilemmaPicked: true`, `panesAdded: 3`, `zoomClicked: true`, `paneCountAfter: 9`), registrando em `consoleErrors` apenas o aviso report-only de CSP do iframe do Google AdSense no ambiente headless.
- **Inspeção visual pós-polimento**: conferidos em `read_file` [home-390-dark.png](file:///home/zpower/Downloads/espectro/docs/design/screenshots/after/webgl/home-390-dark.png) (`Cartão 9:16` sem reticências), [home-1280-dark.png](file:///home/zpower/Downloads/espectro/docs/design/screenshots/after/webgl/home-1280-dark.png) (URLs e eixos completos sem corte), [home-1440-light-top.png](file:///home/zpower/Downloads/espectro/docs/design/screenshots/after/webgl/home-1440-light-top.png) e [home-1440-dark.png](file:///home/zpower/Downloads/espectro/test/ui/goldens/home-1440-dark.png).
