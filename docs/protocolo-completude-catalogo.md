# Protocolo de completude do catálogo

Tipo: revisão de escopo documental, com extração por dimensão e registro de pendências. Não é uma revisão sistemática de toda a literatura histórica nem validação psicométrica.

## Unidade de análise

Cada ficha mantém sua unidade: corrente e variante, personalidade e período, país e regime/período, partido e programa datado, episódio histórico, ou obra específica. Uma posição do autor em outro livro não se torna posição de uma obra que não trata dela. Não se confunde programa, lei, autodescrição, implementação e avaliação histórica posterior.

## Busca e seleção

- Português, inglês e idioma do original quando acessível; intervalo temporal definido pela própria ficha.
- Prioridade: constituições, programas, documentos oficiais, discursos e obras assinadas por participantes; edições identificadas e traduções institucionais.
- Fontes secundárias acadêmicas servem para contextualizar, identificar controvérsias e localizar documentos. Não são reclassificadas como primárias.
- Fontes de descoberta: bibliografias institucionais, arquivos públicos, acervos de autores, Project Gutenberg, GHI/GHDI, Avalon/Yale, Marxists Internet Archive, Santa Sé, repositórios de partidos e editoras. Não usar snippets de busca como evidência de conteúdo.
- Excluir como sustentação direta: apenas ficha de venda, sumário automático, texto indisponível, link não lido, material de outro período/unidade ou reconstrução de respostas que o autor nunca deu. Respostas reconstruídas podem entrar como interpretação editorial identificada, nunca como declaração literal.
- Registrar URL, autoria, título, edição/data, método de acesso, trecho/localizador, interpretação e limites. Deduplicar por documento/edição e URL canônica, sem fundir versões conflitantes.

## Extração

Para cada um dos 12 eixos e 6 grupos de valores: localizar evidência favorável a cada polo/vértice, identificar tensões e definir se a posição pode ser estimada. Magnitudes são sempre interpretação editorial; uma referência não mede um percentual. Quando uma questão contemporânea não tem equivalente histórico, registrar o limite em vez de fabricar uma declaração retroativa.

O preenchimento quantitativo deve distinguir sustentação direta e inferência editorial, com justificativa e incerteza. A decisão de completar uma dimensão não pode depender de deixar a ficha parecida com um estereótipo, de torná-la mais próxima de um usuário ou de atingir uma contagem de catálogo.

## Critérios de aceite

Uma ficha só pode ser declarada integralmente documentada após revisão individual das 18 dimensões, conferência de suas fontes e distinção das inferências. Presença de número, ausência de campo nulo, renderização de gráfico ou sucesso de build não constituem esse aceite. Limites e dimensões não representáveis devem ser informados com motivo e efeito no cálculo.

O inventário separa: completude numérica; completude documental; adequação do modelo; e elegibilidade para comparação. A pesquisa cobre todas as categorias e correntes sem blacklist por espectro ou juízo moral.

## Reconstrução editorial autorizada em 05/11/2026

A personalidade ou unidade histórica pode reunir vários documentos para reconstruir respostas ao banco do Espectro. O livro permanece limitado ao seu próprio conteúdo. Cada resposta atribuída registra enunciado, intensidade, localizador, fonte e interpretação. Uma transposição contemporânea recebe ressalva explícita; uma resposta condicional não equivale a um dado ausente.

O motor nativo transforma essas respostas em coordenadas, mas não se exportam número de respondentes, erro padrão, cobertura de sessão ou confiança estatística como se fossem observações históricas. O status `editorial_reconstruction` é separado de `primary_supported`. Diferenças de itens entre reconstruções limitam sua comparabilidade; o instrumento não é apresentado como forma psicometricamente equivalente ao teste pessoal.

Afinidades esperadas entre autor e tradição servem para investigar erros, não para ajustar respostas até produzir o primeiro lugar desejado. Nas sugestões automáticas do Atlas, exigir pelo menos oito dimensões comuns e 60% de sobreposição da união; a comparação manual continua disponível com cobertura explícita.

## Modelo em três níveis de evidência e dossiês particionados (06–07/11/2026)

Para expandir o catálogo de personalidades para milhares de verbetes sem inflar o carregamento inicial na Web nem misturar graus heterogêneos de verificação documental, cada ficha declara explicitamente um `evidenceTier`:

1. **Nível 1 (`tier1_editorial_reconstruction` — Reconstrução Primária)**: fichas com leitura direta de trechos primários (`primary_supported`) e/ou reconstrução item a item (`editorial_reconstruction`) no banco de questões do Espectro, com localizador, citação contextual e ressalvas por dimensão.
2. **Nível 2 (`tier2_institutional_record` — Votações Nominais / Registro Oficial)**: parlamentares e agentes públicos cujas coordenadas derivam exclusivamente de registros oficiais nominais verificáveis (`institutional_vote`), como votações nominais em plenário da Câmara dos Deputados e do Senado Federal. Dimensões sem votação nominal observada permanecem ausentes (nunca preenchidas por sigla partidária nem por `0.0`).
3. **Nível 3 (`tier3_preliminary_curation` — Curadoria Preliminar)**: personalidades históricas e contemporâneas globais e brasileiras com referência institucional/primária verificável (`https://`) e estimativa editorial preliminar (`unreviewed`), identificadas na interface com aviso explícito de revisão por trecho pendente.

### Particionamento sob demanda (`dossierShard`)

O índice principal (`personalities_extended.json`) armazena apenas metadados, coordenadas numéricas, URLs declaradas, `evidenceTier` e o identificador `dossierShard` (`shard_00`..`shard_15`). O detalhamento por dimensão (`dimensionEvidence`) desses perfis estendidos fica em `assets/data/dossiers/shard_XX.json` e é carregado sob demanda ao abrir a ficha em `StudyProfileScreen`, preservando inicialização rápida e funcionamento 100% offline.
