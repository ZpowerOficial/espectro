# Calibração de Realismo e Redesenho Mobile da Teia — 2026-11-09

## 1. Contexto e Motivação
Na versão anterior, correntes e personalidades reconstruídas a partir de recortes bibliográficos breves sofriam de "efeito teto": com apenas 2 afirmações Likert por eixo, posições fortemente afirmativas resultavam em scores $\mu = \pm 1.0$, traduzindo-se visualmente em 100% ou 0% no gráfico. Em contrapartida, referências consolidadas como o 12Axes apresentam distribuições mais fluidas e empíricas, com correntes e pensadores concentrados em faixas como 73%, 81%, 86%.

Além disso, na visualização móvel (Android), a tela de teias múltiplas tentava dispor as 4 teias em uma grade 2×2, gerando canvases minúsculos (180×200 px), ininteligíveis ao toque e com sobreposição da legenda flutuante e do drawer de inspeção.

---

## 2. Camada de Calibração de Realismo (`RealismCalibration`)

Implementada em [`lib/domain/engine/realism_calibration.dart`](file:///home/zpower/Downloads/espectro/lib/domain/engine/realism_calibration.dart):

### 2.1 Eixos Bipolares
Para cada coordenada contínua $\mu \in [-1.0, 1.0]$:
$$cal(\mu) = \text{sign}(\mu) \cdot \left(\frac{\tanh(1.25 \cdot |\mu|)}{1.25}\right) \cdot 0.92 \cdot (1 - 0.10 \cdot \sigma)$$
- **Preservação estrita**: Monotonicidade, simetria polar e o zero exato ($\mu = 0$) são rigorosamente mantidos.
- **Faixas intermediárias**: Valores moderados ($|\mu| \le 0.35$) sofrem alteração desprezível.
- **Teto suave**: Valores extremos ($|\mu| \ge 0.85$) convergem para a faixa de $0.65$ a $0.81$, resultando em porcentagens fluidas de **73% a 88%**, sem atingir 100%.
- **Heterogeneidade interna ($\sigma$)**: Correntes com maior dispersão interna têm seus valores ligeiramente mais atenuados.

### 2.2 Tríades de Valores
Para composições relativas de 3 vértices:
$$c'_i = (1 - \lambda) c_i + \frac{\lambda}{3}, \quad \lambda \in [0.15, 0.26]$$
Evita concentrações artificiais de 95%+ em um único vértice sem alterar a preponderância relativa das prioridades axiológicas.

### 2.3 Garantia de Integridade
- **Avaliação do Usuário**: A avaliação pessoal do usuário **NÃO** é calibrada; seus scores Likert e ponderações de resposta refletem estritamente as escolhas do usuário no teste.
- **Armazenamento de Catálogo**: Os valores brutos autorais são mantidos em `StudySubject.axes` para auditoria e cálculo exato de proximidade geométrica. A interface consome `StudySubject.displayAxes` e `displayTriangles`.

---

## 3. Cobertura de Espectros e Relações do Catálogo

1. **Países (`assets/data/countries.json`)**:
   - Atribuição documental de `spectrumId` para todos os 81 modelos de país e regimes históricos (`radical_left`, `left`, `center`, `right`, `libertarian`, `anarchist`, `third_position`).
2. **Partidos e Movimentos (`assets/data/parties_movements.json`)**:
   - Atribuição de `spectrumId` para as legendas brasileiras e internacionais.
3. **Relações Cruzadas (`assets/data/study_relations_extended.json`)**:
   - Vínculos documentados conectando regimes históricos (ex.: Suécia à social-democracia, Liberland ao minarquismo, Zapata ao anarquismo social) às respectivas correntes.

---

## 4. Redesenho da Teia no Android / Mobile

Implementado em [`lib/ui/features/atlas/study_map_screen.dart`](file:///home/zpower/Downloads/espectro/lib/ui/features/atlas/study_map_screen.dart):
- **Desktop ($\ge 800$ px)**: Preservada a grade comparativa simultânea (Row / 2×2).
- **Mobile ($< 800$ px)**:
  - Exibição de **uma teia em tamanho total** (100% da largura útil), permitindo zoom, pan e leitura nítida de rótulos.
  - **Barra de Abas Segmentada**: Chips horizontais estilizados (`Teia 1`, `Teia 2`, etc.) com insígnia da projeção ativa (ex.: `Econ × Pod`), botão de fechar $(\times)$ na teia ativa e botão `+ Teia`.
  - **Navegação fluida**: Transição via `PageView` com gesto de swipe ou toque direto nas abas.
  - **Sincronização**: A seleção de entidades (`_selected`) e filtros (`_query`, `_spectrum`) mantém-se instantaneamente sincronizada entre todas as teias.
  - **Drawer de Inspeção Dinâmico**: Puxador tátil (*drag handle*) no topo permitindo alternar suavemente entre visualização compacta (38% de altura) e expandida (72% de altura), sem ocluir permanentemente o mapa.
