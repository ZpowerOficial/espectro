# Relatório de Completude e Expansão em 3 Níveis — Personalidades (2026-11-07)

## 1. Resumo executivo

1. **Completude numérica integral do núcleo base (`assets/data/personalities.json`)**:
   - **129 / 129 personalidades** do catálogo base possuem agora **18 / 18 dimensões numéricas** preenchidas (12 eixos bipolares + 6 tríades de valores; `missingNumericalDimensions = 0`).
   - Inclui a integração de `frederick_douglass`, a conclusão da rodada 5 de reconstruções editoriais (`personality_round5_complete.py`, totalizando 74 perfis reconstruídos e 1.420 respostas âncora reproduzíveis pelo motor) e suplementos partidários (`party_round5_supplements.py`).
2. **Expansão para milhares de personalidades (`2.044` personalidades únicas / `2.782` verbetes no Atlas)** sob arquitetura explícita de **3 Níveis de Evidência** e **carregamento sob demanda em shards (`shard_00`..`shard_15`)**:
   - **Nível 1 (`tier1_editorial_reconstruction` — 68 personalidades)**: fichas com trechos primários conferidos (`primary_supported`) e/ou respostas reconstruídas item a item (`editorial_reconstruction`).
   - **Nível 2 (`tier2_institutional_record` — 1.365 parlamentares federais brasileiros)**: deputados federais e senadores pontuados **exclusivamente** a partir de **votações nominais de plenário (`Sim` / `Não`)** nos Dados Abertos da Câmara dos Deputados (32 votações de texto-base entre 2003 e 2024) e do Senado Federal (10 votações nominais entre 2017 e 2024), somando **13.145 dimensões documentadas (`institutional_vote`)**. Nenhuma posição foi inferida por sigla partidária e as **11.425 dimensões não votadas** permanecem explicitamente em branco (sem preenchimento artificial com `0.0`).
   - **Nível 3 (`tier3_preliminary_curation` — 611 personalidades: 61 legadas do núcleo + 550 estendidas globais e brasileiras)**: estadistas, filósofos, juristas e economistas da Antiguidade à atualidade no Brasil, Américas, Europa, Ásia, Oriente Médio, África e Oceania, identificados com selo explícito de *Curadoria preliminar* e status dimensional `unreviewed`.

---

## 2. Arquitetura de carregamento sob demanda (Lazy Sharding)

Para manter a inicialização rápida no Flutter Web mesmo superando 2.000 personalidades:

- **Índice leve (`assets/data/personalities_extended.json`)**: armazena metadados biográficos, espectro, coordenadas observadas e o ponteiro `editorialBasis.dossierShard` (`shard_00`..`shard_15`), omitindo `dimensionEvidence`, `coordinateNotes` e `compositionNotes` redundantes.
- **Shards de evidência (`assets/data/dossiers/shard_00.json`..`shard_15.json`)**: carregados sob demanda e cacheados em memória por `AppData.loadDossierEvidence(...)` apenas quando o usuário abre `StudyProfileScreen` de um verbete estendido.
- **Interface (`AtlasExplorerScreen` e `StudyProfileScreen`)**:
  - Contagem de espectros pré-computada em $O(N)$ fora do construtor da lista virtualizada.
  - Filtros dedicados de nível de evidência (`Todos os níveis`, `Nível 1 · Reconstrução primária`, `Nível 2 · Votações nominais`, `Nível 3 · Curadoria preliminar`) ao explorar `Personalidade`.
  - Selo transparente de nível na visão geral, na aba *Dimensões* (`Votações nominais e registro oficial` para `institutional_vote`) e na aba *Fontes e limites*.

---

## 3. Quadro consolidado de cobertura (`docs/primary-coverage-audit-2026-11-05.json`)

| Recorte | Verbetes | Numericamente completos (18/18) | Dimensões ausentes | Observação metodológica |
| --- | ---: | ---: | ---: | --- |
| `personality_core` | 129 | 129 | 0 | 100% dos 12 eixos e 6 tríades preenchidos |
| `personality_tier1` | 68 | 68 | 0 | Suporte primário por trecho e/ou reconstrução item a item |
| `personality_tier2` | 1.365 | 0 | 11.425 | 13.145 dimensões por voto nominal oficial; não votadas ficam ausentes |
| `personality_tier3` | 611 | 611 | 0 | 61 do núcleo legado + 550 da expansão global/brasileira (`unreviewed`) |
| **Total `personality`** | **2.044** | **679** | **11.425** | **Zero IDs duplicados; 8 espectros representados** |
| **Total geral do Atlas** | **2.782** | **1.028** | **16.856** | Correntes, personalidades, obras, partidos, história e países |

---

## 4. Pipeline reprodutível

```bash
# 1. Reconstruções editoriais (Nível 1)
python3 tool/curation/build_editorial_reconstructions.py
flutter test test/domain/editorial_reconstruction_test.dart \
  --dart-define=UPDATE_EDITORIAL_RECONSTRUCTIONS=true \
  --plain-name 'editorial coordinates reproduce'

# 2. Catálogo estendido (Nível 2 nominal + Nível 3 curadoria preliminar) e shards 00..15
python3 tool/build_extended_personalities.py

# 3. Integração primária e sincronização da auditoria documental completa
python3 tool/integrate_primary_readings.py
```
