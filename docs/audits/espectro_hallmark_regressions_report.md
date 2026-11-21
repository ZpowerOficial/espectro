# Relatório de Regressões Artísticas (Ciclos Hallmark) e Recuperação Visual do Espectro

**Branch:** `visual/art-direction-v2`  
**Escopo:** Auditoria comparativa (Pré-Hallmark × Regressões Hallmark × Versão Recuperada), recuperação da identidade cromática e icônica dos 12 eixos e 6 tríades, alívio de densidade, revisão da Teia e validação em Testes Flutter, Chromium WebGL2 e Obscura.

---

## 1. Linha do Tempo e Metodologia de Comparação

A investigação comparou três estados reais do repositório:

1. **Pré-Hallmark (referências extraídas do histórico Git):** commits `59f373a`, `22e2d06` e `1ce1059`, cujos goldens originais foram restaurados em `docs/audits/screenshots/pre_hallmark/`.
2. **Pós-ciclos Hallmark (regressão reportada):** capturas em `docs/audits/screenshots/after/` (e capturas anteriores de auditoria).
3. **Versão Recuperada (`visual/art-direction-v2` atual):** goldens atualizados em `docs/audits/screenshots/recovered/goldens/`, renderização real CanvasKit/WebGL2 em Chromium (`docs/audits/screenshots/recovered/webgl/`) e portal HTML/SEO no Obscura (`docs/audits/screenshots/recovered/obscura/`).

### Evidências Visuais Comparativas

- **Home (Pré-Hallmark vs. Regressão Hallmark vs. Recuperada):**
  - Pré-Hallmark: `docs/audits/screenshots/pre_hallmark/59f373a_home-1440-dark.png`
  - Regressão Hallmark: `docs/audits/screenshots/after/home-1440-dark.png` e `docs/audits/screenshots/after/home-1440-light.png`
  - Recuperada WebGL2 (Light / Dark / Carrossel / 12 Eixos / Mobile):
    - `docs/audits/screenshots/recovered/webgl/home-1440-light-top.png`
    - `docs/audits/screenshots/recovered/webgl/home-1440-dark-top.png`
    - `docs/audits/screenshots/recovered/webgl/home-1440-dark-carousel-1.png`
    - `docs/audits/screenshots/recovered/webgl/home-1440-dark-carousel-story.png`
    - `docs/audits/screenshots/recovered/webgl/home-1440-dark-12axes.png`
    - `docs/audits/screenshots/recovered/webgl/home-390-dark-top.png`
    - `docs/audits/screenshots/recovered/webgl/home-390-dark-carousel.png`
- **Comparador & Matriz de 12 Eixos:**
  - Pré-Hallmark: `docs/audits/screenshots/pre_hallmark/59f373a_comparacao-1440-dark.png`
  - Regressão Hallmark: `docs/audits/screenshots/after/comparacao-1440-dark.png`
  - Recuperada WebGL2 (Light & Dark): `docs/audits/screenshots/recovered/webgl/compare-1440-light-12axes.png`, `docs/audits/screenshots/recovered/webgl/compare-1440-dark-12axes.png`, `docs/audits/screenshots/recovered/goldens/comparacao-1440-light.png`
- **Teia das 289 Correntes:**
  - Pré-Hallmark: `docs/audits/screenshots/pre_hallmark/59f373a_teia-1440-dark.png`
  - Regressão Hallmark: `docs/audits/screenshots/after/teia-1440-dark.png`
  - Recuperada WebGL2: `docs/audits/screenshots/recovered/webgl/teia-1440-light.png`, `docs/audits/screenshots/recovered/webgl/teia-1440-dark-zoomed.png`, `docs/audits/screenshots/recovered/webgl/teia-390-dark.png`
- **Resultado & Perfis:**
  - Recuperada WebGL2 & Goldens: `docs/audits/screenshots/recovered/webgl/result-overview-1440-light.png`, `docs/audits/screenshots/recovered/webgl/result-12axes-1440-light.png`, `docs/audits/screenshots/recovered/goldens/resultado-1440-dark.png`, `docs/audits/screenshots/recovered/goldens/resultado-1440-light.png`
- **Portal HTML/SEO no Obscura:**
  - `docs/audits/screenshots/recovered/obscura/portal-home-1440.png` e `docs/audits/screenshots/recovered/obscura/marx-seo-1440.png`

---

## 2. Regressões Artísticas Diagnosticadas nos Ciclos Hallmark

A inspeção visual das capturas `59f373a_*` / `22e2d06_*` contra `docs/audits/screenshots/after/*` revelou seis regressões centrais:

1. **Paleta roxa genérica ("AI slop") e halos/brilhos artificiais:** substituição da sobriedade cartográfica por acentos roxos/lavanda (`#453796`, `#9D90FA`, `#1F1D3B`, `#8B5CF6`, `#6366F1`, `#A48BFA`) em botões principais, bordas, ícones, água-marcas (`ObservatoryOrbWatermark`), sombras brilhantes (`BoxShadow` difusos) e halos com blur nos nós da Teia e gráficos ternários.
2. **Homogeneização cromática dos 12 eixos:** perda das identidades semânticas individuais de cada dimensão (`twelve_axes.json`) em favor de barras e chips monocromáticos na Home (`_AxisInstrumentTile`), nos vértices do radar multidimensional, nos badges de distinção/raridade do Resultado (`Traço raro`, `_DistinctionCard`), nas tags do Quiz e nos cartões compartilháveis.
3. **Adensamento e perda de hierarquia na Home:** o Hero (`_ObservatoryCoverHero`) comprimiu simultaneamente manchete, CTAs, miniatura do `_HeroInstantDilemmaGame`, miniatura interativa da Teia e uma terceira miniatura de cartão compartilhável lado a lado; além disso, `_LatestEvaluationBentoCard` embutia outro mini cartão dentro de outro cartão ("card-in-card"), enquanto a prévia principal colocava um cartão pequeno espremido ao lado de um bloco longo de texto explicativo (`subjectDetails`).
4. **Achatamento monolítico da matriz de comparação dos 12 eixos:** a conversão dos cartões individuais espaçados em uma lista densa separada por divisores finos reduziu a legibilidade individual por eixo e uniformizou as dimensões bipolares e tríades na leitura visual.
5. **Esvaziamento de contexto na Teia sob seleção:** nós não vizinhos perdiam leitura (`alpha: 0.22`) e os rótulos dos territórios desapareciam sob seleção, enquanto linhas e halo pulsante (`glowPaint` / `Breathing halo`) introduziam ruído luminoso.
6. **Fragmentação entre Eixos e Tríades:** nos locais onde cores eram usadas apenas de maneira decorativa, faltavam marcadores não cromáticos consistentes que distinguissem eixos bipolares (`1..12` com ícones próprios) das 6 tríades ternárias (`△` + ícones próprios).

---

## 3. Recuperação Implementada e Sistema Semântico Unificado

### 3.1 Paleta Cartográfica & Contraste WCAG 2.2 AA
- **Tema Claro — Papel Velino & Pinho Cartográfico (`lib/theme.dart`):** fundos minerais em velino (`#F0EDE6` canvas / `#FAF8F4` surface / `#E5E0D6` surfaceMuted) e acento principal em Pinho Cartográfico (`#0E5A4F`), com sombras sutis apenas no modo claro e zero brilho colorido em superfícies escuras.
- **Tema Escuro — Ardósia, Jade & Latão (`lib/theme.dart`):** superfície ardósia profunda (`#0A0F14` canvas / `#111820` surface / `#18222C` surfaceMuted), acento Jade (`#34C3A6`) e destaque primário em Latão quente (`#E5A448`) nos CTAs principais e ações de destaque.
- **Remoção sistemática do roxo genérico:** varredura confirmando `0` ocorrências residuais em `lib/` (`PURPLE_EXIT=1`) e substituição de `--iris`/`--accent: #A48BFA` por `#34C3A6` em `web/index.html`, `web/privacidade.html` e `tool/seo/generate_programmatic_seo.py` (com páginas SEO regeneradas).

### 3.2 Sistema Unificado dos 12 Eixos e 6 Tríades (`lib/ui/charts/axis_colors.dart`)
- Mantidos exatamente os **12 pares cromáticos canônicos** espelhados de `assets/data/twelve_axes.json`.
- Adicionados:
  - `AxisColors.icons`: 12 ícones geométricos/temáticos distintos (um por eixo, ex.: `Estrutura` -> `account_balance_outlined`, `Poder` -> `shield_outlined`, `Economia` -> `storefront_outlined`).
  - `AxisColors.triadIcons`: 6 ícones distintos para tríades + prefixo `△` / etiqueta `△ Tríade`.
  - `AxisColors.readableInk(color, isDark: ..., background: ...)`: ajuste estrito apenas da luminosidade HSL preservando o matiz semântico original até garantir razão de contraste WCAG 2.2 AA (`>= 4.6:1`) em papel velino, ardósia e obsidiana dos cartões compartilháveis.
- Aplicado de forma consistente em:
  - **Home (`_AxisInstrumentTile`, `_HeroInstantDilemmaGame`, `_LatestEvaluationBentoCard`, `_SpotlightCardState`)**: os 12 ladrilhos voltaram a exibir ícone individual, polos coloridos com contraste AA e barra dupla semântica de 5 px com recorte central limpo (`CrossAxisAlignment.stretch`).
  - **Radar Multidimensional (`multidimensional_radar_chart.dart`) e Barras Divergentes (`diverging_axis_bar.dart`)**: vértices/ticks radiais e badges usam a cor semântica e o ícone do respectivo eixo, removendo `MaskFilter.blur`.
  - **Resultados (`espectro_result_screen.dart`), Quiz (`espectro_quiz_screen.dart`), Perfil (`study_profile_screen.dart`) e Cartões Compartilháveis (`share_card_content.dart`, `home_share_card_specimen.dart`)**: tags de dimensão, chips de `Traço raro`, distinções e barras dos cartões passam a refletir cada eixo real e diferenciar tríades (`△`).

### 3.3 Avaliação Comparativa da Matriz de 12 Eixos (Comparador)

| Aspecto | Pré-Hallmark (`59f373a`) | Regressão Hallmark (`after/`) | Recuperada (`visual/art-direction-v2`) |
| --- | --- | --- | --- |
| **Estrutura dos itens** | Cartões individuais com boa respiração, mas pouca codificação semântica por eixo | Bloco monolítico achatado com divisores finos, comprimindo a leitura comparativa | **12 cartões individuais espaçados e emoldurados** (`margin bottom: 14`, `radius: 14`), separação clara entre dimensões |
| **Distinção Eixo vs. Tríade** | Texto simples (`Economia` ambíguo pré-P1.2) | Distinção textual P1.2 presente, mas chips visualmente homogêneos | **P1.2 preservado integralmente** (`Economia — Eixo bipolar` vs. `Economia — Tríade econômica`) + chips com ícone e cor próprios (`EIXO BIPOLAR` / `TRÍADE`) |
| **Leitura em Escala e Contraste** | Cores fixas nem sempre normalizadas para AA no claro | Uniformização cinza/roxa | **Cada eixo exibe cor dupla canônica + ícone único + `readableInk` AA** tanto em tema claro quanto escuro |

### 3.4 Home Editorial & Carrossel Gigante de Cartão Compartilhável
- **Hero limpo (`_ObservatoryCoverHero`):** apenas título, subtítulo editorial, CTAs claros (`Fazer Avaliação Expressa (3 min)` e `Explorar o Atlas`) e linha sintética à esquerda; à direita, uma **Teia interativa ampliada** (`368 px` no desktop, `280 px` no mobile, com expansão segura em texto 2x). Removidos o mini cartão espremido ao lado da Teia e o dilema comprimido dentro do Hero.
- **Carrossel Gigante de 1 Cartão por Vez (`_HeroLiveSpectrumShowcase`):** destaca **apenas 1 cartão grande (`maxWidth: 520 px` Post 1:1 / `400 px` Story 9:16)** centralizado por vez, sem textão explicativo lateral. Cicla por 4 exemplares (`Hannah Arendt`, `Karl Marx`, `Murray Rothbard`, `John Maynard Keynes`) via `AnimatedSwitcher` (slide horizontal + fade, reduzido quando `disableAnimations` está ativo), alternância compacta `Post 1:1` / `Story 9:16`, setas anterior/próximo e botão pausa/play com alvo mínimo acessível (`>= 44 px`), 4 indicadores por ponto com pausa em hover/foco e timer único cancelado em `dispose()`.
- **Dilema Relâmpago (`_HeroInstantDilemmaGame`):** promovido para bloco calmo próprio (`SectionCard(padding: EdgeInsets.all(24))`) com ícone de eixo + `readableInk`, preservando todo o fluxo de 1 toque para a Avaliação Expressa.

### 3.5 Revisões da Teia (`study_constellation.dart`, `teia_cartographic_layer.dart`, `teia_preview_panel.dart`, `study_map_screen.dart`)
- Substituição de `glowPaint` (5 px com blur) e halos pulsantes (`Breathing halo`) por **anéis nítidos de contorno** (`1.2 px` / `1.9 px` nas arestas selecionadas) com borda no tom de fundo para separação dos nós.
- Elevação da legibilidade de nós não vizinhos durante seleção (`alpha: 0.44` escuro / `0.40` claro, raio `3.6`) e preservação dos **rótulos de territórios** com opacidade sutil (`0.42` / `0.45`) e preenchimentos/bordas mais íntegros.
- Preservação de todas as coordenadas Nolan, detents móveis e controles simultâneos (`1` a `4` Teias).

---

## 4. Verificação, QA Real (Chromium WebGL2 & Obscura) e Invariantes

### 4.1 Invariantes Protegidos e Correções P1/P2
- **Arquivos protegidos intocados:** `git diff assets/ lib/ui/ads/ lib/domain/engine/ pubspec.yaml | wc -c` = **`0`** bytes modificados em motores matemáticos, dados/pesos canônicos, anúncios e dependências.
- **Auditoria P1/P2 preservada 100%:** verificada por `test/ui/audit_matrix_verification_test.dart` (padronização de métricas com `MetricPresentation`, distinção `Economia — Eixo bipolar` vs. `Economia — Tríade econômica`, `1405 parlamentares (2003–2024)`, rótulo `'Expressa'`, contraste WCAG AA `>= 4.5:1`, e 0 overflows em 5 viewports × 2 temas × 13 telas + `320px @ 1.3x` + `390px @ 2.0x`).

### 4.2 Análise Estática & Suíte de Testes
- `dart analyze lib/ test/`: **`No issues found!`** (0 erros, 0 avisos).
- `flutter test --reporter=compact` (executado após as últimas edições e após atualização seletiva de goldens em `test/ui/figma_layout_test.dart`):
  - **293 testes aprovados (`+293 ~1`)**, 1 teste pré-existente ignorado (`~1`), **0 falhas**.
  - `test/ui/espectro_widget_test.dart` e `test/ui/design_portability_regression_test.dart` atualizados apenas para acompanhar a nova posição do Dilema abaixo do carrossel e o novo controle do Carrossel Gigante de 1 cartão (`Próximo exemplar`, ponto indicador e `Story 9:16`).

### 4.3 Build Web, Chromium WebGL2 e Obscura
- `flutter build web --no-wasm-dry-run`: compilado com sucesso em `29,9s`; gerador SEO (`tool/seo/generate_programmatic_seo.py`) produziu **1502 páginas estáticas + 8 páginas de espectro + `catalogo.html` + `llms.txt` + `sitemap.xml` (1513 URLs)**.
- **Chromium WebGL2 (`chromium-1243`, CanvasKit):**
  - `webgl2Verified: true`, **`webglConsoleErrors: 0`**, **`webglPageErrors: 0`**.
  - 19 capturas reais Desktop (`1440×900`) e Mobile (`390×844`) validadas visualmente (`Home`, `Carrossel Arendt/Marx/Story`, `12 Eixos cromáticos`, `Atlas`, `Teia completa com zoom`, `Comparador claro/escuro`, `Quiz` e `Resultado` preliminar em 12 eixos).
  - Durante a inspeção visual das capturas WebGL2 iniciais, foram identificados e corrigidos imediatamente: (a) pílulas `Post 1:1`/`Story 9:16` esticadas horizontalmente por `Alignment.center` dentro de `Wrap`, e (b) barras duplas de 5 px invisíveis nos ladrilhos dos 12 eixos por ausência de `CrossAxisAlignment.stretch` em `Row`s com `ColoredBox` (corrigido também em `entity_comparison_screen.dart` e `share_card_content.dart`). Todas as correções foram validadas em nova compilação e novas capturas.
- **Obscura (`/home/zpower/Downloads/obscura-x86_64-linux-stealth/obscura`):**
  - Testado nativamente sem shims ou contornos (`recovered_qa_runner.mjs`): confirmado `webglSupported: false`, `webgl2Supported: false` no ambiente headless do Obscura; portanto o App Flutter WebGL2 não é o contexto nativo desse motor, enquanto o **portal HTML/SEO semântico** (`#seo-semantic-shell` visível em `/`, `/catalogo.html`, `/p/personality-karl_marx.html`) renderizou com `0` quebras horizontais (`overflowX: false`), imagens íntegras e acento Jade (`#34C3A6`) coerente com a identidade recuperada.

---

**Estado de entrega:** todas as alterações permanecem exclusivamente na branch local `visual/art-direction-v2`, **sem merge na `main` e sem deploy no Firebase**, aguardando revisão visual final.
