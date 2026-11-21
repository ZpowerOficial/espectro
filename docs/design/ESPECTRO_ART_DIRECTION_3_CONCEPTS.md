# 3 Direções Artísticas em Flutter — Experimentos, Comparação e Recomendação

**Data:** 2026-11-18  
**Branch:** `visual/art-direction-v2`  
**Protótipo navegável no aplicativo:** rota `#/design-lab` (`lib/ui/features/design_lab/art_direction_lab_screen.dart`), alternando em tempo real entre as Direções **A**, **B**, **C** e o **Estudo Teia 2D**, com tema Claro/Escuro e dados reais do catálogo (`289 correntes`, `757 pensadores`, cálculo vivo `StudyCatalog.compare`).

---

## 1. Visão comparativa das 3 direções estruturais

As três direções foram projetadas em **estruturas espaciais incompatíveis entre si**, e não como variações cromáticas do mesmo layout:

| Dimensão | Direção A · Cartografia Viva | Direção B · Atlas Editorial | Direção C · Laboratório Especular |
| --- | --- | --- | --- |
| **Objeto central da 1ª dobra** | **Teia Nolan viva (289 correntes)** com envoltórias convexas + retículo calibrado ao lado do manifesto editorial | **Folha de espécimes de museu** (daguerreótipo de Karl Marx, Arendt, Hayek, Polcompballs) entre índices tabulares | **Mesa óptica simétrica 50\|50** comparando pares opostos sobre radar ampliado com taxa tabular central |
| **Macroestrutura (`Hero` + Fluxo)** | Split assimétrico **5:7** direto sobre o papel mineral, sem caixa hero e sem barra arco-íris | Monografia em **3 colunas (3:6:3)** separadas por fios editoriais horizontais/verticais | Colunas simétricas espelhadas por eixo vertical central + barra linear de confrontos |
| **Hierarquia Tipográfica** | Display denso `IBMPlexSans` (`44px`, `-1.15` tracking) + numérico tabular exclusivo para coordenadas | Cabeçalho editorial ancho (`38px`) + índices tabulares com sublinhado ativo e zero pílulas | Placar numérico central (`54%`) como âncora visual + lista paralela de desvios |
| **Atmosfera & Superfícies** | Ardósia mineral (`#0A1018`) no escuro; pergaminho calcário (`#F1F0EA`) no claro | Carvão quente (`#141210`) e papel de arquivo (`#F3EEE3`) com carmesim óxido (`#9E2A2B` / `#E0715B`) | Obsidiana óptica (`#0A0D12`) e gelo clínico (`#EBEFF5`) com polaridade azul/âmbar (`#3A86FF` / `#D97706`) |
| **Evidências visuais capturadas** | [`concept-a-1440-dark.png`](screenshots/concepts/concept-a-1440-dark.png) · [`concept-a-1440-light.png`](screenshots/concepts/concept-a-1440-light.png) · [`concept-a-390-dark.png`](screenshots/concepts/concept-a-390-dark.png) | [`concept-b-1440-dark.png`](screenshots/concepts/concept-b-1440-dark.png) · [`concept-b-1440-light.png`](screenshots/concepts/concept-b-1440-light.png) · [`concept-b-390-dark.png`](screenshots/concepts/concept-b-390-dark.png) | [`concept-c-1440-dark.png`](screenshots/concepts/concept-c-1440-dark.png) · [`concept-c-1440-light.png`](screenshots/concepts/concept-c-1440-light.png) · [`concept-c-390-dark.png`](screenshots/concepts/concept-c-390-dark.png) |

---

## 2. Análise crítica de cada direção (Hallmark + Godin/Bartlett + Produto Multiplataforma)

### Direção A — Cartografia Viva (Candidata Principal)
- **O que entrega nos primeiros 5 segundos (Godin):** Responde visualmente sem precisar ler parágrafos que o Espectro **não é um quiz comum**, mas um **mapa espacial vivo de 289 ideias**. Quem toca em qualquer ponto da Teia descobre imediatamente uma corrente, seu espectro e entra em contato com a cartografia real.
- **Conformidade Hallmark:**
  - Elimina o card hero roxo com gradiente diagonal (`G2a`/`G3`), a barra arco-íris decorativa no topo e os eyebrows em caixa alta espaçada (`G54`/`G67`).
  - Integra o *Dilema Relâmpago* diretamente entre fios horizontais de 1px na coluna esquerda (`G4` — zero card dentro de card).
  - Troca manchas difusas de neblina (`G29`) por envoltórias convexas nítidas e retículo calibrado legível tanto no tema claro quanto no escuro (`concept-teia-1440-light.png`).
  - Resolve o Comparador (`concept-a-1440-dark-compare.png`) numa matriz de duas colunas separadas por eixo vertical central, sem bordas verdes/âmbar moralizantes.
- **Limitações / tradeoffs:**
  - Na dobra inicial com a Teia ocupando 7/12 da largura, retratos históricos e Polcompballs aparecem apenas no rodapé de inspeção da Teia — risco de subutilizar o acervo iconográfico se não absorvido nas fichas/atalhos abaixo da dobra.

### Direção B — Atlas Editorial
- **Pontos fortes:** Altíssima sofisticação intelectual e autoridade de arquivo político (`concept-b-1440-light.png` parece uma enciclopédia contemporânea da *Nexo* / *Economist Print* / *Princeton Press*). Os retratos reais (Karl Marx, Hannah Arendt) e tabelas sem pílulas respiram com elegância extrema.
- **Limitações / tradeoffs para a Home:**
  - Ocupando o topo como revista impressa estática, reduz o impulso imediato de **interação e jogo psicológico** (Bartlett — recompensa rápida no primeiro toque) e deixa a **Teia (principal ativo autoral)** fora do primeiro contato. Funciona magistralmente como linguagem de **Atlas, Perfis e Bibliografia**.

### Direção C — Laboratório Especular
- **Pontos fortes:** Torna tangível em segundos o conceito multidimensional comparando vetores antagônicos (`Karl Marx × Murray Rothbard: 54%` na mesa óptica). Mostra claramente como o radar de 12 eixos e a matriz de desvios deveriam ser protagonistas visuais, não caixas secundárias.
- **Limitações / tradeoffs para a Home:**
  - Exige conhecimento prévio do usuário sobre os dois polos comparados para fazer sentido no segundo zero; menos acolhedor do que a Teia como porta de entrada geral para quem acabou de abrir o site ou app no Android/Linux/Web. Contudo, oferece o vocabulário exato de precisão para o **Comparador**, **Raio-X** e **aba de Eixos**.

---

## 3. Estudo visual específico da Teia (`Estudo Teia 2D`)

Evidências: [`concept-teia-1440-dark.png`](screenshots/concepts/concept-teia-1440-dark.png) e [`concept-teia-1440-light.png`](screenshots/concepts/concept-teia-1440-light.png) comparadas com `before/webgl/teia-1pane-1440-light.png`.

**Avanços validados:**
1. **Substituição da neblina radial (`G29`) por envoltórias convexas suaves + contorno 1.15px:** As 8 famílias ideológicas agora são legíveis mesmo no papel claro, onde antes sumiam em fumaça difusa.
2. **Retículo calibrado (`-50`, `0`, `+50`, grade decimal ±25/±50/±75%):** Estabelece imediatamente leitura de instrumento científico.
3. **Defeito residual identificado já na inspeção do estudo (`concept-teia-1440-dark.png`):** No quadrante sudeste, o rótulo territorial `"Libertários"` aproxima-se da pílula ativa `"Liberalismo Clássico"`. Na implementação final da Fase 2 (`StudyConstellation`), devemos ocultar/deslocar o nome do espectro quando colidir com o retângulo do foco selecionado e preservar os identificadores de cardinalidade (`AUTORITARISMO ↑`, `ANARQUISMO ↓`) integrados às bordas do retículo em vez de flutuarem como pílulas pesadas dentro da malha no modo 4×.

---

## 4. Recomendação Fundamentada para o Corte Vertical (Fase 2)

**Recomendação:** adotar **Direção A — Cartografia Viva** como arquitetura estrutural mestre do Espectro, **enriquecida seletivamente com duas forças das outras direções**:
1. **Da Direção B (Atlas Editorial):** disciplina de placas de retrato/Polcompball sem bordas de cartão repetitivas e fios horizontais (`1px`) para listas enciclopédicas, perfis e atalhos secundários abaixo da dobra.
2. **Da Direção C (Laboratório Especular):** matriz tabular simétrica no Comparador (`Proximidade por par` sem sub-cards verde/âmbar), ampliação e clareza do Radar comparativo (`>280px` e rótulos legíveis sem mutilação arbitrária).

**Por que essa combinação vence:**
- Entrega a **Vaca Roxa** (a Teia viva de 289 correntes) no segundo zero da Home.
- Elimina simultaneamente todos os vícios Floor e Reflex críticos da linha de base (hero encaixotado roxo, listras arco-íris, cards dentro de cards, neblina invisível no tema claro, caixas morais verde/âmbar no Comparador).
- Mantém 100% da viabilidade multiplataforma Flutter (`Web, Android, Linux, Windows`) com pintura vetorial determinística e baixa sobrecarga de layout.
