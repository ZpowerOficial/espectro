# Personalidades brasileiras e complementação do catálogo

> Registro da rodada anterior. O saldo atualizado está em [revisao-personalidades-2026-11-05.md](revisao-personalidades-2026-11-05.md).

Foram adicionados Raphaël Lima, Gilson Marques, Peter Turguniev (Ancapsu) e Jones Manoel. Cada ficha contém 12 eixos, seis tríades e 60 respostas atribuídas editorialmente, com fontes, localizadores e justificativas consultáveis. O catálogo passa a 128 personalidades e 866 fichas no total.

As respostas são reconstruções, não entrevistas realizadas pelo Espectro. As intensidades continuam editoriais. Foram preservadas diferenças relevantes: fé e cultura familiar no recorte de Raphael de 2026; laicidade, livre mercado, rigor penal e oposição ao aborto na agenda de Gilson; associação voluntária e contratos no recorte de Peter; reestatização, direitos sociais e dissuasão nuclear sob controle civil no programa de Jones. Não se atribui a alguém todo o programa de seu partido ou os textos de colaboradores de um canal.

## Fontes e limites

- Raphael: entrevista de 2017 ao Boletim da Liberdade e entrevista de 2026 à Free Cities Foundation. A transcrição mais recente é automática e editada, com possibilidade de erros de atribuição informada pelo publicador.
- Gilson: site oficial, autodefinição em debate parlamentar e intervenções identificadas sobre ensino, laicidade, impostos e tecnologia. Foram consideradas suas falas, não as de outros deputados presentes. Diplomacia e parte da imigração têm sustentação temática mais fraca e são identificadas como inferências.
- Peter: documento fundador do PICA 00, que o identifica como fundador inicial; a página oficial de canais serve para identificação. O PDF foi consultado pela cópia indexada. A requisição HTTPS direta falhou por certificado incompatível com o domínio em 05/11/2026; disponibilidade atual não confirmada. Não se desativou TLS nem se publicou uma cópia integral sem licença.
- Jones: programa da candidatura, 69 páginas, e entrevista de janeiro de 2026. Propostas de mandato não são apresentadas como políticas realizadas, e suas afirmações factuais não são automaticamente verificadas por serem primárias.

A pesquisa em navegador usou MCP REA para os sites de Gilson e Jones. A evidência e as limitações de acesso estão em `docs/qa/brazilian-profiles-2026-11-05/source-access.json`.

## Complementação além das novas fichas

Foram reconstruídas onze dimensões que estavam numericamente ausentes: duas do anarcocapitalismo, cinco do comunismo no recorte marxiano, duas do socialismo marxista, uma do liberalismo clássico no recorte de Mill e uma do modelo constitucional sul-africano. Elas derivam de cinquenta respostas editoriais adicionais e não são cópias integrais dos vetores de personalidades.

Essas quatro correntes agora têm 12 eixos e seis tríades parametrizados. Todos os 80 modelos de país também têm essas 18 posições numéricas. Isso **não** declara suas outras dimensões integralmente revisadas: a documentação de cada campo continua com seu próprio estado.

O gerador passou a aceitar complementações delimitadas. Ele exporta somente as dimensões revisadas e a integração preserva as demais. Dimensões não observadas não são transformadas em centros artificiais pelo resultado padrão do motor.

## Saldo real

| Categoria | Fichas | Com 18 posições numéricas | Posições ainda ausentes |
|---|---:|---:|---:|
| Correntes | 289 | 83 | 2.656 |
| Personalidades | 128 | 85 | 169 |
| Países e modelos | 80 | 80 | 0 |
| Partidos e movimentos | 110 | 56 | 806 |
| Episódios históricos | 94 | 47 | 687 |
| Obras | 165 | 71 | 1.378 |
| Total | 866 | 422 | 5.696 |

Há 349 dimensões identificadas como leitura primária direta e 137 como reconstrução editorial documentada. Seis antigas leituras diretas dos suplementos passaram à categoria reconstrução porque agora seus números dependem de respostas atribuídas, mantendo as fontes vinculadas. A base editorial soma 470 respostas: 420 de sete personalidades e cinquenta dos suplementos.

A revisão de todas as fichas continua pendente. Preencher coordenadas não certifica precisão histórica, equivalência psicométrica ou adequação de todo constructo. Obras podem legitimamente permanecer parciais quando não abordam determinado tema. O inventário e a fila completa foram atualizados em `docs/primary-coverage-audit-2026-11-05.json` e `docs/primary-review-queue-2026-11-05.json`.

## Reprodução

As novas leituras estão em `tool/curation/brazil_personalities.py` e `tool/curation/core_dimension_supplements.py`. O arquivo autoral principal continua sendo `tool/curation/build_editorial_reconstructions.py`; a geração passa pelo motor Flutter e a integração por `tool/integrate_primary_readings.py`, conforme o protocolo da rodada anterior. As sete reconstruções completas exigem 60 respostas; suplementos exigem os dois chaveamentos de cada eixo ou dois itens por vértice de cada tríade incluída.

## Validação

218 testes aprovados na suíte completa. Análise estática sem problemas e compilação web concluída. Os quatro novos perfis foram abertos em 390 e 1440 px, com expansão das respostas, rolagem até as fontes e nenhum erro de página nos oito cenários. A integração repetida produziu arquivos idênticos. Relatório de validação: `docs/qa/brazilian-profiles-2026-11-05/validation.json`.

Dispositivo físico não testado nesta rodada. Os testes verificam integridade, cálculo e navegação; não certificam a verdade histórica das inferências. Fora das obras, ainda há 4.318 posições numéricas ausentes, além da revisão documental de posições preexistentes.
