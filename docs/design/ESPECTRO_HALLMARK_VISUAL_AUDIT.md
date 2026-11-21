# Auditoria Visual Hallmark + Obscura — Espectro (Linha de Base ANTES)

**Data:** 2026-11-18  
**Branch:** `visual/art-direction-v2` (base `1ce1059`)  
**Frameworks aplicados:** Hallmark v2.0.0 (`nutlope/hallmark` — Floor, Reflex, Finish, `data-viz.md`, `redesign.md`), Seth Godin (*Purple Cow*, leitura nos primeiros 5 segundos) e Steven Bartlett (*33 Laws*, densidade perceptual, lacuna de curiosidade honesta, progresso dotado).  
**Motores matemáticos congelados:** nenhuma fórmula de projeção Nolan, 12 eixos, 6 tríades (`StudyTernaryGeometry`, `EspectroAtlasEngine`, `EspectroCompatibilityEngine`, `RaioXEngine`) ou dado de catálogo foi alterada nesta auditoria.

---

## 1. Honestidade metodológica: tradução de Hallmark (HTML/CSS) para Flutter/CanvasKit + Obscura

O linter mecânico do Hallmark (`sloplint.mjs`) analisa HTML/CSS e DOM no Chromium. Quando executado sobre os arquivos estáticos da pasta `build/web/`:
- `sloplint.mjs build/web/index.html` reportou **`0 FAIL, 0 REFLEX, 0 WARN`** (apenas porque `web/index.html` contém o comentário-selo Hallmark no CSS do fallback `#seo-semantic-shell`).
- `sloplint.mjs build/web/catalogo.html build/web/p/personality-karl_marx.html build/web/privacidade.html` reportou **`0 FAIL, 1 WARN`** (`Gate 58` em `catalogo.html`, devido aos 1.502 verbetes listados em catálogo enciclopédico — esperado para índice completo).

**Diagnóstico crítico:** declarar "Hallmark conformidade total" pelo resultado do `sloplint` no HTML seria **desonesto**. A interface real onde usuários passam 99% do tempo é renderizada em CanvasKit (`lib/ui/...`, `lib/widgets/...`, `lib/theme.dart`). E mesmo dentro do HTML estático (`home-static-1440.png` no Obscura), a inspeção visual mostra uma composição de 3 cartões uniformes centrados em CSS que passa no lint estático mas cai nos vícios de composição genérica.

### Mapeamento explícito dos gates Hallmark para o ecossistema Espectro

| Categoria | Gates / Regras Hallmark | Como se aplica ao Espectro (Flutter Web/Desktop/Mobile + HTML) | Status na Linha de Base (`ANTES`) |
| --- | --- | --- | --- |
| **Aplicável direto (HTML/SEO)** | `G20`, `G34`, `G40`, `G58`, `G76`, `F23` | Aplicam-se ao HTML fallback de `web/index.html`, `catalogo.html`, `p/*.html` no Obscura 0.2.6. | Parcial: zero overflow/console errors; composição visual do fallback (`home-static-1440.png`) repete tríptico de cards centrados. |
| **Adaptado ao Flutter (`CanvasKit` / Material 3)** | `G2a/2b` (gradientes), `G3` (cards uniformes/listras), `G4` (card dentro de card), `G7a/b` (`#000`/`#fff`), `G29` (glow/nebula), `G54` (eyebrows), `G63` (pontos médios `·` e `→` coladas), `G64` (mono como fantasia), `G67` (caps espaçadas `≤15px`), `G77–79` (massa vazia), `F4` (2 botões preenchidos lado a lado), `F5` (moeda de ícone), `F7` (raio repetitivo) | Mapeados diretamente para `Container`/`SectionCard`, `SpectrumGradientRule`, `Eyebrow`, `TextStyle(letterSpacing > 0.3, uppercase)`, `CustomPainter`, `FilledButton`, `BoxShadow`. | **Múltiplas violações severas** em Home, Modalidades, Atlas, Comparador, Resultados e Teia. |
| **Adaptado a Dataviz (`data-viz.md`)** | Ênfase vs poluição, gridlines sólidas 1px sem neblina (`G29`), texto legível (`G75`), zero sobreposição (`G73`), rótulos integrais (sem truncamento), escala proporcional (`G77`) | Aplicado à **Teia**, **Radar 12 Eixos** e **6 Tríades**: clareza da grade, hierarquia figura-fundo, ausência de manchas borradas e aproveitamento espacial. | **Teia** subexplorada no tema claro e sem leitura cartográfica nítida; **Radar** e **Tríades** encolhidos em caixas largas. |
| **N/A ou distinto em App Nativo Multiplataforma** | CSS `vh`/`100vw`, `hover:scale` puro HTML, formulários de email marketing (`G85`), stamp de CSS (`G20` nos `.dart`) | Em Flutter (`Web, Android, Linux, Windows`), usa-se `LayoutBuilder`, `MediaQuery`, `EspectroScaffold`, `TactilePress` e `InkWell`. | Regra respeitada sem falsa equivalência. |

---

## 2. Evidência de Execução Real: Obscura 0.2.6 vs Chromium WebGL2 (`ANTES`)

Todos os comandos abaixo foram executados contra o build real `build/web` (`1ce1059`):
1. **Obscura 0.2.6** (`/home/zpower/Downloads/obscura-x86_64-linux-stealth/obscura` via CDP `serve` em `ws://127.0.0.1:9xxx/devtools/browser`):
   - **Capaz nativamente de:** renderizar e fotografar HTML/SEO fallback (`/` sem WebGL, `catalogo.html`, `/p/personality-karl_marx.html`) em todas as larguras (`360×800`, `390×844`, `768×1024`, `1280×800`, `1440×900`, `1660×900`, `1920×1080`), verificar `overflowX = false`, `brokenImgs = 0` e `consoleErrors = 0`.
   - **Limitação factual observada no Obscura 0.2.6:** possui `webGLVersion = -1` (fallback de CPU) e não implementa `OffscreenCanvas.prototype.addEventListener` / `bitmaprenderer`, além de seu rasterizador 2D não materializar pixels do CanvasKit de Flutter em screenshot (`MakeSWCanvasSurface` não gera pixels no buffer capturado). Por isso, o Obscura valida **HTML estático, SEO, responsividade DOM, ausência de erros de console e carregamento**, enquanto **Chromium Headless Shell/Chrome (`chromium-1243`) com WebGL2 + Playwright** e o motor Skia do `flutter test` fornecem os pixels reais do CanvasKit Flutter. Ambos os ambientes compõem o protocolo conjunto desta auditoria.
2. **Suíte de regressão base (`flutter test`)**: `284 passed, 1 skipped, 0 failed`.

---

## 3. Auditoria por Área (Todas as 9 Áreas + HTML Fallback)

### A. Home (`lib/ui/features/home/espectro_home_screen.dart` & `test/ui/goldens/home-1440-light.png`, `docs/design/screenshots/before/webgl/home-1440-dark-top.png`, `home-390-dark.png`)

1. **[CRÍTICO · Hallmark G3 / G8 / G77 / G79] Composição SaaS encaixotada e espaço ocioso ao redor:** O Hero inteiro (`_ObservatoryCoverHero`, `espectro_home_screen.dart:1000-1074`) fica preso dentro de um card escuro arredondado (`radius: 22`) com fundo gradient roxo-escuro (`#4E3FA5`), encimado por uma barra arco-íris (`SpectrumGradientRule`, L1027). À esquerda e à direita da coluna de 1040px (`home-1440-light-top.png`), sobra um mar uniforme de fundo cinza-azulado sem hierarquia editorial.
2. **[CRÍTICO · Purple Cow / Godin] A Teia — maior ativo do Espectro — não existe na primeira dobra:** Quem entra em `/` não vê a cartografia das 289 correntes na primeira tela; vê um headline genérico dentro de caixa roxa e 3 botões de Likert. O Espectro parece um app de questionário comum antes de parecer um observatório cartográfico vivo.
3. **[ALTO · Floor G54 / G63 / G67] Cascata de eyebrows em caps espaçadas, pontos médios e setas coladas:**
   - `OBSERVATÓRIO POLÍTICO · 18 DIMENSÕES` (`G54 + G67 + G63`, `espectro_home_screen.dart:903-911`).
   - `Ou explore o Atlas de Correntes →` (`G63` seta colada no botão, L980).
   - `24 afirmações no Expresso · 289 correntes · 757 pensadores` (`G63` múltiplos pontos médios em mono abaixo dos CTAs, L986).
   - `DILEMA RELÂMPAGO · 1/24` e `PODER · LIBERDADE VS. SEGURANÇA` dentro da sub-caixa direita do card hero (`G4` card dentro de card + `G67`).
4. **[ALTO · Floor G4 + F5] Pilha monótona de `SectionCard` abaixo da dobra:** `_LatestEvaluationBentoCard` → `_HeroLiveSpectrumShowcase` (radar minúsculo ~168px escondido à esquerda dentro de outro card arredondado com `PRÉVIA EM 12 EIXOS`) → `_IdeologicalRiddleGameCard` (enigma dentro de card interno cinza com filete colorido de contagem `G82`-like) → dois cards lado a lado (`Explorar por conta própria` com 3 ícones em quadrado roxo `F5` + `Comparador`) → `_ObservatoryPassportCard` (`Nível 1 · Visitante Curioso`).
5. **[ALTO · BUG VISUAL DE PRODUÇÃO WEB] Tarja cinza/opaca vazia de anúncio no Web headless:** em `docs/design/screenshots/before/webgl/home-1440-dark-top.png` e `home-390-dark.png`, `EspectroFloatingAdBar` (`lib/ui/ads/espectro_banner_ad.dart:42-83`) reserva faixa sólida no rodapé com retângulo vazio claro no tema claro e container vazio no escuro quando o slot web ainda não recebeu criativo do AdSense.

---

### B. Modalidades e Quiz (`lib/ui/features/quiz/espectro_suites_screen.dart` & `docs/design/screenshots/before/webgl/suites-1440-dark.png`, `quiz-express-1440-dark.png`)

1. **[ALTO · G3 / G54 / G67 / G69] 3 cartões empilhados repetitivos com moedas numeradas (`01`, `02`, `03`):** `suites-1440-dark.png` mostra três boxes idênticos com quadrados `01/02/03`, selo `RECOMENDADO` em caps (`G67`), fileira de chips repetidos (`12 eixos`, `6 tríades`, `Nolan`, `289 correntes`), barra arco-íris no selecionado (`SpectrumGradientRule`), eyebrow `DESCUBRA SUA VISÃO DE MUNDO`, e o cartão à direita (`RESUMO DA MODALIDADE`) **repete exatamente os mesmos chips** (`G69` — echo) dentro de um card escuro com sombra e outra barra arco-íris. Botão `Continuar →` carrega seta colada (`G63`).
2. **[MÉDIO · Quiz] Barra de progresso e densidade (`quiz-express-1440-dark.png`):** O fluxo de resposta em si é focado, limpo e legível, com ótimos atalhos `1–5`; porém os cabeçalhos internos ainda usam caps rastreadas (`ESTRUTURA · GOVERNO`, `G54/G67`) e pílula flutuante central acima do card. Fica **fora do corte vertical principal** após a aprovação, exceto tokens herdados de `Surface`/tipografia.

---

### C. Atlas Político — Entrada e Lista com Polcompballs (`lib/ui/features/atlas/atlas_explorer_screen.dart` & `docs/design/screenshots/before/webgl/atlas-1440-dark-top.png`, `atlas-1440-dark-list-polcompballs.png`)

1. **[ALTO · Parede de controles acima da dobra (`atlas-1440-dark-top.png`):** O usuário precisa atravessar: eyebrow `CATÁLOGO & PERSONALIDADES` (`G54/G67`), título H1, linha longa com 3 pontos médios, **4 pílulas de estatística**, campo de busca largura total, **9 chips de filtro em 2 linhas**, título `Tradições e espectros` e **8 cards uniformes (4×2)** com listra superior colorida (`G3`), número no canto superior direito (`F5`/`G66`), texto cortado com `...` (`F2`), e seta colada (`50 correntes →`, `G63`) antes de ver um único verbete ou os *Percursos Curados*.
2. **[MÉDIO · Contraste / Moldura das Polcompballs (`atlas-1440-dark-list-polcompballs.png`):** Os ícones autorais das correntes (ex.: *Aceleracionismo de Esquerda*, *Austromarxismo*) são ilustrações fortes e únicas, mas cada item repete uma caixa com borda grossa colorida, duas pílulas (`ESQUERDA RADICAL` + `18/18 dim.`) e fita DNA sem rótulo de legenda no primeiro contato.

---

### D. Fichas / Personalidades (`marx-1440-dark.png`, `rothbard-1440-dark.png`)

1. **[MÉDIO · Pontos positivos a preservar + falhas:** Os retratos históricos reais (daguerreótipos de Marx, Rothbard etc.) têm grande autoridade editorial e autenticidade. Todavia, em `marx-1440-dark.png`, a ficha abre com caixa avermelhada com tarja sólida no topo (`G3`), eyebrow `ESQUERDA RADICAL`, ponto médio, coleção de 5 chips (`1818-1883`, `Alemanha / Reino Unido`, `Comparar perfil`, `Esquerda radical`, `18/18 dimensões completas`), e sub-card encaixotado em `Tradições de referência` com eyebrow `RELAÇÃO INTELECTUAL DOCUMENTADA` (`G4 + G54 + G67`).

---

### E. Resultados: Visão Completa, 12 Eixos e 6 Tríades (`resultado-1440-dark.png`, `resultado-390-dark.png`, `result-overview-1440-dark.png`, `result-axes-1440-dark.png`)

1. **[CRÍTICO · Floor G4 / F4 / G54 / G63 (`result-overview-1440-dark.png`, `resultado-390-dark.png`):** O card inicial do resultado empilha **quatro níveis de contenção** um dentro do outro:
   - Card externo `Trabalhismo Desenvolvimentista` (`42.92% de convergência` em pill + `SEU ARQUÉTIPO · ESQUERDA` + citação com barra lateral vermelha) →
   - Chip `Traço raro: ...` com diamante →
   - Caixa verde-petróleo interna `SURPRESA FUNDAMENTADA · CONVERGÊNCIA IMPROVÁVEL →` →
   - **Dois sub-cards com borda lateral grossa** (`PENSADOR MAIS PRÓXIMO` e `SEU ANTAGONISTA HISTÓRICO`, violando `G4` e `G3`) →
   - **Dois botões preenchidos roxos lado a lado** (`Compartilhar resultado` e `Desafiar amigo`, violando Hallmark **`F4`**) + botão `Sobre este arquétipo` + link com seta colada (`Comparar lado a lado →`, `G63`).
   - Em **mobile 390px (`resultado-390-dark.png`)**, essa caixa empilhada consome 100% da primeira tela inteira sem mostrar nenhum gráfico!

---

### F. Radar de 12 Eixos (`lib/ui/charts/multidimensional_radar_chart.dart`, `result-axes-1440-dark.png`, `compare-1440-dark-radar.png`)

1. **[CRÍTICO · DataViz G77 / Subdimensionamento e truncamento]:**
   - Na aba `Eixos (12)` (`result-axes-1440-dark.png`), o radar fica solitário dentro de um cartão largo com ~350px de vazio à esquerda e à direita (`RADAR MULTIDIMENSIONAL DOS 12 EIXOS`), medindo cerca de ~200px úteis dentro de uma folha de 980px. Na visão geral de resultados (`espectro_result_screen.dart:2209`), mede apenas **186px** no desktop e **168px** no mobile!
   - **Rótulos mutilados a 5 caracteres (`multidimensional_radar_chart.dart:96-98`):** `Estru.`, `Repre.`, `Imigr.`, `Diplo.`, `Inter.`, `Econo.`, `Contr.`, `Comér.`, `Relig.`, `Tecno.` em monoespaçada de `9.5px` (`G75` abaixo de 11px funcional), obrigando o leitor a decifrar abreviações sem o eixo legível.
   - **Divergência texto vs desenho:** O subtítulo na aba de eixos descreve `"A linha tracejada interna representa o centro neutro"`, enquanto `_RadarPainter` (`multidimensional_radar_chart.dart:72-79`) desenha uma linha **contínua** fina de 1.3px (não tracejada!).

---

### G. 6 Tríades Baricêntricas (`lib/ui/charts/study_ternary_chart.dart`, `lib/ui/features/results/espectro_result_screen.dart:4415-4550`)

1. **[ALTO · DataViz + G4 + G63]:** Cada uma das 6 tríades ocupa uma página inteira em altura dentro de `SectionCard` com lista de tags em topo (`Composição: A 33% · B 33% · C 34%` com `G63` ponto médio), outro box de aviso, triângulo centralizado limitado a `maxWidth: 360` / altura `240px` (`study_ternary_chart.dart:151-156`) com sombreamento nos pinos circulares (`boxShadow` colorido, `G29`), mais 3 cartões de vértice embaixo e sub-card de figura histórica embaixo. O gráfico triangular — a peça intelectual mais original das 6 dimensões — parece miniatura cercada de fichas.

---

### H. Comparador Lado a Lado (`lib/ui/features/compare/study_comparison_screen.dart` & `docs/design/screenshots/before/webgl/compare-1440-dark-top.png`, `compare-1440-dark-radar.png`, `compare-1440-dark-triads-real.png`)

1. **[CRÍTICO · Floor G4 / G63 / Semantic Slop (`study_comparison_screen.dart:632-763`, `comparacao-1440-dark.png`)]:**
   - `Proximidade por par` está encapsulado dentro de um cartão externo com barra roxa plana no meio, texto mono com pontos médios (`12 eixos · 6 tríades · 100% de sobreposição disponível`, `G63`) e **dois sub-cartões aninhados (`G4`) com borda e fundo verde (`p.success`) para "Convergências" e âmbar (`p.warning`) para "Contrastes"**. Em ciência política analítica, verde vs âmbar passa julgamento moral implícito (“certo/errado”) em vez de convergência vs tensão neutra entre eixos!
   - Na lista dos 12 eixos abaixo (`compare-1440-dark-triads-real.png`), **cada eixo** vira um cartão isolado cheio de **4 pílulas repetidas**: ponto colorido no título, pílula azul sujeito A, pílula rosa sujeito B, pílula `Δ 2 pp`, barra dupla e mais 2 pílulas de polos abaixo (`● Irreligioso`, `● Religioso`). Faltam tabela tabular limpa e alinhamento direto dos desvios!

---

### I. A Teia — 1 Painel e 4 Painéis Simultâneos (`lib/ui/charts/study_constellation.dart`, `lib/ui/features/atlas/study_map_screen.dart`, `teia-1pane-1440-light.png`, `teia-1pane-1440-dark.png`, `teia-4pane-1440-dark-inspector.png`)

Sendo a **Vaca Roxa (Patrimônio Visual Central)** do Espectro, a Teia apresenta os defeitos de maior impacto na percepção de qualidade:

1. **[CRÍTICO · DataViz G29 — Manchas difusas invisíveis no tema claro (`teia-1pane-1440-light.png`)]:** O fundo das 8 famílias usa `RadialGradient` suaves de baixa opacidade (`Nebula`). No tema escuro vira névoa sem contorno claro de fronteira; no **tema claro** vira **fumaça quase imperceptível** onde Centro, Direita e Libertários praticamente se fundem no papel claro.
2. **[CRÍTICO · Colisões reais no modo 4 Painéis (`teia-4pane-1440-dark-inspector.png`)]:**
   - No **Painel 2 (`Economia × Poder`)**, rótulos densos (`Anarquismo Individualista (Tucker / Spooner)`) colidem por cima da pílula cardinal `LIBERDADE ↑` (`G73`).
   - No **Painel 3 (`Moral × Religião`)**, a caixa flutuante `ESPECTROS` no canto inferior esquerdo **cobre diretamente os nós e rótulos** (`Liberalismo Clássico`, `...capiatlismo`) dentro do quadrante sudoeste (`G73`).
   - Os controles flutuantes `[+] [-] [reenquadrar] [pausar]` aparecem **duplicados 4 vezes**, um em cada quadrante, junto de 4 cartões flutuantes de eixo e 16 pílulas cardinais em caps — transformando o modo 2×2 em poluição de UI cromada sobre o mapa.
3. **[ALTO · Hierarquia figura-fundo & micro-colisões nos nós (`teia-1pane-1440-dark.png`)]:** Mesmo com filtro `"liberalismo"`, o cluster próximo (*Benedetto Croce*, *Free Market Fairness*, *Liberalismo Clássico*) empilha etiquetas brancas/escuras sólidas diretamente sobre os nós azuis e amarelos, escondendo os pontos que deveriam ser clicáveis e apagando as arestas relacionais sob a opacidade sólida.
4. **[ALTO · Grade sem calibração cartográfica]:** Os eixos ortogonais (`x=0`, `y=0`) são linhas tênues sem marcações de escala (`-100`, `-50`, `0`, `+50`, `+100`) nem retículo sutil, perdendo o caráter de **instrumento cartográfico de precisão**.

---

## 4. Síntese de Prioridades para as Fases 1 e 2

| Prioridade | Alvo | Problema principal na Linha de Base | Direção estrutural da solução |
| --- | --- | --- | --- |
| **P0** | **Home (Primeira Dobra)** | Card hero genérico roxo + barra arco-íris + ausência da Teia | Abrir Home com composição cartográfica assimétrica **sem caixa externa**, colocando **Teia viva interativa das 289 correntes** ao lado do manifesto editorial tipográfico + acesso progressivo e honesto aos jogos sem pilhas de cartões. |
| **P0** | **Teia (1 e 4 Painéis)** | Nebulosa difusa (`G29`), colisões (`G73`) no modo 2×2, controles 4× duplicados e sem grade calibrada | Substituir manchas difusas por **envoltórias/regiões cartográficas convexas precisas + retículo calibrado** (`-100..+100`), desclutter anti-colisão nas etiquetas, unificação dos controles no modo 2×2 (`toolbar` compartilhada + foco claro do painel ativo) e preservação integral da projeção Nolan/2-eixos/Tríade. |
| **P1** | **Comparador (`Proximidade por par` + Radar)** | Sub-cards aninhados (`G4`) verde/âmbar com julgamento moral + barras/pills repetidos em cada eixo | Matriz tabular especular **Sem Cartões Aninhados**: convergências vs tensões divididas por fio editorial central na mesma superfície, com radar comparativo ampliado e legível. |
| **P1** | **Sistema Visual & Tarja AdSense** | Eyebrows caps (`G54/G67`), pontos médios (`G63`), 2 botões sólidos (`F4`), barra cinza vazia no AdSense web | Padronizar escala tipográfica sem `UPPERCASE + tracking` em labels, remover `SpectrumGradientRule` como carimbo repetitivo e colapsar o banner web quando não houver anúncio carregado no viewport headless. |

---

## 5. Verificação de Integridade da Linha de Base

- **Inventário de capturas ANTES geradas e verificadas:**
  - `docs/design/screenshots/before/obscura/` — 10 capturas reais do Obscura 0.2.6 (`home-static-{360,390,768,1280,1440,1660,1920}.png`, `catalogo-seo-{1440,390}.png`, `marx-seo-1440.png`).
  - `docs/design/screenshots/before/webgl/` — 24+ capturas Chromium WebGL2 CanvasKit cobrindo Home (Light/Dark + responsividade), Atlas + Polcompballs, Teia 1-painel (Light/Dark) e 4-painéis, Modalidades, Quiz, Resultados e Comparador.
  - `docs/design/screenshots/before/qa_report_before.json` — registro técnico (`0 consoleErrors`, `0 pageErrors`, `0 brokenImgs`, `overflowX = false`).
- **Golden baseline:** `test/ui/goldens/*.png` intactos e `flutter test`: `284 passed, 1 skipped`.
