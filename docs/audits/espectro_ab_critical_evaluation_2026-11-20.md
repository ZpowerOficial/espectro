# ESPECTRO — Avaliação Crítica Final A/B de Direção Artística, Dataviz, AdSense & Exportação PNG

**Data:** 20 de novembro de 2026  
**Branch:** `visual/art-direction-v2` (sem merge em `main` e sem deploy em produção)  
**Escopo:** Resposta crítica às 7 questões finais com comparações visuais A/B pixel-alinhadas (mesmos dados, resolução, tema e posição de rolagem), correções objetivas verificadas em Flutter + Chromium WebGL2 e forense DOM de AdSense mobile.  
**Invariantes preservados:** Zero alterações em `assets/`, `lib/ui/ads/`, `lib/domain/engine/` e `pubspec.yaml` (`git diff assets/ lib/ui/ads/ lib/domain/engine/ pubspec.yaml | wc -c` = `0`).

---

## Sumário Executivo

| Questão do Usuário | Status | Resultado / Decisão |
| :--- | :--- | :--- |
| **1. Roxo/Íris vs Jade/Pinho/Latão** | **Aguarda aprovação A/B** | A remoção *total* do roxo foi reação excessiva. Roxo em gradiente neon/glass é *slop* (Gate `2a`); **Íris Cartográfico sólido `#44378F` / `#9A92F0` + Latão `#E5A448`** passa em WCAG 2.2 AA/AAA e ancora no mascote sem perder seriedade editorial. Recomenda-se **B** (ou seletivo por perfil). |
| **2. 12 Eixos: 24 cores (dual-pole) vs 12 cores-âncora** | **Aguarda aprovação A/B** | **A (dual-pole, 24 cores)** diferencia polos opostos pela cor, mas dispersa atenção em 24 matizes simultâneos; **B (primary-anchor, 12 cores)** reduz pela metade o ruído cromático usando posição esquerda/direita + trilha neutra para polaridade. Recomenda-se **B**. |
| **3. Radar multidimensional mais expressivo** | **Implementado e verificado** | Ampliado de `248 px` para `292 px` (Visão Geral) e **`372 px` lado a lado** com o novo painel **`LEITURA DO RADAR`** em desktop (`1440×900` em `ResponsiveContentFrame(maxWidth: 920)`), com **faixa real `±1 SE`** (`PathFillType.evenOdd`), ticks `-1 / 0 / +1` e afastamento direcional de rótulos horizontais. |
| **4. Teia: hierarquia e colisão em zoom/clusters** | **Implementado e verificado** | Corrigida a causa raiz em [`study_constellation.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/study_constellation.dart): `_tier1Anchors` usava hífens em vez de underscores (`0/289` IDs usam hífen), falhando ~18 âncoras e concentrando 25 rótulos na esquerda vermelha. Agora há **27 âncoras reais nos 8 espectros**, round-robin espacial no zoom, 8 direções + líderes curtos, exclusão do HUD/legenda e trava contra corte nas bordas. |
| **5. Mobile 390×844 e anúncios (AdSense)** | **Auditado (DOM real) · Aguarda decisão** | Em WebGL2 `390×844`, a barra atual (`height: 50`, container ~`63 px`) com `<ins data-ad-status="unfilled">` exibe um **retângulo cinza vazio colado a `0 px`** acima da `NavigationBar` (`127 px` = **`15,0%`** da altura), ofuscando o texto `"AD · Espectro..."`. Recomendação: **recolher slots `unfilled` a `0 px`**, remover fallback auto-promocional `"AD"` e migrar para **unidade inline entre seções (`≥ 24 px` da navegação)** ou **Anchor oficial do AdSense**. |
| **6. Expressa: não afirmar "6 tríades" não observadas** | **Implementado e verificado** | Banner preliminar, seção 07 e **`ShareCardCanvas`** (subtítulo superior `'12/12 eixos bipolares observados'` e selo inferior `'12 eixos bipolares'`) agora espelham estritamente dimensões observadas, com teste de regressão dedicado. |
| **7. Exportação real PNG 1:1 e 9:16 ponta a ponta** | **Validado Flutter + Chromium WebGL2** | Fluxo completo (`Expressa 24/24 -> Resultado -> ShareableCardSheet -> Salvar imagem`) baixou PNGs reais no Chromium WebGL2 (`espectro-post.png` **`1080×1080`**, `184.746 B`; `espectro-story.png` **`1080×1920`**, `271.070 B`) com **0 erros de console/página**. |

---

## Avaliação Crítica Item a Item

### Item 1 — Paleta: A remoção total do roxo era realmente necessária?

**Crítica sob Hallmark (sem dogmatismo):**
O Hallmark **não proíbe a família índigo/roxo**. O Gate `2a` pune especificamente *"purple-to-blue / purple-to-pink / cyan-on-dark gradients"*, e o Gate `74` alerta contra *swatches padrão* de Tailwind (`indigo-500`, `violet-600`, `slate-900`) — ou seja, o clichê de SaaS com card translúcido, brilho neon (`glow`) e gradiente violeta-ciano. Por outro lado, o próprio Gate `65` adverte contra o reflexo automático de trocar tudo para *"papel creme quente (`L 90+`) + acento terroso/pinho"* sempre que um aplicativo quer parecer sério. No ciclo anterior, o Espectro trocou todo índigo por **Pinho/Jade/Latão**, o que limpou o *glow*, mas desconectou a interface do próprio **mascote editorial do Espectro** (que carrega espectro cromático completo sobre ardósia escura).

#### Comparação A vs B (mesmos dados, resolução, scroll `y=0`, contraste WCAG 2.2 AA/AAA)

- **Variante A (Ativa em [`theme.dart`](file:///home/zpower/Downloads/espectro/lib/theme.dart)) — Papel Velino + Pinho/Jade + Latão:**
  - Claro: `canvas #F0EDE6`, `surface #FAF8F4`, `ink #13191B` (**16,74:1**), `muted #4F5B5F` sobre `surfaceMuted` (**5,33:1**), `accent #0E5A4F` (**7,63:1**).
  - Escuro: `canvas #0A0F14`, `surface #111820`, `ink #F2F4F2` (**16,16:1**), `muted #8C9AA3` sobre `surfaceMuted` (**5,57:1**), `accent #34C3A6` (**8,09:1**; texto CTA `#071614` = **8,38:1**).
- **Variante B (Proposta isolada no harness de teste — Íris Cartográfico Refinado + Latão):**
  - Misturada em OKLCH fora dos padrões Tailwind, ancorada no espectro do mascote, **zero gradientes roxo-ciano**, **zero glow**, mantendo **Latão `#E5A448` nos CTAs primários escuros** para que botões escuros nunca virem roxo pastel neon:
  - Claro: `canvas #F2F0EB`, `surface #FAF9F6`, `ink #151822` (**16,82:1**), `muted #545A6E` sobre `surfaceMuted #E6E3DC` (**5,35:1**), `accent #44378F` (**9,11:1** sobre `surface`, **8,42:1** sobre `canvas`, texto branco = **9,11:1**).
  - Escuro: `canvas #0B0F16`, `surface #121822`, `ink #F2F4F8` (**16,17:1**), `muted #8C97AE` sobre `surfaceMuted #192130` (**5,50:1**), `accent #9A92F0` (**6,57:1** sobre `surface`, **5,95:1** sobre `surfaceMuted`), CTA primário escuro `#E5A448` + tinta `#140D03` (**8,94:1**).

| Tela | Variante A — Jade / Pinho / Latão | Variante B — Íris Cartográfico Refinado & Latão |
| :--- | :--- | :--- |
| Home Desktop Dark (`1440×900`) | [A_jade_home_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_home_1440-dark.png) | [B_refined_iris_home_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_home_1440-dark.png) |
| Home Desktop Light (`1440×900`) | [A_jade_home_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_home_1440-light.png) | [B_refined_iris_home_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_home_1440-light.png) |
| Home Mobile Dark (`390×844`) | [A_jade_home_390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_home_390-dark.png) | [B_refined_iris_home_390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_home_390-dark.png) |
| Resultado Overview Light (`1440×900`) | [A_jade_result_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_result_1440-light.png) | [B_refined_iris_result_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_result_1440-light.png) |
| Resultado Overview Dark (`1440×900`) | [A_jade_result_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_result_1440-dark.png) | [B_refined_iris_result_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_result_1440-dark.png) |
| Comparador Light (`1440×900`) | [A_jade_compare_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_compare_1440-light.png) | [B_refined_iris_compare_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_compare_1440-light.png) |
| Comparador Dark (`1440×900`) | [A_jade_compare_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_compare_1440-dark.png) | [B_refined_iris_compare_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_compare_1440-dark.png) |
| Teia Dark (`1440×900`) | [A_jade_teia_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_teia_1440-dark.png) | [B_refined_iris_teia_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_teia_1440-dark.png) |
| Teia Light (`1440×900`) | [A_jade_teia_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/A_jade_teia_1440-light.png) | [B_refined_iris_teia_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_1_palette/B_refined_iris_teia_1440-light.png) |

**Justificativa e Recomendação:**
- **Por que B se destaca no tema claro:** O índigo-íris `#44378F` possui **9,11:1** de contraste (superior ao `#0E5A4F` com **7,63:1**) e separa claramente o cromo institucional (`Visão geral`, `Compartilhar resultado`, selos de UI) das cores **políticas/dataviz** (Ecologismo/Centro-Esquerda verde-jade, Libertários latão/ouro, Direita azul). No tema escuro, o pair **Íris `#9A92F0` para foco/navegação + Latão `#E5A448` para CTA principal** evita tanto a homogeneidade verde quanto o erro clássico de botão neon roxo de AI.
- **Prós da A:** Já está alinhada ao papel quente editorial e evita qualquer associação superficial ao clichê de roxo. **Recomendação:** **Aprovar B (Íris Cartográfico Refinado & Latão)** se quiser personalidade autoral conectada ao mascote, preservando obrigatoriamente a regra *zero glow / zero gradientes violeta-ciano*. A paleta padrão em [`theme.dart`](file:///home/zpower/Downloads/espectro/lib/theme.dart) permanece **inalterada** até sua escolha.

---

### Item 2 — Codificação dos 12 Eixos: 24 cores (dual-pole) vs 12 cores-âncora (primary-anchor)

Infraestrutura implementada de forma não intrusiva via [`AxisColorStrategy`](file:///home/zpower/Downloads/espectro/lib/ui/charts/axis_colors.dart#L11) + [`AxisColorStrategyScope`](file:///home/zpower/Downloads/espectro/lib/ui/charts/axis_colors.dart#L15) (padrão ativo mantido em `dualPole`).

- **Variante A (`dualPole`, padrão atual — 24 cores):** Cada eixo tem um par de cores para polo esquerdo e polo direito.
  - *Força:* Identidade direcional dupla ("azul vs laranja" em Estrutura; "verde vs magenta" em Controle).
  - *Fraqueza (carga cognitiva):* Em uma página com os 12 eixos empilhados (Home, Resultado `Eixos (12)`, Comparador), o olho enfrenta **24 matizes concorrentes ao mesmo tempo**, e nos cards do Comparador (ex.: *Poder* em [`A_dual_pole_compare-12axes_1440-light.png`](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_compare-12axes_1440-light.png)) dois polos com saturação similar disputam atenção mesmo quando ambos os perfis pendem só para um lado.
- **Variante B (`primaryAnchor` — 12 cores semânticas, 1 por eixo):** Um matiz canônico identifica o **tema/eixo** (ex.: `Estrutura = #2F6DC0`, `Economia = #D43A28`, `Moral = #D23E84`); o polo dominante ou metade ativa recebe o matiz + selo cheio, enquanto o polo oposto usa trilha neutra estruturada (`p.line`) + rótulo suave (`p.inkSoft`). A distinção de polos nunca depende da cor: continua garantida por **esquerda vs direita**, **alinhamento espacial**, **marcador `•` no polo vencedor** e **percentual explícito**.

| Contexto (mesma posição exata de scroll) | Variante A — Dual-Pole (24 cores) | Variante B — Primary Anchor (12 cores) |
| :--- | :--- | :--- |
| Home `Os 12 Eixos` Dark | [A_dual_pole_home-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_home-12axes_1440-dark.png) | [B_primary_anchor_home-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_home-12axes_1440-dark.png) |
| Home `Os 12 Eixos` Light | [A_dual_pole_home-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_home-12axes_1440-light.png) | [B_primary_anchor_home-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_home-12axes_1440-light.png) |
| Resultado `Detalhamento Eixo a Eixo` Light | [A_dual_pole_result-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_result-12axes_1440-light.png) | [B_primary_anchor_result-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_result-12axes_1440-light.png) |
| Resultado `Detalhamento Eixo a Eixo` Dark | [A_dual_pole_result-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_result-12axes_1440-dark.png) | [B_primary_anchor_result-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_result-12axes_1440-dark.png) |
| Comparador `Mesmos eixos, mesma régua` Light | [A_dual_pole_compare-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_compare-12axes_1440-light.png) | [B_primary_anchor_compare-12axes_1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_compare-12axes_1440-light.png) |
| Comparador `Mesmos eixos, mesma régua` Dark | [A_dual_pole_compare-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/A_dual_pole_compare-12axes_1440-dark.png) | [B_primary_anchor_compare-12axes_1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_2_axes/B_primary_anchor_compare-12axes_1440-dark.png) |

**Recomendação:** **Migrar o padrão para B (`primaryAnchor`, 12 cores-âncora)** em [`axis_colors.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/axis_colors.dart). Em todas as 6 comparações acima, **B** dá uma identidade cromática inequívoca para cada uma das 12 dimensões (*Economia* é sempre vermelha, *Estrutura* sempre azul, *Representação* sempre esmeralda), corta metade da fragmentação visual na tela e destaca imediatamente *para que lado a barra inclinou* contra o fundo neutro. Aguardando sua confirmação para trocar o default de `AxisColorStrategy.dualPole` para `primaryAnchor`.

---

### Item 3 — Radar Multidimensional Expressivo (`lib/ui/charts/multidimensional_radar_chart.dart` & `espectro_result_screen.dart`)

**Diagnóstico encontrado no Antes (A):**
1. Na aba `Eixos (12)`, `ResponsiveContentFrame` limitava a largura útil a ~`684 px` dentro de `1440×900`, deixando o radar centralizado com `248 px` em meio a uma caixa enorme vazia.
2. O texto de auxílio declarava *"a área hachurada expressa a dispersão estimada pelo modelo (SE)"*, mas [`_RadarPainter`](file:///home/zpower/Downloads/espectro/lib/ui/charts/multidimensional_radar_chart.dart#L54) **não desenhava nenhuma faixa de incerteza `standardError`**, além de rótulos horizontais (`Imigração`, `Religião`) tangenciarem pontos externos no mobile.

**Solução implementada e verificada (B):**
- **`_buildAxesTab`** em [`espectro_result_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L4232) expandido para `ResponsiveContentFrame(maxWidth: 920)` (mesmo ritmo de `Visão Completa`): em desktop exibe radar **`372 px` à esquerda** e o novo painel **`LEITURA DO RADAR`** ([`_buildAxesRadarReadingRail`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L4426)) à direita, com legenda geométrica, os **3 polos mais intensos** com `±1 SE` em pontos percentuais (`(standardError * 50).round() pp`) e o eixo de **maior dispersão** (ex.: *Representação `±28 pp · SE 0.55`*). Em `Visão Completa`, `Panorama dimensional` cresceu de `248 -> 292 px` (desktop) e `220 -> 272 px` (mobile).
- **Faixa real anelar `±1 SE`** ([`_drawUncertaintyBand`](file:///home/zpower/Downloads/espectro/lib/ui/charts/multidimensional_radar_chart.dart#L223)) desenhada via `PathFillType.evenOdd` diretamente de `axis.standardError` sem alterar cálculos; marcações `−1`, `0`, `+1` ao longo do setor superior; e afastamento direcional `(tp.width / 2) * |dx| + (tp.height / 2) * |dy|` garantindo zero sobreposição entre rótulos e pontos em `390×844`.

| Contexto | Antes (A) | Depois (B) | WebGL2 ao Vivo |
| :--- | :--- | :--- | :--- |
| Aba Eixos Light `1440×900` | [A_result-axes-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/A_result-axes-1440-light.png) | [B_result-axes-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/B_result-axes-1440-light.png) | [webgl-result-radar-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/webgl-result-radar-1440-light.png) |
| Aba Eixos Dark `1440×900` | [A_result-axes-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/A_result-axes-1440-dark.png) | [B_result-axes-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/B_result-axes-1440-dark.png) | — |
| Aba Eixos Mobile Dark `390×844` | [A_result-axes-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/A_result-axes-390-dark.png) | [B_result-axes-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/B_result-axes-390-dark.png) | — |
| Panorama Overview `1440×900` | [A_result-overview-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/A_result-overview-1440-light.png) | [B_result-overview-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_3_radar/B_result-overview-1440-light.png) | — |

---

### Item 4 — Teia: Hierarquia e Colisão em Zoom, Seleção e Clusters Densos (`study_constellation.dart`)

**Causa raiz encontrada no Antes (A):**
Em `assets/data/ideological_currents.json` (289 correntes), **0 IDs usam hífen** e **206 usam underscore**. Porém `_tier1Anchors` em [`study_constellation.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/study_constellation.dart#L1217) listava chaves com hífen (`current:social-democracia`, `current:liberalismo-classico`, etc.), fazendo ~18 âncoras falharem silenciosamente. Combinado à iteração linear em ordem de catálogo (que começa por `radical_left`), ampliar `2.2×` lotava o cluster vermelho da esquerda (`Juche`, `Blanquismo`, `Hoxhaísmo` em `A_teia-zoom22-dense-1440-dark.png`) enquanto apagava cânones do Centro, Direita e Libertários.

**Solução implementada e verificada (B):**
- **`_tier1Anchors` com 27 IDs canônicos verificados com underscore** nos 8 espectros ([`study_constellation.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/study_constellation.dart#L1217-L1245)).
- **Alocador espacial em 4 prioridades**: (1) selecionado/hover com traço líder curto (`leader tick`) quando deslocado; (2) vizinhos imediatos sem sobrepor pontos ativos; (3) âncoras históricas Tier-1 ordenadas por proximidade ao centro visível; (4) distribuição **round-robin equilibrada por espectro** no zoom (`>= 1.2×`).
- **Zonas seguras de HUD e viewport** ([`safeScreenSceneBounds`](file:///home/zpower/Downloads/espectro/lib/ui/charts/study_constellation.dart#L1513-L1520)): nenhuma etiqueta colide com legenda `ESPECTROS`, selos cardinais (`ESQUERDA`/`DIREITA`/`AUTORITARISMO`/`ANARQUISMO`), barra de controle à direita nem corta nas margens superior/lateral.

| Cenário Teia | Antes (A) | Depois (B) | WebGL2 ao Vivo |
| :--- | :--- | :--- | :--- |
| Busca `"liberalismo"` Zoom `1.6×` Dark | [A_teia-zoom16-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/A_teia-zoom16-1440-dark.png) | [B_teia-zoom16-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/B_teia-zoom16-1440-dark.png) | [webgl-teia-zoomed-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/webgl-teia-zoomed-1440-dark.png) |
| Busca `"liberalismo"` Zoom `1.6×` Light | [A_teia-zoom16-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/A_teia-zoom16-1440-light.png) | [B_teia-zoom16-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/B_teia-zoom16-1440-light.png) | — |
| Cluster denso Zoom `2.2×` Dark (`289` correntes) | [A_teia-zoom22-dense-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/A_teia-zoom22-dense-1440-dark.png) | [B_teia-zoom22-dense-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/B_teia-zoom22-dense-1440-dark.png) | — |
| Mobile Dark `390×844` | [A_teia-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/A_teia-390-dark.png) | [B_teia-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_4_teia/B_teia-390-dark.png) | — |

---

### Item 5 — Primeira Impressão Mobile (`390×844`), Anúncios e Políticas do Google AdSense

**Forense DOM real em Chromium WebGL2 (`build/web`, `127.0.0.1`, viewport `390×844`):**
Medição extraída via [`ab_webgl_export_qa.mjs`](file:///home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2/scratch/ab_webgl_export_qa.mjs) sobre os arquivos reais em `lib/ui/ads/` (mantidos **intocados**, `PROTECTED_BYTES=0`):

- **O que o código atual faz (`A`):**
  - [`EspectroFloatingAdBar`](file:///home/zpower/Downloads/espectro/lib/ui/ads/espectro_banner_ad.dart#L12) fica ancorada em [`EspectroScaffold`](file:///home/zpower/Downloads/espectro/lib/widgets/espectro_scaffold.dart#L117) e `EspectroQuizScreen` acima da `NavigationBar`.
  - No Chromium WebGL2 `390×844`, `flt-platform-view` e `<ins class="adsbygoogle" data-ad-client="ca-pub-1519935796466095" data-ad-slot="8975287447" data-ad-format="auto" data-full-width-responsive="true" data-ad-status="unfilled" data-adsbygoogle-status="done">` renderizam a partir de **`top: 717 px`** enquanto a `NavigationBar` começa exatamente em **`top: 780 px`** (`0 px` de espaçamento!).
  - O próprio `<ins>` responsivo reporta `offsetHeight: 390, wrapperHeight: 390` recortado pela caixa de `50 px` (`top: 717..780` com padding/borda = ~**`63 px`**). Somado à barra inferior de navegação (`780..844` = **`64 px`**), **os `127 px` inferiores (`15,0%` do viewport `844 px`)** ficam ocupados na primeira dobra.
  - Em estado **`unfilled`** (sem anúncio entregue ou offline), a captura real mostra **um retângulo cinza vazio ofuscando o rodapé**, tampando inclusive o texto `"AD · Espectro · Observatório Político Multidimensional"` que o [`EspectroBannerAdWidget`](file:///home/zpower/Downloads/espectro/lib/ui/ads/espectro_banner_ad.dart#L204-L256) tentava renderizar por baixo.

- **Diferenciação explícita dos 3 estados & Riscos às Políticas do AdSense:**
  1. **Unidade/Placeholder de Teste (`AdSense` test / AdMob oficial de teste):** só deve existir em builds de debug/homologação e **nunca** em produção web. No AdMob nativo já existem constantes de teste em `EspectroAdUnits`.
  2. **Espaço Vazio / Não Preenchido (`data-ad-status="unfilled"`):** pelas diretrizes de experiência do AdSense/Better Ads Standards, slots sem preenchimento **devem recolher para `0 px`** (`ins.adsbygoogle[data-ad-status="unfilled"] { display: none !important; }` e colapso do `EspectroFloatingAdBar` ao observar evento/estado `unfilled`), e **nunca** renderizar rótulo enganoso `"AD"` sobre texto autopromocional próprio (`"Espectro · Observatório..."`) — rotular conteúdo editorial próprio como `"AD"` confunde usuário/revisor e cria zona morta na primeira dobra.
  3. **Anúncio Carregado (`data-ad-status="filled"`):**
     - *Risco de clique acidental:* colar o banner a `0 px` acima da `NavigationBar` (`Início / Testes / Atlas / Histórico`) com botão customizado `×` de `14 px` viola recomendações de separação de controles de navegação em mobile (*Accidental Clicks* policy).
     - *Solução recomendada para web:* usar **AdSense Anchor Ads nativo** (gerenciado pelo script oficial) OU **unidade inline entre blocos de conteúdo (`In-feed` `320×100` / responsivo com `>= 24 px` de respiro e cabeçalho discreto `PUBLICIDADE`, nunca sobreposto nem tocando a barra de navegação)**, recolhendo a `0 px` quando `unfilled`.

| Estado Mobile `390×844` | Evidência Visual | Ocupação do Rodapé / 1ª Dobra |
| :--- | :--- | :--- |
| **A — Atual (`unfilled` fixo no WebGL2)** | [Dark](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_5_mobile_ads/A_mobile-390-dark-current-unfilled-ad.png) · [Light](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_5_mobile_ads/A_mobile-390-light-current-unfilled-ad.png) | Caixa cinza vazia fixa (`717–780 px`) a `0 px` dos botões de navegação (`780–844 px`) = **127 px (`15,0%`)** bloqueados. |
| **B — Recolhido se `unfilled` (`ESPECTRO_NO_ADS=true` simulando colapso)** | [Dark](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_5_mobile_ads/B_mobile-390-dark-collapsed-unfilled.png) · [Light](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_5_mobile_ads/B_mobile-390-light-collapsed-unfilled.png) | **0 px** desperdiçados acima da `NavigationBar` (`64 px` = `7,6%`). Hero + Teia + topo do próximo bloco respiram na 1ª dobra. |
| **C — Proposta Inline Política AdSense** | [C_mobile-390-dark-inline-policy-proposal.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_5_mobile_ads/C_mobile-390-dark-inline-policy-proposal.png) | Unidade `320×100` rotulada `PUBLICIDADE` **entre seções** (`≥ 24 px` de respiro), separada da barra de abas e recolhível a `0 px` se `unfilled`. |

---

### Item 6 — Fidelidade Metodológica da Suite Expressa (`espectro_result_screen.dart` & `share_card_content.dart`)

**Problema confirmado no Antes (A):** Em `TestSuite.espectroIntegrated` com `TestDepth.express` (24 afirmações, apenas os 12 eixos bipolares, **0 tríades avaliadas**):
- `_PreliminaryBanner` exibia *"Suas coordenadas nos 12 eixos e 6 tríades foram estimadas..."* mesmo quando nenhuma tríade havia sido medida.
- `_buildSectionCompassAndTriads` mantinha título *"Bússola política & Tríades composicionais"* citando 6 tríades em simplex de Aitchison.
- `ShareCardCanvas` exibia no selo inferior `"12 eixos · 6 tríades"` e no subtítulo superior `"12/12 eixos · 0/0 tríades com base observada"`.

**Correção implementada e verificada (B):**
- [`_PreliminaryBanner`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L5142-L5153) agora ramifica dinamicamente conforme `hasObservedAxes` e `hasObservedTriads`, informando explicitamente *"...nos 12 eixos bipolares foram estimadas... (as 6 tríades não foram medidas nesta etapa)"*.
- [`_buildSectionCompassAndTriads`](file:///home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart#L3273-L3279) muda para *"Bússola política (Projeção de Nolan)"* e explica que as 6 tríades não foram avaliadas nesta etapa.
- [`ShareCardCanvas`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart#L76-L83) e subtítulo [`dimensions`](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart#L118-L127) exibem **`"12/12 eixos bipolares observados"`** + selo **`"12 eixos bipolares"`** na Expressa, mantendo `"12 eixos · 6 tríades"` apenas quando ambas são observadas. Coberto por teste de regressão em [`audit_matrix_verification_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/audit_matrix_verification_test.dart#L586-L699).

- Antes (A): [A_express-prelim-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_6_express_truth/A_express-prelim-1440-light.png)
- Depois (B): [B_express-prelim-1440-light.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/ab_6_express_truth/B_express-prelim-1440-light.png)

---

### Item 7 — Validação Ponta a Ponta até Exportação de PNGs Reais `1:1` e `9:16`

Validado por dois caminhos independentes:

1. **Engine real Flutter (`captureShareCardPng`, `pixelRatio: 3`)** em [`ab_visual_evaluation_harness_test.dart`](file:///home/zpower/Downloads/espectro/test/ui/ab_visual_evaluation_harness_test.dart):
   - Expressa `1:1`: [flutter-export-expressa-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/flutter-export-expressa-1x1.png) — PNG válido (`89504e470d0a1a0a`), **`1080 × 1080 px`**, `196.423 B` (selo `"12 eixos bipolares"`, subtítulo `"12/12 eixos bipolares observados"`).
   - Expressa `9:16`: [flutter-export-expressa-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/flutter-export-expressa-9x16.png) — PNG válido (`89504e470d0a1a0a`), **`1080 × 1920 px`**, `260.993 B`.
   - Integrado Rápida `1:1`: [flutter-export-integrado-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/flutter-export-integrado-1x1.png) — PNG válido, **`1080 × 1080 px`**, `189.578 B` (selo `"12 eixos · 6 tríades"`).
   - Integrado Rápida `9:16`: [flutter-export-integrado-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/flutter-export-integrado-9x16.png) — PNG válido, **`1080 × 1920 px`**, `256.749 B`.
2. **Download real no navegador Chromium WebGL2 (`build/web`)**: resposta completa das **24 afirmações da Expressa** -> `Concluir` -> navegação à aba `Eixos (12)` (radar capturado) -> retorno a `Visão Completa` -> abertura do `ShareableCardSheet` -> clique em `Salvar imagem` (`Post 1:1` e após alternar para `Story 9:16`), interceptando evento nativo `download` do navegador:
   - Download `espectro-post.png`: [webgl-download-post-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/webgl-download-post-1x1.png) — **`1080 × 1080 px`**, `184.746 B`, zero `0/0 tríades`.
   - Download `espectro-story.png`: [webgl-download-story-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/ab_review/exports/webgl-download-story-9x16.png) — **`1080 × 1920 px`**, `271.070 B`, zero `0/0 tríades`. *(Obs.: no servidor local de QA, o rodapé exibe a origem `http://127.0.0.1:.../#/`; em produção publicada, `shareCardEntryLink()` resolve para `https://espectro-politico.web.app/`.)*

---

## Matriz de Verificação Técnica

| Verificação | Comando / Contexto | Resultado Observado |
| :--- | :--- | :--- |
| Análise estática | `dart analyze lib/ test/` | **0 issues** (`No issues found!`) |
| Harness A/B + PNGs 1:1 / 9:16 | `flutter test --dart-define=RUN_AB_CAPTURE=true --dart-define=AB_PHASE=after test/ui/ab_visual_evaluation_harness_test.dart` | **1/1 passou**, PNGs `1080×1080` e `1080×1920` decodificados via `ui.instantiateImageCodec` |
| Matriz responsiva & Expressa | `flutter test test/ui/audit_matrix_verification_test.dart` | **10/10 passaram** (zero overflow até `320×568 @ 1.3x`, contraste AA, teste Expressa) |
| Goldens Figma | `flutter test --update-goldens test/ui/figma_layout_test.dart` | **6/6 passaram** |
| Suíte completa Flutter | `flutter test --reporter=compact` | **`+295 ~1` (0 falhas; 1 skip preexistente)** |
| Web build + SEO | `flutter build web --no-wasm-dry-run && python3 tool/seo/generate_programmatic_seo.py` | **Compilado em 32,7s + 1.513 URLs SEO** |
| Chromium WebGL2 QA | `ab_webgl_export_qa.mjs --mode=normal` + `--mode=noads` (`/tmp/espectro_web_noads` removido em seguida) | `webgl2Verified: true`, **`0 console errors`**, **`0 page errors`**, downloads reais `1:1` e `9:16` válidos |
| Integridade protegida | `git diff assets/ lib/ui/ads/ lib/domain/engine/ pubspec.yaml \| wc -c` | **`0` bytes alterados** |

---

## Próximos Passos Aguardando Sua Aprovação

Nenhuma alteração foi aplicada nos padrões ativos de tema, estratégia dos 12 eixos ou arquivos de anúncios (`lib/ui/ads/`), nem houve merge para `main` ou deploy. Para fechar esta rodada, basta decidir os **3 pontos subjetivos** abaixo:

1. **Item 1 (Paleta padrão em [`lib/theme.dart`](file:///home/zpower/Downloads/espectro/lib/theme.dart)):** Manter **A (Jade/Pinho/Latão)** ou aplicar **B (Íris Cartográfico Refinado `#44378F` / `#9A92F0` + Latão `#E5A448`)**?
2. **Item 2 (Estratégia dos 12 Eixos em [`lib/ui/charts/axis_colors.dart`](file:///home/zpower/Downloads/espectro/lib/ui/charts/axis_colors.dart)):** Manter **A (Dual-Pole 24 cores)** ou ativar **B (Primary-Anchor 12 cores-âncora com polo oposto neutro)**?
3. **Item 5 (AdSense Mobile):** Manter atual ou autorizar atualização de `lib/ui/ads/` + `lib/widgets/espectro_scaffold.dart` para **recolher slots `unfilled` a `0 px`**, remover o selo `"AD"` autopromocional e adotar **unidade inline `In-feed` entre blocos (`≥ 24 px` da navegação)** ou **Anchor nativo do AdSense**?
