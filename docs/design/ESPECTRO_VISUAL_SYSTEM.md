# Sistema Visual Espectro — Arquitetura "Cartografia Viva" (v2)

**Status:** Sistema de referência da Fase 2 (branch `visual/art-direction-v2`)  
**Escopo multiplataforma:** Flutter (`Web CanvasKit`, `Android`, `Linux`, `Windows`) + Shell semântico HTML (`web/index.html`)

---

## 1. Tese Central e Personalidade Visual

O Espectro não é um aplicativo genérico de quiz SaaS: é um **observatório cartográfico multidimensional da história das ideias políticas**.  
Toda decisão visual responde a três regras derivadas da auditoria Hallmark + psicologia de produto:

1. **O dado e o mapa são a interface.** Em vez de esconder a Teia e os gráficos atrás de cartões escuros ou pílulas decorativas, o mapa cartográfico, os fios de eixos e os espécimes reais ocupam a superfície direta.
2. **Contenção máxima de 1 nível (`Gate 4`).** Nunca colocar um cartão com borda e sombra dentro de outro cartão com borda e sombra. Separações internas acontecem por **fios estruturais de 1px** (`p.line`) e contraste tipográfico/respiro.
3. **Sem moralismo cromático nem fantasias de código.** Verde/âmbar não significam "certo/errado" em comparações ideológicas (usa-se contraste de polos `poleLeft` vs `poleRight`); texto monoespaçado (`IBMPlexMono`) só aparece em **coordenadas, porcentagens, escalas e contagens numéricas** (`Gate 64`), jamais como fantasia de eyebrow em caixa alta espaçada (`Gate 54` / `Gate 67`).

---

## 2. Sistema Cromático (Tokens OKLCH-equilibrados sem `#000`/`#fff` puros)

Os tokens vivem centralizados em `lib/theme.dart` (`EspectroPalette.light` e `EspectroPalette.dark`) e refletem o papel mineral/calcário no claro e a mesa astronômica/cartográfica no escuro:

| Token | Papel | Tema Claro (Papel Mineral) | Tema Escuro (Observatório) | Justificativa Hallmark |
| --- | --- | --- | --- | --- |
| `canvas` | Fundo global sem costura | `#EFECE4` (calcário quente) | `#0A0F17` (ardósia abissal) | Evita `#FFFFFF` / `#000000` puros (`Gate 7a/b`) e reduz fadiga ocular. |
| `surface` | Plano analítico principal | `#FAF8F3` | `#111824` | Contraste nítido de superfície (`≥1.08` de elevação luminosa no escuro, sem parecer "buraco"). |
| `surfaceMuted` | Poços discretos / trilhos | `#E4E0D6` | `#172131` | Usado apenas para inputs, trilhos e estados ativos discretos. |
| `ink` | Tipografia primária & títulos | `#131722` | `#F1F3F8` | Garante `>12:1` de contraste (`Gate 40`). |
| `inkSoft` | Corpo secundário & subtítulos | `#464E5E` | `#AAB5C7` | Legibilidade ≥ `5.5:1` em ambos os modos. |
| `line` | Fios estruturais de `1px` | `#D4D0C4` | `#243043` | Substitui pilhas de caixas por grades precisas. |
| `accent` | Foco cartográfico & seleção | `#453796` (índigo mineral) | `#9D90FA` | Uso restrito (`≤5%` do viewport, `Gate 23`) — nunca fundo de seção inteira. |
| `accentAction` | Ação primária única | `#182232` (ou `#9D5B12`) | `#E5A64B` (âmbar de bússola) | Uma única voz de botão preenchido por tela (`F4`). |
| `poleLeft` / `poleRight` | Polaridade de eixos sem viés | `#176B78` / `#B85A25` | `#4CC4BE` / `#E5A64B` | Teia/Comparador usam o par azul-petróleo vs cobre-âmbar em vez de verde vs vermelho. |

---

## 3. Tipografia e Hierarquia (`Gate 64 / 67 / 75`)

- **Display & UI:** `IBMPlexSans` (weights `500`, `600`, `700`, `800`).
  - Headline inicial: `42–46px` no desktop (`-1.15` tracking, altura `1.07`), `28–32px` no mobile.
  - Título de seção: `22–28px` (`-0.5` tracking) sempre com respiro superior ≥ `1.5×` o inferior (`Gate 71`).
  - Corpo padrão: `14–15.5px`, altura `1.48–1.55`.
- **Tabular & Coordenadas:** `IBMPlexMono` com `FontFeature.tabularFigures()` restrito a:
  - Porcentagens (`70%`, `82%`), deltas (`Δ 24 pp`), escalas da Teia (`−50`, `0`, `+50`), contadores de acervo (`289`, `757`).
- **Proibições absolutas:**
  - Nenhum rótulo decorativo em `UPPERCASE` + `letterSpacing >= 0.8` antes de títulos (`Gate 54` + `Gate 67`).
  - Nenhuma concatenação artificial de 3+ metadados por ponto médio (`A · B · C` — `Gate 63`) nem setas coladas dentro de botões (`Ver mapa →` vira verbo claro + ícone apenas quando direcional).

---

## 4. Escada de Superfícies (Surface Ladder contra Pilhas de Cartões)

Para matar o aspecto de dashboard gerado por IA (`Gate 3`, `Gate 4`, `Gate 9`):
1. **Degrau 0 — Canvas direto + Espaço negativo intencional:** Seções abrem direto no fundo com títulos grandes e largura preenchida (`10–12` colunas).
2. **Degrau 1 — Fio estrutural (`1px solid p.line`):** Separação entre manifesto, dilema em linha, matriz do comparador e cabeçalhos de tabela.
3. **Degrau 2 — Câmara do instrumento (`Border.all(p.line)`, raio contido `10–12px`):** Reservada exclusivamente ao palco da Teia, quadros de leitura ativa e painéis interativos principais.
4. **Proibido:** empilhar 3 níveis de borda arredondada (`Card > Container > Pill`) ou repetir listras arco-íris no topo de caixas secundárias.

---

## 5. Visualizações de Dados (`data-viz.md` adaptado)

- **Teia (`StudyConstellation` & prévia Home):**
  - Coordenadas canônicas (`StudyConstellationGeometry.position`) intocadas.
  - Territórios desenhados com envoltórias convexas suaves (`TeiaCartographicLayer.computeTerritories`) com preenchimento sutil (`5.5%–7%`) e contorno nítido (`1.15px`), substituindo manchas difusas invisíveis no tema claro.
  - Retículo calibrado com linhas secundárias (`±25%`, `±50%`, `±75%`), eixos ortogonais centrais e marcações numéricas (`−50`, `+50`).
  - Modo **4 Painéis (2×2)** no desktop: controle de legenda compartilhado sem cobrir o quadrante 3, moldura nítida do painel ativo, e marcadores cardinais contidos junto às bordas sem colisão com pontos/rótulos (`Gate 73`).
- **Radar Comparativo & 12 Eixos:**
  - Dimensão mínima útil `260–320px` em comparações e abas principais; rótulos completos ou abreviações inequívocas em escala legível (`≥10.5px` / `≥11px`), anel neutro de `50%` visualmente tracejado quando assim descrito.
- **Comparador Lado a Lado (`Proximidade por par`):**
  - Substitui a barra plana e os dois sub-cartões verde/âmbar por uma **matriz especular de duas colunas** separadas por fio central vertical (`1px`): à esquerda as convergências reais (`p.poleLeft`), à direita os eixos de maior tensão (`p.poleRight`), encabeçados por figura percentual tabular.

---

## 6. Retratos Históricos, Polcompballs e Acessibilidade

- **Fotografias reais e Polcompballs:** Preservar `StudyIdentityAvatar` com recorte limpo de retrato (`daguerreótipos`) ou emblema vetorial/PNG transparente em moldura discreta (`1px` na cor do espectro), sem glows coloridos (`boxShadow` difuso colorido em torno de avatares proibido, `Gate 29`).
- **Redução de movimento (`MediaQuery.disableAnimationsOf`):** Nenhuma animação contínua em segundo plano quando desativada; voo da câmera da Teia salta diretamente ao destino; transição de páginas apenas `Fade + micro-slide` respeitando acessibilidade.
- **Portabilidade e Escalabilidade de Texto (`2.0×`):** Todas as divisões `split / row` devem degradar para `Column` limpa com `TextScaler` acima de `1.35×` ou largura `< 880px`, garantindo 0 overflows em Android/Linux/Windows/Web.
