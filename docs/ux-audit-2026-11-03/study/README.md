# Atlas de estudo, transparência e teia viva

Complemento do diagnóstico de 3 de novembro de 2026, incorporando a direção explicitada pelo usuário: profundidade intelectual, navegação por espectros e correntes, design limpo, identidade dos eixos e uma teia fluida com posições estáveis.

**Direção de produto:** o Espectro deve oferecer um Atlas político que permita estudar relações, posições e argumentos continuamente. O teste é uma das entradas nesse acervo. A pessoa deve conseguir entrar por um espectro, por uma pergunta, por um autor, por uma obra ou pelo mapa e continuar a exploração sem precisar realizar uma avaliação pessoal.

Este complemento atualiza a prioridade do relatório anterior: a teia passa a integrar a primeira entrega do Atlas de estudo, juntamente com perfis conectados e navegação em lista. Não é apenas um acabamento previsto para depois de todo o restante.

## Evidências adicionais verificadas

Foram executados seis novos cenários completos via REA: catálogo de correntes, biblioteca, perfil de corrente, navegação por espectro, aba de ideologias relacionadas e explicação de eixo. Uma inspeção passiva capturou os scripts do mapa; o REA exportou esses bytes com manifesto e hashes. Os resultados e as limitações estão em [evidence/index.json](evidence/index.json), [rea-bundle.json](evidence/rea-bundle.json) e [motion-source-anchors.json](evidence/motion-source-anchors.json).

| Observação | Resultado |
| --- | --- |
| Biblioteca | A interface anuncia 334 obras, oito áreas de pensamento e navegação por autor |
| Correntes | A interface anuncia 275 correntes, oito espectros e 12 eixos por perfil |
| Espectro | Acionar a categoria de esquerda radical navega para `#esq-radical`, com 25 correntes naquele agrupamento |
| Corrente | O perfil de liberalismo clássico contém resumo, pessoa e país de referência, síntese em primeira pessoa e quatro abas de exploração |
| Relações | A aba de ideologias separa próximas no mesmo espectro, próximas em outros espectros e a mais distante |
| Explicação | Acionar a ajuda de Estrutura abre um diálogo com o significado do eixo e a posição do perfil |
| Teia | O código capturado usa posições-base carregadas de dados e pequenas oscilações visuais sobre essas posições |

As contagens são o que a interface declara. As distribuições visíveis somam os totais anunciados, mas esta investigação não constitui auditoria bibliográfica das 334 obras nem validação histórica de todas as 275 correntes.

Fontes: [biblioteca](https://12axes.vercel.app/books), [correntes](https://12axes.vercel.app/ideologies), [perfil inspecionado](https://12axes.vercel.app/ideologies/liberalismo-classico), [teia](https://12axes.vercel.app/tree/ideologies?id=liberalismo-classico).

## Por que esse percurso convida ao estudo

O site permite começar com uma noção ampla e avançar em etapas pequenas: espectro → corrente → posição por eixo → pessoa de referência → outra corrente → comparação. Cada etapa responde uma pergunta e oferece outra que faz sentido naquele contexto.

A simplicidade visual contribui para isso. A estrutura de leitura permanece previsível; a variação vem de cores, identidades e conteúdo, em vez de uma composição inteiramente diferente a cada clique. Há profundidade disponível sem exigir a leitura de tudo de uma vez.

Para o Espectro, o indicador de qualidade desse percurso será a capacidade de continuar uma investigação mantendo contexto: retornar à mesma categoria, posição de rolagem, pesquisa, perfil selecionado e ponto de observação no mapa. Quantidade de conteúdo e tempo de permanência, isoladamente, não demonstram aprendizado.

## Contrato de navegação do Espectro

| Elemento apresentado | Ação esperada |
| --- | --- |
| Espectro ou família | Abrir sua apresentação editorial, critérios de agrupamento e correntes; preservar os filtros |
| Nome de corrente | Abrir seu perfil, com caminhos para eixos, referências, relações e comparação |
| Eixo ou indicador de intensidade | Explicar os polos, a posição e sua justificativa; mostrar limites da interpretação |
| Pessoa de referência | Abrir o perfil daquela pessoa e explicitar o tipo da relação com a corrente |
| País ou experiência histórica | Abrir contexto institucional e período, com a justificativa da associação |
| Obra ou autor | Abrir ficha bibliográfica, motivo da indicação e referências de leitura |
| Relação de proximidade | Mostrar dimensões relevantes e permitir abrir ou comparar a outra entidade |
| Nó da teia | Destacar conexões pertinentes e abrir um painel sem substituir todo o mapa |
| Área vazia do mapa | Permitir deslocamento e tirar foco quando apropriado, sem apagar a investigação |
| Voltar, fechar ou alternar lista/teia | Restaurar o contexto anterior |

Uma cor, um rótulo ou um número com aparência de controle deve cumprir a ação prometida. Elementos informativos sem ação precisam de tratamento visual diferente. Não se deve tornar cada palavra clicável: cada interação precisa oferecer uma explicação ou um próximo passo útil.

## Perfil de corrente como unidade editorial

O perfil deve ter uma hierarquia comum:

1. Nome, resumo neutro e família/espectro, com explicação dessa classificação.
2. Uma síntese da sociedade desejada, identificada como paráfrase editorial da perspectiva da corrente.
3. Princípios centrais, variantes e tensões internas relevantes.
4. Personalidades e contextos de referência, com relações tipadas e justificadas.
5. Doze eixos e, quando modeladas, seis tríades; ajuda acessível no próprio indicador.
6. Aproximações no mesmo agrupamento e em outros, com motivos de convergência e diferença.
7. Obras introdutórias, aprofundamento e contrapontos.
8. Fontes, edição do verbete, período e limites de evidência.
9. Ações de comparar, salvar e continuar a leitura.

O formato em primeira pessoa ajuda a compreender a lógica interna de uma corrente. Deve ficar claro que é uma síntese editorial, não uma citação histórica nem uma posição do aplicativo. Se houver citação literal, autoria, obra e referência pertencem à própria apresentação.

**Referência histórica e afinidade numérica são relações distintas.** A pessoa com vetor mais próximo não se torna automaticamente o principal representante histórico de uma corrente. O mesmo vale para países: proximidade parametrizada não significa que um país ou toda a sua população encarne aquela doutrina. Contexto e período precisam acompanhar a associação.

## Transparência que acompanha a interação

Há duas camadas complementares:

- **Explicação imediata:** o significado do eixo, por que uma entidade apareceu como próxima, quais dimensões aproximam ou afastam e o que significa o indicador.
- **Rastreabilidade:** fontes, autoria editorial, data, versão dos parâmetros, justificativas e lacunas por dimensão.

A primeira camada favorece entendimento durante a navegação. A segunda permite examinar e contestar o conteúdo. A página geral de metodologia não substitui as duas no ponto de uso.

Para cada posição editorial, o modelo deve comportar referência, período, nota de interpretação, incerteza e estado de evidência. Uma referência não deve preencher automaticamente todas as dimensões. Onde não houver justificativa suficiente, declarar ausência ou estimativa provisória.

Proximidade entre vetores, influência histórica, autoria e pertencimento a uma tradição também são relações diferentes. As linhas da teia devem explicitar que tipo de relação representam. Uma conexão calculada não demonstra influência histórica.

## Design limpo com identidade semântica

O sistema visual precisa diferenciar três usos de cor:

| Cor identifica | Consistência necessária |
| --- | --- |
| Eixo e seus polos | A mesma identidade no quiz, perfil, resultado, comparação e legenda |
| Espectro/família editorial | A mesma identidade nos agrupamentos, badges e mapa |
| Participante da comparação | Um marcador persistente que permite seguir a entidade entre os eixos |

Essas três camadas não podem compartilhar cores arbitrariamente sem rótulos. Tipo, nome, ícone e posição complementam a cor. Contraste deve funcionar nos dois temas.

O Espectro já possui `leftColor` e `rightColor` nos eixos em `assets/data/twelve_axes.json`, mas a barra atual em `lib/ui/charts/diverging_axis_bar.dart` utiliza predominantemente `palette.poleLeft` e `palette.poleRight`. Portanto, há um problema de integração dos tokens disponíveis, além de direção visual. A solução é mapear e revisar essa identidade de forma consistente, preservando legibilidade, sem transplantar automaticamente a paleta do concorrente.

A base pode manter fundos discretos, tipografia legível e separadores leves. Cor serve para orientação; o conteúdo recebe a atenção principal. Painéis escuros grandes não precisam aparecer em toda seção.

## Como funciona a fluidez observada na teia

A inspeção do script servido pelo site fornece uma explicação específica, derivada estaticamente dos bytes capturados:

- Os arrays de posições-base são carregados de um arquivo de dados do mapa.
- O desenho calcula a posição visível a partir dessa base, da transformação da câmera e de um deslocamento oscilatório pequeno.
- As amplitudes somadas do deslocamento têm limite de seis unidades de tela por componente naquele código. Isso é um limite matemático da expressão encontrada, não uma medição de quadros ou percepção.
- Há pulsações discretas de tamanho e variação de regiões de fundo.
- A seleção usa uma transição de câmera com desaceleração e duração definida; o painel e as relações pertinentes são atualizados.
- O código consulta a preferência de movimento reduzido para desativar a oscilação e interrompe a animação contínua enquanto o documento está oculto.

Isso é diferente de reorganizar continuamente o significado espacial do mapa. A sensação orgânica vem de um movimento limitado sobre uma referência estável.

Arquivo observado: `TreePage-92319e9199.js`, SHA-256 `ee37e621f8cc32070b286eb1c59d590c849551f9640a61825959df77ce0d4717`. Inspeção REA `ev_9c3411893e30007b6dabcd0fa9f19cdf359bd6f9530a0d8d525ae036c65e6080`; exportação verificada `ev_8acd23d3bd761f88524f33dba9b1227d66cb00add4175763a67ac92a70301a81`.

A captura dos scripts não prova execução de todos os ramos. O gerador das posições pré-calculadas e a validade intelectual dessas coordenadas não foram auditados. Não foi realizado benchmark de fluidez, bateria ou acessibilidade integral.

## Contrato da teia do Espectro

**Coordenada analítica estável.** A projeção pertence ao domínio e permanece independente da animação. Selecionar um nó não muda seus escores ou sua posição calculada. Toda projeção deve indicar quais dimensões resume; a proximidade no plano não equivale necessariamente à proximidade completa nos 12 eixos e seis tríades.

**Desenho vivo e discreto.** Movimento opcional de pequena amplitude, destacamento progressivo das relações e transições de câmera suaves. A amplitude, os tempos e a densidade são decisões próprias a validar, sem copiar os coeficientes do concorrente.

**Interação preservada.** Busca leva ao nó e abre seu painel. Arrastar desloca a câmera; zoom conserva o foco; selecionar destaca vizinhos e mantém o restante como contexto. O retorno do perfil completo conserva a seleção e o enquadramento.

**Conforto e precisão.** Movimento reduzido, modo estável, alvos de toque adequados e suspensão quando o mapa não está visível. Hit testing acompanha a posição desenhada. O movimento não deve dificultar selecionar um nó ou ler seus dados.

**Alternativa equivalente.** A pessoa pode cumprir a mesma investigação em lista, busca e perfis. O painel detalhado, os controles e os resultados da busca devem ser acessíveis por teclado e leitor de tela; não depender somente do canvas.

**Densidade controlada.** Rótulos e conexões aparecem conforme zoom, foco e contexto, evitando desenhar tudo com o mesmo peso. A seleção mantém vizinhos relevantes e suas diferenças; deve ser possível entender por que cada conexão existe.

## Primeira entrega revisada

O primeiro recorte deve permitir, com o catálogo atual, o seguinte percurso completo:

**Explorar → escolher um espectro → abrir uma corrente → entender seus eixos → abrir uma referência → voltar ao mapa → selecionar uma vizinha → comparar.**

Lista e teia passam a ser duas vistas do mesmo Atlas. Perfis e referências são compartilhados por ambas. Uma fonte de dados comum impede divergências entre lista, mapa, resultado e comparação.

Critérios de aceite:

- Categorias levam aos itens correspondentes e explicam seu agrupamento.
- Perfil de corrente tem síntese contextualizada, referências, ajuda de eixo e relações navegáveis.
- Eixos conservam a identidade visual entre telas.
- Busca encontra entidades independentemente de a pessoa conhecer a categoria.
- Nenhuma dessas ações exige responder ao teste.
- Lista e teia mantêm seleção e contexto ao alternar.
- Clicar em um nó não recalcula sua posição analítica.
- Movimento reduzido desativa a deriva decorativa sem impedir a navegação.
- Relações e coordenadas têm explicação acessível no painel.
- Fontes e lacunas ficam próximas das afirmações que justificam.

A ampliação do acervo acompanha uma política editorial: distribuição entre tradições e períodos, identificação de variantes, qualidade das referências e revisão de conflitos. Não há motivo para atingir os números do concorrente antes de assegurar consistência e navegabilidade no catálogo existente.

Este complemento especifica a próxima implementação; não altera o motor, a taxonomia ou os verbetes do aplicativo nesta etapa.
