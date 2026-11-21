# Espectro — Auditoria Ciclo 5: Sistema Unificado de Espaçamento (`EspectroLayout`), Atlas e Comparação

**Data:** 21 de novembro de 2026  
**Branch:** `visual/art-direction-v2` (sem merge em `main` e sem deploy automático)  
**Integridade metodológica:** `git diff assets/ lib/domain/engine/ pubspec.yaml | wc -c` = **`0`** bytes.

---

## 1. Diagnóstico das Inconsistências Encontradas

Ao auditar o código-fonte e as capturas em `1440×900` e `390×844` após o apontamento direto do usuário (*"notei inconsistências de espaçamento entre telas, repare no atlas e na comparação"*), foram identificadas duas camadas de desalinhamento:

1. **Quebra de prumo horizontal e espaçamento de topo entre telas:**
   - As telas usavam 8 larguras máximas distintas (`760`, `900`, `920`, `960`, `1000`, `1060`, `1100`, `1240`), 6 recuos superiores diferentes (`12`, `14`, `18`, `20`, `22`, `26`, `28 px`) e margens laterais divergentes (`20` vs `22` no mobile e `18` vs `32` no desktop entre abas de Resultados).
   - O `_WorkspaceConstrainedAppBar` limitava a `AppBar` a `1100 px` com recuo padrão do Material (`16 px`), desalinhando o título da `AppBar` em relação ao conteúdo do corpo em todas as seções (`Atlas`: `4 px`; `Comparação`: `34 px`; `Histórico`: `94 px`; `Metodologia`: `174 px`; além de um salto de `80 px` entre as abas da tela de Resultados).
2. **Ritmo vertical irregular e lacunas duplas internas em Atlas e Comparação:**
   - **Atlas:** respiro de `36 px` antes de *Tradições e espectros* contra `18 px` antes de *Percursos de Descoberta*, seguido de gap duplo (`14 + 12 = 26 px`) antes de *N verbetes* e outro gap duplo (`16 + 18 = 34 px`) antes do cabeçalho da primeira categoria.
   - **Comparação:** gap duplo de `40 px` (`Padding(bottom: 16)` dentro de `_pair` + `SizedBox(height: 24)`) entre o cartão de par e o radar contra apenas `16 px` antes de *Tríades*, gap duplo de `30 px` antes de *Como ler a comparação*, mistura de raios (`12` vs `14`) e paddings (`18`/`20`/`22`), além de 4 linhas empilhadas de chips em `390×844` empurrando *Proximidade por par* para fora da dobra inicial.

---

## 2. Sistema Centralizado `EspectroLayout` ([theme.dart](file:///home/zpower/Downloads/espectro/lib/theme.dart))

Criada a classe de tokens `EspectroLayout`:

- `workspaceMaxWidth = 1100.0` (`workspaceInnerWidth = 1060.0`)
- `proseMaxWidth = 860.0` (medida editorial de leitura contínua na Metodologia, alinhada à esquerda em `x0 + 20`)
- `quizMaxWidth = 680.0`
- `pageHorizontalPadding = 20.0`, `pageTopPadding = 24.0`, `pageBottomPadding = 72.0` (`EspectroLayout.pagePadding`)
- Ritmo vertical compartilhado: `sectionGap = 28.0`, `blockGap = 20.0`, `controlGap = 14.0`, `headerToContentGap = 14.0`, `cardGap = 14.0`

Todos os títulos de `AppBar` sem botão voltar passam a usar `titleSpacing: EspectroLayout.pageHorizontalPadding` (`20.0`), alinhando o texto da `AppBar`, a borda de `TabBar` e o conteúdo do corpo exatamente sobre a mesma linha vertical em `1440 px` e `390 px`.

---

## 3. Alterações Aplicadas Tela a Tela

### 3.1 Atlas Político ([atlas_explorer_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart))
- `AppBar` com `titleSpacing: EspectroLayout.pageHorizontalPadding`, corpo em `maxWidth: EspectroLayout.workspaceInnerWidth` (`1060 px`) e `padding` externo `(20, 24, 20, 72)`.
- Cadência interna unificada: hero → faixa de estatísticas (`12 px`), estatísticas → busca (`controlGap = 14`), busca → chips (`14`), chips → *Tradições e espectros* (`sectionGap = 28` quando sem busca ativa; `blockGap = 20` quando filtrando), *Tradições* → *Percursos de Descoberta* (`28 px`), *Percursos* → *N verbetes* (`28 px`, eliminando o gap duplo `14 + 12`), e primeiro grupo da lista com `top: index == 0 ? 0 : 24`, eliminando o gap duplo `16 + 18`.
- Cabeçalho de *Percursos de Descoberta* padronizado para título → subtítulo (`6 px`) → cards (`headerToContentGap = 14`).

### 3.2 Comparação Livre ([study_comparison_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/study_comparison_screen.dart))
- Substituído `LayoutBuilder` próprio (`1000 px` + `hPad >= 22`, topo `22`) por `ResponsiveContentFrame(maxWidth: EspectroLayout.workspaceMaxWidth)` + `padding: EspectroLayout.pagePadding` (`20, 24, 20, 72`) e `titleSpacing: EspectroLayout.pageHorizontalPadding` na `AppBar`.
- Removido o `Padding(bottom: 16)` interno de `_pair()`: o espaçamento entre pares usa exclusivamente `cardGap` (`14 px`), e toda transição entre seções (*Proximidade por par* → *Visão em teia* → *Mesmos eixos* → *Tríades* → *Como ler a comparação*) usa `sectionGap` (`28 px`).
- Títulos → subtítulos normalizados (`6 px`), cabeçalhos → cards (`14 px`) e todos os cartões padronizados com `BorderRadius.circular(14)` e `EdgeInsets.all(20)`.
- No mobile (`< 680 px`), as sugestões de *Adicionar 3º perfil* agora usam trilho horizontal em 1 linha (`Key('comparacao-mobile-suggestions-rail')`), trazendo *Proximidade por par* para dentro da dobra inicial em `390×844`.

### 3.3 Coerência em Todas as Outras Telas Principais
- **Home** ([espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart)): workspace desktop alinhado para `EspectroLayout.workspaceMaxWidth` (`1100`), topo desktop para `EspectroLayout.pageTopPadding` (`24`), e proporção do Herói ajustada de `5:7` para `11:13` (`SizedBox(width: 28)`) mantendo *Fazer Avaliação Expressa (3 min)* e *Explorar o Atlas* lado a lado na mesma linha.
- **Histórico** ([history_evolution_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/history/history_evolution_screen.dart)): `maxWidth: EspectroLayout.workspaceMaxWidth`, `titleSpacing: 20`, `TabBar` com `horizontal: 20` e `ListView`s com `EspectroLayout.pagePadding`.
- **Metodologia** ([methodology_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/methodology/methodology_screen.dart)): workspace de `1100 px`, `TabBar` e conteúdo alinhados em `x0 + 20`, mantendo blocos de texto da aba 0 limitados a `EspectroLayout.proseMaxWidth` (`860 px`) à esquerda para conforto de leitura.
- **Modalidades e Profundidade** ([espectro_suites_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_suites_screen.dart), [espectro_intro_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_intro_screen.dart)): `workspaceMaxWidth` (`1100`) e `pagePadding` sem deslocamento extra horizontal de `2 px` nos títulos.
- **Perfil do Atlas e Comparações Auxiliares** ([study_profile_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_profile_screen.dart), [entity_comparison_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/entity_comparison_screen.dart), [compare_evaluations_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/compare_evaluations_screen.dart)): `workspaceMaxWidth`, `pagePadding` e alinhamento de `TabBar` (`Visão geral` na linha exata `20 px`).
- **Resultados (5 abas)** ([espectro_result_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart)): eliminada a divergência de `80 px` entre *Visão Completa* e as outras 4 abas (`workspaceMaxWidth` / `workspaceInnerWidth` + `pagePadding` + `TabBar` alinhado em `horizontal: 4`).
- **PolePill (`320 px / 1.3x`)** ([common.dart](file:///home/zpower/Downloads/espectro/lib/widgets/common.dart)): ao padronizar a margem lateral de *Resultados* de `18` para `20 px`, a matriz de testes revelou overflow subpixel (`0,841 px`) em `PolePill` na escala `1.3x` em `320 px` causado pelo `Text(badge!)` fora de `Flexible`. Rótulo e selo agora usam um único `Flexible(child: Text.rich(...))` com `tabularFigures()`.

---

## 4. Verificação Objetiva Executada Após o Último Edit

- **`dart analyze lib/ test/`**: `No issues found!`
- **`flutter test --update-goldens test/ui/figma_layout_test.dart`**: `+6: All tests passed!`
- **`flutter test --reporter=compact`**: `+304 ~1: 1 skipped test. All other tests passed!` (inclui o novo teste `Cycle 5 (spacing)` em [audit_matrix_verification_test.dart](file:///home/zpower/Downloads/espectro/test/ui/audit_matrix_verification_test.dart) validando alinhamento `<= 1.0 px` entre título da `AppBar` e `EditorialHeading` em Atlas, Comparação, Histórico e Metodologia em `1440×900` e `390×844`, mais trilho mobile da Comparação e visibilidade de *Proximidade por par* acima de `y = 844 px`).
- **`git diff assets/ lib/domain/engine/ pubspec.yaml | wc -c`**: `0`
- **`flutter build web --no-wasm-dry-run`** + **`python3 tool/seo/generate_programmatic_seo.py`**: `✓ Built build/web` (`34,4s`) + `Generated 1502 static SEO pages + 8 spectrum pages + catalogo.html + llms.txt + sitemap.xml (1513 URLs).`
- **QA Chromium WebGL2** ([telemetry_final_v2.json](file:///home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2/scratch/telemetry_final_v2.json)): `webgl2Verified: true`, `appConsoleErrors: []`, `appPageErrors: []`, `offlineExpectedAborts: 1`, matriz AdSense de 5 estados íntegra, `exports.post1x1` (`1080×1080`, `194722` B) e `exports.story9x16` (`1080×1920`, `274079` B).

---

## 5. Comparativo Antes / Depois (Inspecionado em Pixels)

- **Atlas `1440px`:** [before/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/atlas-1440-dark.png) → [after/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/atlas-1440-dark.png)
- **Comparação `1440px`:** [before/compare-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/compare-1440-dark.png) → [after/compare-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/compare-1440-dark.png)
- **Comparação Eixos `1440px` (Claro):** [before/compare-1440-light-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/compare-1440-light-12axes.png) → [after/compare-1440-light-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/compare-1440-light-12axes.png)
- **Atlas `390px`:** [before/atlas-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/atlas-390-dark.png) → [after/atlas-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/atlas-390-dark.png)
- **Comparação `390px`:** [before/comparacao-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/comparacao-390-dark.png) → [after/compare-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/compare-390-dark.png)
- **Home `1440px`:** [before/home-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/home-1440-dark.png) → [after/home-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/home-1440-dark.png)
- **Metodologia `1440px`:** [before/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/metodo-1440-dark.png) → [after/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/metodo-1440-dark.png)
- **Histórico `1440px`:** [before/historico-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/historico-1440-dark.png) → [after/historico-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/historico-1440-dark.png)
- **Resultados Visão Completa `1440px`:** [before/result-overview-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/before/result-overview-1440-dark.png) → [after/result-overview-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle5_spacing/after/result-overview-1440-dark.png)
