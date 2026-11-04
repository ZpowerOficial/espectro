# Espectro × 12Axes — diagnóstico de produto e UX

Inspeção: 3 de novembro de 2026. Referências principais: [início do 12Axes](https://12axes.vercel.app/), [Rothbard × Mises × Hoppe](https://12axes.vercel.app/compare?items=personality:rothbard,personality:mises,personality:hoppe), [perfil de Mises](https://12axes.vercel.app/personalities/mises), [mapa de personalidades](https://12axes.vercel.app/tree/personalities?id=mises), [marca oficial do Espectro](https://www.figma.com/design/0D4CcCfuRr85O69DWwmVDO?node-id=24-31).

**Diagnóstico:** o Espectro já tem um motor e um acervo consideráveis, mas oferece uma experiência predominantemente centrada em responder um teste e consultar relatórios. O 12Axes transforma pessoas, posições e resultados em pontos de partida para outras investigações. Essa continuidade, combinada com retratos e comparações legíveis, explica parte da diferença de experiência percebida. É uma interpretação de UX apoiada nos fluxos observados; não é uma medição de aquisição, retenção ou conversão.

O ganho seguinte deve vir de busca, comparação exploratória, relações entre conteúdos e apresentação do resultado. Uma nova troca de cores não resolve essas lacunas.

## O que foi realmente inspecionado

REA MCP 6.3.0, Chromium 153, perfil temporário, idioma pt-BR, sem autenticação. Foram preservados **20 registros REA**, dos quais **19 cenários controlados: 18 sem falha de ação e 1 tentativa interrompida**. Há DOM, árvores de acessibilidade e 17 capturas. Uma inspeção independente do código Flutter verificou as capacidades do Espectro.

- Início, apresentação do benefício e escolha de profundidade.
- Questionário curto, avanço automático e conclusão sintética: 36 respostas neutras, seguidas de seis perguntas opcionais de arquétipo, todas puladas. Essas respostas não representam o usuário.
- Resultado sintético e sua URL reabrível; presença dos caminhos para países, personalidades, livros, partidos, valores, comparação e compartilhamento.
- Comparação solicitada em 1440×1000 e 390×844; navegação até os eixos no desktop.
- Remoção de Hoppe, busca por Marx e seleção de Karl Marx, com atualização da URL.
- Catálogo de personalidades, perfil de Mises, aba de personalidades relacionadas, mapa e navegação de Mises para Raphaël Lima.
- Componente oficial de marca do Figma 24:31.

A tentativa interrompida esperava pressionar o botão de avanço depois de escolher uma resposta. O site já avançava automaticamente. O cenário corrigido confirmou esse comportamento e chegou ao resultado; a falha foi do roteiro de automação, não um defeito demonstrado no produto.

Não foram medidos tráfego, popularidade, conversão, retenção, validade psicométrica, correção histórica do catálogo ou conformidade integral com WCAG. Também não foram concluídos pagamento, relatório pago, download/compartilhamento externo ou persistência do concorrente após fechar o navegador. As URLs e os controles correspondentes foram observados, sem presumir que toda operação passou ponta a ponta.

## O que o 12Axes entrega melhor

**1. Mostra a recompensa antes de cobrar esforço.**

A primeira dobra exibe cartões de resultado com identidades visuais, retratos, países e dimensões. O visitante entende o que vai receber. O Espectro tem uma abertura editorial agradável, mas o benefício permanece abstrato e os resultados reais ficam depois do teste. Uma demonstração claramente identificada, com percurso explorável, reduziria essa distância. Evidência R01.

**2. Permite explorar sem produzir um resultado pessoal.**

O perfil de Mises já oferece seus eixos, pessoas relacionadas, correntes próximas, países e entrada para comparação. O mapa permite selecionar outro perfil e continuar. A pessoa pode aprender algo sem responder nenhuma pergunta. O Atlas do Espectro é acessível sem teste, mas as relações e comparações dependem mais do último resultado pessoal. Evidências R05, R08 e R10.

**3. Compara no mesmo espaço visual.**

Na comparação de três pessoas, cada eixo usa uma única régua e posiciona os retratos nela. A identidade de quem está sendo comparado continua visível. Isso reduz a necessidade de guardar números na memória e alternar cartões. Retrato, nome, cor e posição trabalham juntos; a cor não é o único identificador. Evidências R02 e R03.

**4. Converte gráficos em descobertas.**

A página não termina nos 12 eixos: resume a dimensão de maior separação, a mais próxima, os eixos com lados opostos e as compatibilidades entre pares. No exemplo solicitado, o site apresenta imigração como maior distância, controle como maior proximidade e três eixos com posições em lados opostos. São saídas do próprio site, não validações históricas dos personagens. A oportunidade do Espectro é explicar essas relações com cobertura e evidência disponíveis. Evidência R02.

**5. Faz o catálogo parecer um lugar, e não apenas uma lista.**

O catálogo observado anuncia 675 personalidades e oito áreas. Há busca, filtros, retratos, perfis próprios, abas de relações e mapa alternativo. O Espectro tem 84 personalidades, 84 correntes, 80 países/modelos, 56 partidos/movimentos, 48 eras e 76 livros. Seu acervo já permite uma experiência exploratória rica; multiplicar entradas não substitui conectar as existentes. Evidências R06 e R08; contagens locais dos JSONs.

**6. Dá continuidade ao resultado.**

O resultado sintético oferece leituras, perfis próximos por dimensão, mais distantes e novas comparações. Os caminhos são contextualizados: o visitante entende por que abrir o próximo conteúdo. O Espectro já calcula afinidades, contrapontos, antípoda e sínteses, mas parte desse material fica distante na rolagem ou em abas pouco evidentes. Evidência R09.

**7. Usa a própria URL como objeto compartilhável.**

A seleção de pessoas aparece em `items=…`; a troca de Hoppe por Marx alterou esse parâmetro. O resultado sintético retornou uma URL com os 12 valores dos eixos. Isso permite reabrir uma análise sem depender da sessão que a criou. O Espectro exporta imagens, PDF e texto, mas não oferece essa continuidade por URL/importação. Evidências R04, R07 e R09.

## Comparação e ausências reais do Espectro

| Área | Espectro atual | Natureza da lacuna | Consequência |
| --- | --- | --- | --- |
| Comparar duas ou três entidades do Atlas sem teste | Não implementado nos fluxos inspecionados | Funcionalidade ausente | Não reproduz a investigação Rothbard × Mises × Hoppe |
| Comparar avaliações pessoais | Implementado para duas avaliações | Capacidade existente | Deve continuar como um caso da ferramenta maior |
| Usuário × entidade | Implementado, exige resultado pessoal | Capacidade parcial | Não serve como comparação editorial independente |
| Busca global | A entrada oferece várias categorias, mas pesquisa a aba ativa | Inconsistência de UX | Buscar Mises na entrada padrão pesquisa correntes |
| Ordenação por afinidade | Afinidade calculada e exibida; lista mantém ordem original | Descoberta/controle insuficiente | O usuário precisa procurar o que já foi calculado |
| Perfil editorial | Resumo, destaques, período e vetores | Conteúdo/conexões parciais | Há menos caminhos para continuar a leitura |
| Retratos, capas e créditos | Modelo não tem campos de mídia/licença | Lacuna de dados e interface | Iniciais não oferecem o mesmo reconhecimento visual |
| Fontes por dimensão e período | Ausentes no modelo AtlasEntry | Lacuna de proveniência | Não há trilha documental para justificar cada posição |
| Relatório rico | Nolan, radar, tríades, cobertura, contribuições, afinidades e livros existem | Hierarquia/discoverability | A riqueza do motor não aparece logo na experiência |
| Compartilhamento | Imagem, PDF e texto existem | Continuidade ausente | O destinatário não retoma uma exploração interativa |
| Navegação web | MaterialPageRoute; sem rotas de entidades/query/deep link | Funcionalidade ausente no boundary inspecionado | Conteúdo não tem endereço próprio |
| Persistência web | Usa explicitamente armazenamento em memória | Limitação concreta da versão web | Recarregar perde histórico e rascunho dessa sessão |
| Persistência Android | Repositório local em disco | Capacidade existente | A limitação web não deve ser atribuída ao Android |
| Marca | Letra E nos cabeçalhos anteriores | Ajuste visual identificado | Mascote oficial é mais reconhecível e coerente |

Referências locais: `lib/ui/features/compare/compare_evaluations_screen.dart:37`, `lib/ui/features/compare/entity_comparison_screen.dart:26`, `lib/ui/features/atlas/atlas_explorer_screen.dart:48`, `:63`, `:421`, `:564`, `:581`, `:601`, `:920`; `lib/domain/models/atlas_models.dart:31`; `lib/main.dart:15`; `lib/app.dart:17`; `lib/ui/features/share/shareable_card_sheet.dart:54`.

No relatório desktop atual, a análise completa está dentro de uma expansão com área rolável de altura fixa. Isso cria rolagem dentro da rolagem e enfraquece a sensação de continuidade. No mobile, as afinidades chegam depois de vários blocos de resultados. São problemas de organização do que já existe, e não justificativa para recalcular o motor.

## O que deve ser preservado ou melhorado em relação ao concorrente

- O Espectro diferencia pulo de neutralidade, expõe cobertura e dimensões indeterminadas e separa composição de apoio absoluto nas tríades. A apresentação mais simples deve continuar correta sobre esses conceitos.
- O resultado deve comunicar uma leitura provável das respostas observadas, sem afirmar uma identidade definitiva. Na execução neutra, o concorrente exibiu uma compatibilidade de 100% com uma corrente e uma frase identitária. Isso demonstra como ele apresenta o resultado, não prova que uma pessoa neutra pertença àquela corrente.
- A página inicial do concorrente oferece ressalva sobre ausência de validação científica, mas também anuncia precisão absoluta em uma versão. O Espectro pode ser persuasivo com resultados concretos, sem prometer certeza que não mediu.
- Fotos e crédito de imagem melhoram reconhecimento e transparência da mídia. Não são, por si, fontes suficientes para justificar os percentuais políticos de uma personalidade. No perfil de Mises inspecionado, não foi encontrada documentação por eixo no painel observado.
- O mapa é um modo opcional de exploração. A lista com busca, rótulos claros e alternativas acessíveis precisa funcionar antes de investir em uma visualização densa.
- A comparação mobile precisa resumir antes de se alongar. No concorrente, três cartões de perfis já ocupam quase uma tela. O Espectro pode oferecer seleção compacta e atalhos para as conclusões principais.
- A projeção em duas dimensões é uma síntese dos dados, não substitui os 12 eixos nem as seis tríades. Não se deve copiar os percentuais, a classificação ou os coeficientes do concorrente como se fossem equivalentes ao motor do Espectro.

## Ordem de implementação recomendada

| Prioridade | Entrega concreta | Critério de aceite |
| --- | --- | --- |
| P0 | Busca global com resultados agrupados, aliases e normalização de acentos | Buscar Mises na entrada inicial encontra a personalidade; buscar um país não exige adivinhar a aba; seleção mantém contexto |
| P0 | Comparador exploratório independente do teste | Abrir novo app, selecionar Rothbard, Mises e Hoppe e comparar sem criar avaliação pessoal |
| P0, se houver lançamento web | Persistência web durável | Recarregar mantém preferências, rascunho e avaliações locais; exclusão continua sob controle do usuário |
| P1 | Resultado organizado em resumo, relações e detalhes | Em uma primeira leitura, usuário encontra tendências, lacunas, afinidades e próxima ação; detalhes não dependem de rolagem aninhada |
| P1 | Perfis editoriais conectados | Cada perfil abre eixos, relações, obras e comparação; retorno preserva busca/filtros e posição da lista |
| P1 | Modelo de mídia e proveniência | Arquivo/URL, autoria, licença, referência, período e justificativa por dimensão; ausência de evidência visível |
| P1 | Estado reabrível e compartilhamento interativo | Link ou arquivo abre a mesma seleção, com versões de esquema/catálogo; compartilhamento do próprio resultado é deliberado |
| P2 | Home para usuário recorrente e coleção pessoal | Último retrato, avaliações, leituras e comparações recentes aparecem onde ajudam o retorno |
| P2 | Mapa exploratório | Seleção por busca/lista também funciona; relação e significado da posição são explicados; desempenho e acessibilidade verificados |

O comparador pode começar com três sujeitos, em vez de ampliar imediatamente para quatro ou mais. O limite deve acompanhar legibilidade mobile. O objetivo não é superar o número de cartões do concorrente, mas responder uma pergunta com menos esforço.

## Especificação mínima da próxima experiência

**Entrada:** iniciar avaliação ou explorar Atlas. A exploração tem valor próprio e pode levar ao teste depois.

**Seleção:** uma busca global encontra pessoas, correntes, países, partidos e avaliações pessoais. Uma bandeja conserva até três seleções enquanto a pessoa navega. Cada item mantém seu tipo e sua identificação.

**Relatório de comparação:** cabeçalho compacto, resumo das aproximações/diferenças, régua comum por eixo, tríades quando disponíveis, afinidade entre pares, evidências e caminhos para perfis/obras. Explicar o que falta observar é parte da comparação.

**Continuidade:** abrir um perfil, voltar para a comparação sem perder seleção e compartilhar/reabrir o mesmo contexto. O fluxo de comparação entre duas avaliações pessoais passa a usar o mesmo ponto de entrada, sem desaparecer.

Na implementação, os sujeitos devem ter uma representação comum de comparação, preservando a origem: avaliação observada, perfil editorial ou corrente parametrizada. Os cálculos devem continuar no domínio Flutter/Dart, com regras explícitas de cobertura. Não preencher dimensão desconhecida como neutralidade. A ordem dos sujeitos não deve mudar os resultados. Versões de catálogo, motor e esquema precisam acompanhar o estado compartilhado.

**Sequência com maior retorno:** busca global → comparação livre → relatório narrativo e navegável → perfis/mídia/fontes → compartilhamento reabrível → mapa. Evitar começar pelo mapa ou por expandir o catálogo antes de corrigir o percurso básico.

## Marca oficial

O componente Figma 24:31 foi inspecionado e exportado sem redesenho para `assets/figma/espectro-mascot.png` (512×512). Foi aplicado no cabeçalho inicial e na navegação desktop por `EspectroBrandMark`. A alteração não substitui o ícone de instalação Android nem o favicon nesta etapa. A variante compacta da marca pode ser avaliada posteriormente para tamanhos pequenos.

As recomendações de funcionalidades deste documento são diagnóstico e especificação; não foram implementadas automaticamente nesta análise. A mudança de produto executada foi a incorporação da marca oficial indicada pelo usuário.

## Evidências e reprodução

- [Índice completo, IDs, URLs, resultados e limitações](evidence/index.json).
- [Bundle REA canônico](evidence/rea-bundle.json).
- [Início desktop](screenshots/12axes-home-desktop.png).
- [Comparação desktop](screenshots/12axes-compare-desktop.png), [mobile](screenshots/12axes-compare-mobile.png) e [eixos alinhados](screenshots/12axes-compare-axes.png).
- [Perfil de Mises](screenshots/12axes-mises-profile.png), [mapa](screenshots/12axes-atlas-map.png), [busca de comparação](screenshots/12axes-picker-search.png) e [resultado sintético](screenshots/12axes-synthetic-result.png).

| Ref. | Observação | Prefixo do ID REA |
| --- | --- | --- |
| R01 | Início e apresentação visual | ev_74fb42bf |
| R02 | Comparação original de três personalidades | ev_588fb6e9 |
| R03 | Navegação até eixos com marcadores alinhados | ev_052b2faf |
| R04 | Remoção e busca de substituto | ev_76f022c4 |
| R05 | Perfil editorial de Mises | ev_a2b1aeb4 |
| R06 | Catálogo de personalidades | ev_8d227229 |
| R07 | Substituição por Marx e alteração da URL | ev_782aeea3 |
| R08 | Mapa com Mises selecionado | ev_08978288 |
| R09 | Questionário sintético concluído e resultado | ev_578232e3 |
| R10 | Navegação para vizinho e relações do perfil | ev_8fc51a91 / ev_d8b94e5f |

Os IDs completos estão no índice. As capturas são evidência pontual da execução. O REA registra o limite das observações e a ordem dos eventos recebidos; isso não estabelece causalidade de rede, validade dos escores, cobertura completa de todas as rotas ou qualidade de todos os 675 verbetes.

## Validação da alteração de marca

PASS: `flutter analyze`, sem problemas. PASS: `flutter test`, 83 testes. As 32 capturas foram atualizadas e a marca foi inspecionada na renderização do início. Esta etapa não incluiu build/dispositivo Android nem atualização do ícone de instalação.

## Atualização da direção de estudo

O [complemento sobre Atlas de estudo e teia viva](study/README.md) incorpora a direção posterior do usuário. Ele atualiza a ordem de prioridade: navegação por espectros, perfis conectados e teia com coordenadas estáveis pertencem à primeira entrega do Atlas, e não apenas a uma etapa posterior de acabamento.
