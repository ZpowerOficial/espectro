# Enriquecimento documental de correntes e personalidades — 13/11/2026

## 1. O que mudou

Esta rodada amplia a documentação já existente sem criar URL, obra ou citação nova.

| Recorte | Antes | Depois |
| --- | ---: | ---: |
| Dimensões calibradas de correntes com verbete documental | 1.176 de 2.802 | 2.802 de 2.802 |
| Verbetes dimensionais nas 289 correntes | 1.213 | 2.839 |
| Correntes com as 18 dimensões documentadas | 1 | 123 |
| Personalidades do núcleo com `coordinateNotes` | 68 de 129 | 129 de 129 |
| Correntes com ao menos uma relação documentada | 47 de 289 | 150 de 289 |
| Personalidades do núcleo com ao menos uma relação | 79 de 129 | 129 de 129 |
| Relações no arquivo estendido | 2.006 | 2.477 |

As 139 correntes ainda sem relação não receberam vínculo por proximidade geométrica, nome parecido ou família editorial. Quando não há documento ou entidade correspondente no acervo, a ausência permanece explícita.

## 2. Como a documentação foi ampliada

### 2.1 Correntes

Cada corrente já possuía uma nota doutrinária por eixo e por tríade, mas o verbete documental (`editorialBasis.dimensionEvidence`) cobria apenas parte das dimensões calibradas. A rodada transporta essa nota para o verbete, ancorada na fonte que a própria ficha já declara:

- **879 evidências de eixo** e **747 evidências de tríade** em 152 fichas;
- localizador temático explícito, por exemplo `Socialismo Evolucionário: leitura temática do eixo Propriedade Econômica e Mercado`;
- justificativa igual à nota doutrinária já revisada, sem gerar texto novo sobre a fonte;
- status próprio **`editorial_synthesis`**, distinto de `primary_supported` e de `editorial_reconstruction`;
- nova limitação registrada em cada ficha: a síntese indica o eixo temático, não uma citação literal página a página.

O novo status é exibido no perfil como **“Síntese editorial e fonte registrada”**, com aviso de que o autor não respondeu ao questionário do Espectro. O contador da aba de dimensões passou a separar leitura primária, reconstrução e síntese.

Também foram preenchidos títulos de fonte ausentes a partir de URLs já nomeadas em outros verbetes do acervo: 329 → 342 títulos para 378 URLs. Nenhum título foi inventado.

### 2.2 Personalidades do núcleo

As 129 personalidades já tinham evidência documental, mas nem sempre a justificativa aparecia nas notas de coordenada usadas pelo perfil, pelo motor e pela comparação. Foram adicionadas **218 `coordinateNotes`**, cobrindo agora as 129 fichas. Nenhuma nova evidência primária foi declarada: as notas apenas refletem justificativas já existentes.

## 3. Como as relações foram ampliadas

Foram adicionadas **471 relações** com origens rastreáveis:

| Origem | Relações |
| --- | ---: |
| Fonte da corrente atribuída a uma personalidade do acervo | 111 |
| Obra do acervo citada no título da fonte | 65 |
| Mesma URL registrada por duas correntes | 68 |
| Leitura primária compartilhada na lista curada | 131 |
| Leitura primária de obra na lista curada | 30 |
| Tradição editorial para personalidade do núcleo sem relação | 54 |
| Debate editorial para personalidade do núcleo sem relação | 12 |

As relações de fonte compartilhada declaram expressamente que compartilhar documento não prova acordo, influência ou filiação. As conexões das personalidades do núcleo são apresentadas como escolha editorial de leitura, ancoradas na fonte primária da própria ficha, e não como autodeclaração. As relações da lista de leituras vêm de `lib/domain/models/study_sources.dart`, que já associava explicitamente as entidades sob a mesma fonte.

## 4. Arquivos alterados

- `assets/data/ideological_currents.json`: 1.626 sínteses editoriais, metadados de fonte e lote `documentation-synthesis-2026-11-13`.
- `assets/data/personalities.json`: 218 notas de coordenada e metadados de fonte.
- `assets/data/study_relations_extended.json`: 471 relações documentadas.
- `lib/domain/models/study_editorial_basis.dart`: suporte ao estado `editorial_synthesis`.
- `lib/ui/features/atlas/study_profile_screen.dart`: rótulo, aviso e contador do novo estado.
- `tool/curation/enrich_currents_documentation.py`: rodada documental reprodutível e idempotente.
- `tool/curation/enrich_study_relations.py`: gerador de relações reprodutível e idempotente.

## 5. Limites desta rodada

- A síntese editorial não é leitura primária direta nem resposta reconstruída ao questionário. Ela documenta a direção doutrinária a partir da fonte registrada, mas não certifica cada número.
- 139 correntes continuam sem relação porque o acervo não contém personalidade, obra, leitura compartilhada ou documento comum que permita uma conexão rastreável. Criar uma relação por semelhança numérica contrariaria o protocolo do catálogo.
- As personalidades do núcleo continuam com 9 fichas em 18/18 dimensões documentadas. A rodada não converte notas editoriais em evidência primária para atingir uma contagem.
- O inventário `docs/primary-coverage-audit-2026-11-05.json` permanece como fotografia datada da revisão anterior. Os números desta rodada são os do quadro acima; o campo `documentationBatch` identifica as fichas enriquecidas.
- Não houve revisão integral de cada texto primário nesta rodada. O enriquecimento reutiliza fontes e notas já registradas.

## 6. Reprodução e verificação

```bash
python3 tool/curation/enrich_currents_documentation.py
python3 tool/curation/enrich_study_relations.py
flutter analyze --no-pub
flutter test --no-pub \
  test/domain/primary_review_test.dart \
  test/domain/study_sources_test.dart \
  test/domain/personality_reading_supplements_test.dart \
  test/domain/catalog_expansion_test.dart \
  test/domain/brazilian_personalities_test.dart
```

Resultado desta rodada: `flutter analyze` sem problemas e 22 testes focados aprovados. Os scripts são idempotentes: uma segunda execução não duplica evidências, limitações ou relações.
