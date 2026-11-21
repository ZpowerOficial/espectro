# Espectro — Auditoria Ciclo 4: Aplicação Real das 5 Skills Anti-Slop e Design Engineering

**Data:** 21 de novembro de 2026  
**Branch:** `visual/art-direction-v2` (sem merge em `main` e sem deploy automático)  
**Integridade metodológica:** `git diff assets/ lib/domain/engine/ pubspec.yaml | wc -c` = **`0`** bytes (zero alterações em fórmulas, pesos, catálogo ou paletas semânticas canônicas).

---

## 1. Inventário Transparente das 5 Skills Solicitadas

Para corrigir a lacuna do Ciclo 3, cada uma das 5 referências enviadas pelo usuário foi verificada diretamente antes da execução do Ciclo 4:

| # | Skill / Ferramenta enviada | Status local nesta sessão | Como foi aplicada no Ciclo 4 |
|---|---|---|---|
| 1 | **Anti UI Slop** (`uizze/uizze`) | Instalada em `/home/zpower/Downloads/.agents/skills/anti-ui-slop/` (`SKILL.md` + `reference/{polish,craft,distill,audit}.md`) | Inspeção real dos PNGs antes/depois para eliminar truncamentos, caixas de glifo ausente (`□`) e desalinhamentos de grade em desktop/mobile. |
| 2 | **ThinkUI** (`https://thinkui.xyz`) | **Não conectada automaticamente**: ThinkUI é um servidor MCP hospedado autenticado (`https://thinkui.xyz/mcp`) que exige `Authorization: Bearer <sua-chave>` | Divulgado de forma transparente; nenhuma afirmação fictícia de uso. Veja instruções de conexão abaixo caso deseje ativá-lo. |
| 3 | **Taste Skill 2.5.1** (`Leonxlnx/taste-skill`) | Instalada com referências completas (`SKILL.md` + `references/{layout-v4,copy-voice,copy,motion}.md`) | Regra de primeira dobra em `1440×900`, redução de repetição textual (`289 correntes`), largura controlada de subtítulo (`maxWidth`), rótulos de botão específicos (verbo + objeto). |
| 4 | **Emil Design Engineering** (`emilkowalski/skills`) | Instalada com `emil-design-eng`, `choreograph`, `break-ui`, `find-animation-opportunities` e `learn-taste` | Polaridade direcional correta no Questionário (`Anterior` vs. `Próxima`), troca instantânea via teclado, elevação física discreta no hover desktop, CSS `@media (hover: hover) and (pointer: fine)`, tabela explícita de animações rejeitadas e testes `break-ui` com as fontes reais. |
| 5 | **Vercel Web Design Guidelines** (`vercel-labs/agent-skills`) | Instalada em `/home/zpower/Downloads/.agents/skills/web-design-guidelines/` (`SKILL.md` + `references/command.md`) | Substituição de `'Continuar'` genérico por `'Escolher profundidade'`, `fontFeatures: [FontFeature.tabularFigures()]` nos contadores/percentuais e prevenção de vazamento de `:hover` em telas touch. |

> [!NOTE]
> **Como conectar o ThinkUI MCP (opcional):** Caso queira incluir referências visuais do ThinkUI em ciclos futuros, adicione o endpoint `https://thinkui.xyz/mcp` com o cabeçalho `Authorization: Bearer <YOUR_API_KEY>` na configuração MCP local do seu cliente. Sem essa chave, apenas as 4 skills open-source podem ser executadas localmente.

---

## 2. Aplicação Prática por Skill (O que Mudou e Por quê)

### 2.1 `Emil: break-ui` + `UIZZE: anti-ui-slop` (Defeitos Reais Detectados em Capturas)

| Tela / Artefato | Antes (Ciclo 3) | Depois (Ciclo 4) | Arquivo |
|---|---|---|---|
| **Metodologia** (`metodo-1440-dark.png`) | `S = □(w_i · c_i) / □(w_i)` porque `assets/fonts/IBMPlexMono-Regular.ttf` não inclui `Σ` | Fórmulas usam `∑` (presente em `IBMPlexMono`) com `fontFamilyFallback: ['IBMPlexSans', 'sans-serif']`; zero glifos `□` | [methodology_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/methodology/methodology_screen.dart) |
| **Cartão Exportado `1:1`** (`final-export-prod-1x1.png`) | Rótulo de polo colidia com título do eixo na coluna direita compacta (`87,5% Assimila...`) | Quando `compact: true`, `_ShareAxisMiniBar` separa título em linha própria e valor/polo na linha inteira logo abaixo; `fontFamily: 'IBMPlexSans'` e `tabularFigures()` explícitos | [share_card_content.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart) |
| **Cartão Exportado `9:16`** (`final-export-prod-9x16.png`) | Nome longo truncava em 1 linha (`Mustafa Kemal Ata...`) | `_ShareThinkerCompactRow` permite `maxLines: 2` (`height: 1.16`); radar Story ajustado de `176` para `168 px` e divisores compactados (`+16 px` de folga vertical), zerando o overflow de `2,0 px` detectado em `share_card_regression_test.dart` | [share_card_content.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/share/share_card_content.dart) |
| **Home Mobile `390px`** (`home-390-dark.png`) | Rodapé da Teia concatenava `'Direita — toque em qualquer nó d...'` e cortava no `1 linha` | `TeiaInteractivePreviewPanel` exibe apenas a tradição (`'Direita'`), já que o cabeçalho informa `'Toque num nó para inspecionar'` | [teia_preview_panel.dart](file:///home/zpower/Downloads/espectro/lib/ui/charts/teia_preview_panel.dart) |
| **Personalidades em Evidência** (`home-1440-dark-12axes.png`) | Subtítulo de Karl Marx cortava em `recorte ...` e pill de Hannah Arendt cortava em `Representação: Democracia ...` | `_SpotlightCard` passou de `216` para `224 px` de largura, `maxLines: 3` no subtítulo (`height >= 288` escalável) e pill enxuto `'${dominantPole} · ${percent}%'` com `tabularFigures()` (ex.: `Democracia · 95%`, `Público · 100%`) | [espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart) |
| **Atlas Desktop `1440px`** (`atlas-1440-dark.png`) | 7 de 8 cards de tradição cortavam a descrição no meio da frase (`maxLines: 2`) | `_SpectrumCard` agora usa `maxLines: 4` e altura desktop uniforme escalável (`>= 154 px`); 7 de 8 tradições aparecem 100% completas (`Terceira posição`, mais longa, exibe 4 linhas completas com corte limpo apenas na linha final) | [atlas_explorer_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart) |

---

### 2.2 `Emil: choreograph` + `emil-design-eng` + `find-animation-opportunities`

#### A. Transições do Questionário ([espectro_quiz_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_quiz_screen.dart))
- **Polaridade direcional real:** `_navDirection` (`+1` para avançar, `-1` para `Anterior` ou salto para índice menor) faz o novo card entrar de `+0.028` (avanço) ou `-0.028` (retorno), enquanto o card antigo sai na direção oposta com `reverseDuration: 135 ms` (< `180 ms` de entrada).
- **Atalhos de teclado sempre instantâneos:** teclas `1–5` (e teclado numérico) e setas `←`/`→` acionam `_instantTransition = true`, trocando `AnimatedSwitcher.duration` e `reverseDuration` para `Duration.zero` (conforme regra Emil para ações frequentes iniciadas por teclado), preservando a transição suave apenas para ponteiro/toque e respeitando `MediaQuery.disableAnimationsOf`.

#### B. Micro-interações em Desktop & CSS Touch-Safe
- **`_SpotlightCard` ([espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart)):** elevação sutil de `-2 px` no hover desktop e zoom contido (`1.03x`) dentro de `ClipRect` no retrato, respeitando `disableAnimationsOf`.
- **`_SpectrumCard` ([atlas_explorer_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/atlas_explorer_screen.dart)):** elevação `-2 px` + deslizamento sutil da seta (`Offset(0.18, 0)`) no hover desktop.
- **Páginas Web & SEO Estático ([web/index.html](file:///home/zpower/Downloads/espectro/web/index.html), [web/privacidade.html](file:///home/zpower/Downloads/espectro/web/privacidade.html), [generate_programmatic_seo.py](file:///home/zpower/Downloads/espectro/tool/seo/generate_programmatic_seo.py)):** todos os estados `:hover` agora ficam encapsulados em `@media (hover: hover) and (pointer: fine)` para evitar estado visual preso após toque em dispositivos móveis.

#### C. Tabela de Candidatos Rejeitados (`find-animation-opportunities`)
Em conformidade explícita com a skill `find-animation-opportunities`, os elementos abaixo foram avaliados e **rejeitados para animação**:

| Candidato avaliado | Por que NÃO animar |
|---|---|
| Barras divergentes na rolagem da lista de resultados | Alta densidade de itens simultâneos; animações encadeadas ou por rolagem adicionam latência perceptiva sem valor analítico. |
| Chips de filtro horizontais do Atlas (`atlas-mobile-filter-rail`) | Ação de troca rápida e frequente; resposta imediata de borda/cor supera animações de mola ou escala contínua. |
| Pulsos contínuos ou brilho ambiente na Projeção Nolan / Hero | O usuário já aprovou ausência de glows, halos artificiais e animações decorativas contínuas em áreas cartográficas. |
| Auto-scroll/stagger nos 12 cards de eixos na Home | Os 12 cards são referência estática de leitura imediata; animar entrada retardaria a comparação paralela dos polos. |

---

### 2.3 `Taste Skill 2.5.1` (`layout-v4` + `copy-voice`) + `Vercel Web Design Guidelines`

- **Estágio do Herói (`1440×900` e `390×844`)** ([espectro_home_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/home/espectro_home_screen.dart)): título desktop em `40 px`, subtítulo limitado a `maxWidth: 450`, mapa Nolan elevado (`height: 456` em desktop / `284` em mobile), respiro vertical de `28 px` no bloco Hero e espaçamento de `72 px` (`52 px` no mobile) antes da seção `"Veja como fica o seu cartão"`.
- **Desduplicação de cópia na primeira dobra:** reduzida a repetição excessiva de `"289 correntes"` na abertura; o subtítulo traz o recorte uma vez (`Inspecione 289 correntes na Teia…`), o cabeçalho da prévia traz `'Projeção Nolan (289 correntes)'`, o subtítulo da prévia traz `'Toque num nó para inspecionar'` e a linha de metadados ficou factual: `'24 afirmações · 100% offline · Cartão 9:16 e 1:1'`.
- **CTA específico (verbo + objeto)** ([espectro_suites_screen.dart](file:///home/zpower/Downloads/espectro/lib/ui/features/quiz/espectro_suites_screen.dart)): botão genérico `'Continuar'` substituído por `'Escolher profundidade'` (e testes correspondentes atualizados em [figma_layout_test.dart](file:///home/zpower/Downloads/espectro/test/ui/figma_layout_test.dart) e [navigation_values_regression_test.dart](file:///home/zpower/Downloads/espectro/test/ui/navigation_values_regression_test.dart)).

---

## 3. Verificação Objetiva Executada Após o Último Edit

| Verificação | Resultado observado |
|---|---|
| `dart analyze lib/ test/` | `No issues found!` |
| `flutter test --update-goldens test/ui/figma_layout_test.dart` | Goldens atualizados (`home-390-light/dark`, `home-1440-light/dark`) e `+6: All tests passed!` |
| `flutter test --reporter=compact` (suíte completa com os 2 novos testes em [audit_matrix_verification_test.dart](file:///home/zpower/Downloads/espectro/test/ui/audit_matrix_verification_test.dart)) | `01:01 +303 ~1: 1 skipped test. All other tests passed!` (0 falhas; inclui stress `break-ui` com fontes reais `IBMPlexSans`/`IBMPlexMono` validando `didExceedMaxLines == false` para `'Mustafa Kemal Atatürk'` e `'87,5% Assimilação'` em `1:1` e `9:16`, e teste `choreograph` teclado vs. ponteiro) |
| Integridade protegida (`git diff assets/ lib/domain/engine/ pubspec.yaml \| wc -c`) | `0` |
| `flutter build web --no-wasm-dry-run` + `python3 tool/seo/generate_programmatic_seo.py` | `✓ Built build/web` (`31,9s`); `Generated 1502 static SEO pages + 8 spectrum pages + catalogo.html + llms.txt + sitemap.xml (1513 URLs).` |
| QA Chromium WebGL2 (`final_verification_webgl_qa.mjs`, [telemetry_final_v2.json](file:///home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2/scratch/telemetry_final_v2.json)) | `webgl2Verified: true`, `appConsoleErrors: []`, `appPageErrors: []`, `offlineExpectedAborts: 1`, `quizAdsCheck` vazio, matriz AdSense íntegra (`unfilled`/`offline`/`unfill-optimized-zero` com altura `0 px`, `filled` `350×100` inline com rótulo `Publicidade`), exportações válidas: `post1x1` (`1080×1080`, `183994` B) e `story9x16` (`1080×1920`, `258164` B) |

---

## 4. Comparação Visual Antes / Depois (Inspecionada em Pixels)

- **Metodologia (antes/depois):** [before/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/metodo-1440-dark.png) → [after/metodo-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/metodo-1440-dark.png)
- **Exportação `1:1` (antes/depois):** [before/final-export-prod-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/final-export-prod-1x1.png) → [after/final-export-prod-1x1.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/final-export-prod-1x1.png)
- **Exportação `9:16` (antes/depois):** [before/final-export-prod-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/final-export-prod-9x16.png) → [after/final-export-prod-9x16.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/final-export-prod-9x16.png)
- **Home Desktop `1440px` (antes/depois):** [before/home-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/home-1440-dark.png) → [after/home-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/home-1440-dark.png)
- **Home Mobile `390px` (antes/depois):** [before/home-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/home-390-dark.png) → [after/home-390-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/home-390-dark.png)
- **Destaques e 12 Eixos `1440px` (antes/depois):** [before/home-1440-dark-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/home-1440-dark-12axes.png) → [after/home-1440-dark-12axes.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/home-1440-dark-12axes.png)
- **Atlas `1440px` (antes/depois):** [before/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/before/atlas-1440-dark.png) → [after/atlas-1440-dark.png](file:///home/zpower/Downloads/espectro/docs/audits/screenshots/cycle4_skills/after/atlas-1440-dark.png)
