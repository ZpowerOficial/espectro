# ESPECTRO — Relatório de Auditoria de Refinamento Visual, UX e Consistência (v1.0)

**Branch:** `visual/art-direction-v2`  
**Escopo auditado:** Desktop (`1440×900`, `1024×768`), Tablet (`768×1024`), Mobile (`390×844`, `320×568`), temas claro e escuro, 13 fluxos principais e cartões de compartilhamento (`Post 1:1` e `Story 9:16`).

---

## 1. Resumo Executivo e Preservação Metodológica

Todos os ajustes priorizados (**P1.1–P1.6**) e de refinamento (**P2.1–P2.4**) foram implementados preservando integralmente o motor matemático, as fórmulas, pesos, incertezas, normalizações, catálogo editorial e componentes de anúncios.

- **Diretórios protegidos (`assets/`, `lib/ui/ads/`, `lib/domain/engine/`):** `git diff assets/ lib/ui/ads/ lib/domain/engine/ | wc -c` = **0 bytes**.
- **Dependências (`pubspec.yaml`):** inalterado (zero pacotes externos adicionados; zero imports `dart:html`, `dart:js`, `dart:ui_web`).

---

## 2. Achados de Causa Raiz e Correções Aplicadas

### P1.1 — Padronização das métricas de resultado
- **Causa raiz confirmada:** Os valores `49,04%` (tela de resultado via `.toStringAsFixed(2)`) e `49%` (Início, Histórico e Cartão via `.round()`) vinham exatamente da mesma saída `EspectroCompatibilityEngine.evaluate().primaryMatch.compatibilityPercent`. Já `61,96%` / `62,0%` (Feijó) vinham de `EspectroAtlasEngine.rankEntries` (distância quadrática limitada `effZ²` sobre tolerâncias do Atlas), e `70%` / `70,1%` no comparador vinham de `100 × (1 − RMSD)` em `StudyCatalog.compare`.
- **Implementação:** Criado [`MetricPresentation` e `MetricInfoBadge`](file:///home/zpower/Downloads/espectro/lib/ui/shared/metric_presentation.dart), padronizando formatação contínua para **1 casa decimal com vírgula pt-BR** (`49,0%`, `62,0%`, `70,1%`) e explicitando o referente (`convergência com a corrente`, `prox. personalidade`/`país`/`partido`/`período`/`obra`, `prox. exploratória`) com tooltips acessíveis por toque e teclado em:
  - [`espectro_home_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart)
  - [`espectro_result_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart)
  - [`study_comparison_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/study_comparison_screen.dart)
  - [`entity_comparison_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/entity_comparison_screen.dart)
  - [`compare_evaluations_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/compare_evaluations_screen.dart)
  - [`history_evolution_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/history/history_evolution_screen.dart)
  - [`share_card_content.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart)

### P1.2 — Comparação: dimensões duplicadas (`Economia`)
- **Causa raiz confirmada:** Havia colisão nominal exata do rótulo `'Economia'` entre o eixo bipolar (`assets/data/twelve_axes.json`, id `economia`) e a tríade composicional (`assets/data/six_triangles.json`, id `0`). Não se tratava de duplicação matemática, mas de duas dimensões distintas sem qualificação visual.
- **Implementação:** Adicionados [`StudyComparisonDimension`, `StudyMatch.similarityDetails` e `StudyMatch.differenceDetails`](file:///home/zpower/Downloads/espectro/lib/domain/models/study_models.dart) mantendo o cálculo `100 × (1 − RMSD)` intacto e exibindo na UI de [`StudyComparisonScreen`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/study_comparison_screen.dart) selos de componente (`EIXO BIPOLAR` / `TRÍADE`) junto aos rótulos qualificados **`Economia — Eixo bipolar`** (58% da distância máxima) e **`Economia — Tríade econômica`** (47% da distância máxima).

### P1.3 — Contagem e identificação da bancada parlamentar (`1.405`)
- **Causa raiz confirmada:** Os `1.405` verbetes (`1.404` indivíduos únicos de votações nominais entre `2003–2024` em `personalities_extended.json` + `gilson_marques` em `personalities.json`, sem nomes duplicados) representam **indivíduos históricos distintos com votos nominais registrados em múltiplas legislaturas**, e não o número de cadeiras em exercício hoje.
- **Implementação:** Atualizados [`atlas_models.dart`](file:///home/zpower/Downloads/espectro/lib/domain/models/atlas_models.dart), [`study_taxonomy.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_taxonomy.dart) e [`atlas_explorer_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart) para exibir **`1405 parlamentares (2003–2024)`** com `MetricInfoBadge` explicativo, chip **`Parlamentares · Voto Nominal (1405)`** (mantendo compatibilidade retroativa com rotas antigas `'Bancada / Congresso'`) e filtro temporal segmentado em **`Todos (2003–2024 · 1405)`**, **`Atuação recente (2023–2024)`** e **`Legislaturas anteriores (2003–2022)`**.

### P1.4 — Padronização de nomenclatura da profundidade `Expressa` e sincronia dinâmica
- **Implementação:** Padronizado `TestDepth.express.label` para **`Expressa`** em [`political_models.dart`](file:///home/zpower/Downloads/espectro/lib/domain/models/political_models.dart); CTA da tela inicial para **`Fazer Avaliação Expressa (3 min)`**, missão **`Mapear 12 Eixos / Expressa`** e contagem dinâmica de correntes via `catalog.data.catalog.currents.length` em [`espectro_home_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart); texto introdutório em [`espectro_intro_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_intro_screen.dart) (`Avaliação Expressa:`); banner de resultado (`AVALIAÇÃO EXPRESSA · 12 EIXOS CONCLUÍDOS`); [`web/index.html`](file:///home/zpower/Downloads/espectro/web/index.html); e colofão `${record.suite.title} · ${record.depth.label}` em [`ShareCardCanvas`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart). Os dois seletores de teste literais correspondentes foram atualizados em [`espectro_widget_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/espectro_widget_test.dart) e [`figma_layout_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/figma_layout_test.dart).

### P1.5 — Área segura, espaçamento inferior mobile e teclado virtual
- **Implementação:** Barra fixa mobile em [`EspectroScaffold`](file:///home/zpower/Downloads/espectro/lib/widgets/espectro_scaffold.dart) agora é ocultada automaticamente quando `MediaQuery.viewInsetsOf(context).bottom > 100`; itens de navegação receberam alvo mínimo `48px` e modo compacto `< 350px`. Folha inferior [`ShareableCardSheet`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/shareable_card_sheet.dart) soma `viewInsets.bottom`. Paddings inferiores de rolagem elevados para `72px` (`Home`, `Suites`, `Intro`, `Result` em todas as 4 abas, `Atlas`, `Profile`, `StudyComparison`, `EntityComparison`, `History`, `Methodology`, `CompareEvaluations`) e `44px` no cartão do quiz.

### P1.6 — Imagens/emblemas ausentes e carregamento imediato em `StudyIdentity`
- **Causa raiz confirmada:** Os `289/289` emblemas em `assets/currents/` existem e são válidos; quadros apareciam vazios antes da decodificação assíncrona porque `Image.asset` não tinha `frameBuilder` (e `Image.network` usava opacidade `0` no primeiro quadro), além de `StudyIdentityHero` omitir o avatar quando `kind != 'personality' && !hasImage` e `figma_layout_test.dart` não pré-aquecer o asset na captura de `perfil`.
- **Implementação:** Criado [`resilient_image.dart`](file:///home/zpower/Downloads/espectro/lib/ui/shared/resilient_image.dart) (`gaplessPlayback: true`, `frameBuilder` com exibição imediata do fallback antes do primeiro quadro, e `errorBuilder`), aplicado em [`study_identity.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_identity.dart), `espectro_home_screen.dart`, `espectro_result_screen.dart`, `study_profile_screen.dart`, `home_share_card_specimen.dart`, `share_card_content.dart`, `study_comparative_radar_chart.dart` e `study_ternary_chart.dart`. `StudyIdentityHero` agora exibe emblema/avatar para todas as entidades de catálogo (exceto `spectrum` e `evaluation`), e [`figma_layout_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/figma_layout_test.dart) pré-aquece `ResizeImage` do emblema em `perfil`.

### P2.1 — Teia mobile (`StudyMapScreen`): inspetor com 3 níveis e barra superior limpa
- **Implementação em [`study_map_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_map_screen.dart):** Adicionado `_MobileInspectorDetent` (`peek <= 156px`, `half`, `full`), abrindo sempre em **`peek`** ao selecionar um nó no mobile (preservando ~80% do grafo livre), com alça de arraste vertical e botão acessível (`44×44`) para alternância, modo [`StudySubjectTile.compact`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart) exibindo título, espectro, dimensões e ações (`Abrir ficha` e `12 eixos e 6 tríades`) dentro da área compacta, legenda reposicionada acima de `peek` e ocultada em `half`/`full`, respeito a `disableAnimationsOf`, e barra dedicada superior de `36px` para controles de projeção em `< 600px` eliminando a colisão sobre `AUTORITARISMO ↑`. O inspetor lateral desktop (`390px`) permaneceu inalterado.

### P2.2, P2.3 & P2.4 — Contraste WCAG 2.2 AA, foco por teclado, responsividade extrema (`320px`) e cartões sociais
- **Tema e contraste ([`lib/theme.dart`](file:///home/zpower/Downloads/espectro/lib/theme.dart)):** Atualizados tokens da paleta clara `poleRight: #9B4716`, `warning: #964705`, `success: #0E6657` (inclusive `triadPalette[1]`); adicionados anéis de foco `WidgetState.focused` (`2.0px`) e bordas selecionadas não dependentes apenas de cor em `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton` e `ChipThemeData`.
- **Contraste em cartões Obsidian (`#0B101A`):** Aplicado `traditionInk = spectrum.ink(true)` em [`ShareCardCanvas`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart) e [`HomeShareCardSpecimen`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/home_share_card_specimen.dart), unificando também a formatação pt-BR em `_ShareAxisMiniBar`.
- **Responsividade em `320px`, `768px` e escala `1.3x`/`2.0x`:** Ajustados cabeçalhos e linhas com `LayoutBuilder`/`Wrap`/`Expanded` em [`study_comparison_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/study_comparison_screen.dart), [`entity_comparison_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/compare/entity_comparison_screen.dart), [`history_evolution_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/history/history_evolution_screen.dart), [`atlas_explorer_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart), [`espectro_quiz_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_quiz_screen.dart) e [`espectro_result_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart).

---

## 3. Auditoria Programática de Contraste WCAG 2.2 AA (`>= 4,5:1`)

| Token / Espectro | Hex / Saída `ink(true)` | Fundo `canvas` (`#F3F1EC`) | Fundo `surface` (`#FAF8F3`) | Fundo `surfaceMuted` (`#E4E0D6`) | Fundo Obsidian (`#0B101A`) | Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `light.ink` | `#161B24` | 15,30:1 | 16,27:1 | 13,10:1 | — | PASS |
| `light.inkSoft` | `#3B4454` | 8,69:1 | 9,24:1 | 7,44:1 | — | PASS |
| `light.muted` | `#525B6D` | 6,05:1 | 6,43:1 | 5,18:1 | — | PASS |
| `light.accent` | `#453796` | 8,31:1 | 8,83:1 | 7,11:1 | — | PASS |
| `light.poleLeft` | `#176B78` | 5,45:1 | 5,80:1 | 4,67:1 | — | PASS |
| `light.poleRight` | `#9B4716` | 5,63:1 | 5,98:1 | 4,82:1 | — | PASS |
| `light.warning` | `#964705` | 5,81:1 | 6,18:1 | 4,98:1 | — | PASS |
| `light.success` | `#0E6657` | 6,09:1 | 6,47:1 | 5,21:1 | — | PASS |
| 8 Espectros (`ink(true)`) | `#D6373E`..`#8566A9` ajustados | — | — | — | 7,54:1 a 11,61:1 | PASS |

---

## 4. Verificações Executadas e Evidências Visuais

1. **`dart analyze lib/ test/`:** **0 erros e 0 avisos** (apenas 1 info pré-existente de membro obsoleto `cacheExtent` em `espectro_home_screen.dart:402`).
2. **Suíte completa `flutter test --reporter=compact`:** **293 testes aprovados, 1 teste pulado pré-existente** (`test/domain/user_vector_dossier_test.dart:244`, condicional à existência de `/tmp/espectro-raw-quick-session.json`), **0 falhas**. Inclui [`audit_matrix_verification_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/audit_matrix_verification_test.dart) cobrindo `1440×900`, `1024×768`, `768×1024`, `390×844` e `320×568` × Claro/Escuro × 13 telas + `ShareCardCanvas` 1:1/9:16 + `320px` com escala `1.3x` e `disableAnimations: true`.
3. **Build Web (`flutter build web --no-wasm-dry-run`):** compilado sem erros (`✓ Built build/web`, 32,1s).
4. **Sloplint (`sloplint.mjs build/web/index.html`):** `sloplint: clean. 0 FAIL, 0 REFLEX, 0 WARN across 1 file(s).`
5. **Evidências visuais (BEFORE vs. AFTER):**
   - **BEFORE (23 capturas):** [docs/audits/screenshots/before](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/before)
   - **AFTER (28 capturas, incluindo 320px, 768px, 1024px e cartões 1:1 / 9:16):** [docs/audits/screenshots/after](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/after)
   - Inspeção direta realizada nas capturas AFTER principais (`home-1440-light.png`, `home-1024-dark.png`, `atlas-768-light.png`, `home-390-dark.png`, `home-320-light.png`, `atlas-1440-dark.png`, `comparacao-1440-dark.png`, `perfil-corrente-1440-light.png`, `perfil-corrente-390-light.png`, `teia-390-dark.png`, `resultado-390-dark.png`, `profundidade-390-dark.png`, `share-card-1x1.png`, `share-card-9x16.png`).
