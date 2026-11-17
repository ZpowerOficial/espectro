# Complementação individual de personalidades — 05/11/2026

Foram complementadas 56 dimensões em 20 personalidades, mediante 144 respostas editoriais aos itens do próprio Espectro. As respostas passam pelo motor nativo e ficam consultáveis com fonte, localizador, justificativa e ressalvas. A base autoral completa desta etapa soma 614 respostas, incluindo as reconstruções das rodadas anteriores.

Esta rodada amplia a [rodada brasileira anterior](personalidades-brasileiras-e-completude-2026-11-05.md). Os números abaixo substituem seu saldo de completude. Não declara revisão integral do catálogo.

## Fichas revistas

| Personalidade | Dimensões complementadas |
|---|---|
| Platão | Moral |
| Aristóteles | Representação |
| Proudhon | Economia |
| John Stuart Mill | Liberdade Individual |
| Friedrich Engels | Imigração; Economia |
| Emma Goldman | Comércio; Tecnologia |
| Errico Malatesta | Representação; Imigração; Comércio; Tecnologia; Governo |
| Benjamin Tucker | Representação; Imigração; Tecnologia; Governo |
| Thomas Paine | Imigração; Tecnologia |
| Anton Pannekoek | Imigração |
| James Connolly | Imigração; Religião |
| James Guillaume | Representação; Imigração; Comércio; Tecnologia; Governo |
| Alexander Berkman | Representação; Imigração; Comércio; Tecnologia; Governo |
| Benjamin Constant | Estrutura; Imigração; Religião; Tecnologia |
| Jair Bolsonaro | Estrutura; Poder; Diplomacia; Comércio; Tecnologia; Governo; Igualdade |
| Lysander Spooner | Representação; Imigração; Religião; Tecnologia |
| Hans-Hermann Hoppe | Religião; Tecnologia |
| Milton Friedman | Imigração; Religião |
| Herbert Spencer | Estrutura; Representação; Imigração; Religião |
| Karl Kautsky | Imigração |

## Distinções preservadas

- A carta de Engels a Sorge, de 1893, critica isolamento linguístico de militantes emigrados. Não recebe automaticamente a posição cultural reconstruída de Marx.
- Berkman combina intercâmbio voluntário com autonomia material das comunidades. Os itens de comércio selecionados registram dependência e produção alimentar, sem transformá-lo em defensor de tarifas estatais.
- O programa de Bolsonaro de 2018 combina descentralização, rigor penal e renda mínima. O discurso de Davos sustenta abertura comercial e desenvolvimento tecnológico. São posições declaradas, não certificação de execução ou de toda sua trajetória. Imigração e outras dimensões continuam pendentes.
- A entrevista de Milton e Rose Friedman contém discordâncias expressas. As falas de Rose sobre assimilação não foram atribuídas a Milton; preservação cultural não é confundida com sua posição condicional sobre fronteiras e assistência social.
- Hoppe declara agnosticismo pessoal e valoriza a cultura cristã. A leitura separa isso da defesa de desenvolvimento técnico; suas generalizações históricas sobre etnia e gênero são identificadas como teses do autor, não fatos certificados pelo Espectro.
- Spooner e Tucker sustentam inovação, mas divergem sobre propriedade intelectual. A complementação não os converte numa mesma doutrina.
- Spencer está delimitado à edição de 1851. A edição abreviada posterior não substitui silenciosamente esse recorte.

A defesa de posse em Proudhon, a democracia restrita de Aristóteles e a organização anarquista têm encaixe imperfeito nos polos existentes. Essas limitações acompanham as coordenadas. A tríade Governo continua sem um vértice que represente adequadamente anarquia.

## Fontes e acesso

O arquivo [personality_reading_supplements.py](../tool/curation/personality_reading_supplements.py) mantém as fontes, itens, respostas e interpretações de cada dimensão. Os perfis não foram copiados de um concorrente nem ajustados para produzir uma afinidade vencedora específica.

O plano de Bolsonaro foi lido em cópia arquivada de 81 páginas, vinculada ao candidato TSE `280000614517` e ao documento histórico `proposta_1534284632231.pdf`. O SHA-256 conferido é `35a67dff4ebc802db20b2f59723c3d32e52146c896caf923456b00059e2577eb`. O endereço histórico do TSE não ficou acessível nesta consulta; a ficha informa a procedência da cópia utilizada. O discurso de Davos está em PDF publicado pela FUNAG. Sumários automáticos e introduções de terceiros não foram tratados como declarações dos autores.

## Saldo verificável

| Categoria | Fichas | Com 18 coordenadas utilizáveis | Coordenadas ainda ausentes | Com 18 dimensões documentadas |
|---|---:|---:|---:|---:|
| Correntes | 289 | 83 | 2.656 | 0 |
| Personalidades | 128 | 102 | 113 | 7 |
| Países e modelos | 80 | 80 | 0 | 0 |
| Partidos e movimentos | 110 | 56 | 806 | 0 |
| Episódios históricos | 94 | 47 | 687 | 0 |
| Obras | 165 | 71 | 1.378 | 0 |
| Total | 866 | 439 | 5.640 | 7 |

Há 342 dimensões com leitura primária direta e 193 com reconstrução editorial documentada. Sete antigas leituras diretas passaram à categoria reconstrução nesta rodada: seus números agora derivam de respostas atribuídas ao questionário. Isso não significa perda das referências.

Fora das obras, permanecem 4.262 coordenadas ausentes, além de posições antigas ainda não auditadas. Nas obras, ausência de tema pode ser legítima. A revisão integral pedida ainda não foi concluída.

O inventário e a fila documental agora também listam `missingNumericalDimensions` para cada ficha e totais por categoria. A definição coincide com as coordenadas utilizáveis no aplicativo; valores de correntes com relevância zero não contam como preenchimento. Os relatórios são gerados em [primary-coverage-audit-2026-11-05.json](primary-coverage-audit-2026-11-05.json) e [primary-review-queue-2026-11-05.json](primary-review-queue-2026-11-05.json).

## Validação

A suíte completa passou com 220 testes após atualizar uma expectativa antiga que exigia o campo Poder vazio em Bolsonaro. O novo teste adicional compara o inventário com as coordenadas efetivamente utilizáveis nas 866 fichas; ele também passou. A análise estática e a compilação web passaram. Os seis catálogos empacotados na versão web tiveram seus hashes comparados com os arquivos atuais, todos iguais.

A integração repetida estabilizada foi conferida por hashes e produziu arquivos idênticos. O navegador confirmou respostas e acesso às fontes em oito cenários: Bolsonaro, Friedman, Hoppe e Berkman, em 390 e 1440 px, sem erros de página. O primeiro script precisou de rolagem para alcançar dimensões reconstruídas abaixo da tela inicial; na rodada seguinte, Berkman desktop expirou ao iniciar a árvore acessível e passou em repetição isolada. A evidência e essas falhas iniciais estão em [validation.json](qa/personality-readings-2026-11-05/validation.json).

Esses testes verificam integridade, cálculo e acesso na interface; não certificam precisão histórica ou equivalência psicométrica. Dispositivo físico não testado nesta rodada.
