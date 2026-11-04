# Revisão dos oito pontos — 2026-11-04

## Identidade e cores

Dez tradições editoriais substituem os oito grupos mistos. Esquerda radical usa vermelho; libertarianismo, amarelo; anarquismo, carvão. Liberalismos, conservadorismo, reformismo, ecologias e redes têm cores e símbolos próprios. A identificação de personalidades usa curadoria explícita e os novos campos `spectrumId`, sem deduzir sua tradição do vizinho numérico mais próximo.

Cabeçalhos, botões principais, abas, avatares, conexões e legenda da teia usam a mesma classificação. As cores de texto adaptam o contraste ao tema; amarelo recebe texto escuro. Marx e Rothbard têm retrato, faixa, selo e contexto próprios. A consistência de componentes continua preservada.

## Interação da teia

Regressões reproduzidas por gestos: arrasto vertical era capturado pela rolagem da página; uma animação em curso sobrescrevia o pan manual; raios e fontes encolhiam com a escala inicial. Em Chromium, alvos semânticos sobrepostos também interceptavam perfis nas mesmas coordenadas.

A implementação prioriza os gestos do mapa, interrompe o voo ao começar um gesto, mantém tamanhos legíveis em unidades de tela e oferece seletor pesquisável para pontos coincidentes. Inspeção e ação de abrir o perfil permanecem explícitas. Coordenadas analíticas e conexões não são movidas para esconder colisões. Pan, pinça com dois ponteiros, mouse, zoom, reenquadramento e retorno do perfil são verificados.

## Navegação e hierarquia

Modalidades e profundidade usavam `Scaffold` fora do shell. Agora mantêm navbar/sidebar de Testes. O questionário ativo continua com os controles próprios da avaliação.

Tocar na seção já aberta não empilha outra cópia. Em uma subpágina, a navbar retorna à raiz existente: o Atlas preserva busca, seleção e câmera; Testes preserva a modalidade escolhida. Um perfil aberto diretamente por link também consegue abrir a raiz do Atlas.

Em Sistemas de valores fundamentais, a arena, o título completo e o resumo passam a ser uma hierarquia vertical. A grade adapta colunas ao espaço e ao tamanho do texto. Cabeçalhos de Nolan, compatibilidade, biblioteca, tríades e cartões de livros também foram corrigidos para telas estreitas e texto ampliado.

## Conteúdo e o caso de Marx

O catálogo passa de 84 para **124 correntes**, de 84 para **124 personalidades** e de 76 para **80 obras**. Com países, partidos e recortes históricos existentes, são **512 verbetes**. A expansão inclui comunismo, socialismo marxista, tradições marxistas e anarquistas distintas, Mises, Rothbard e Hoppe. Não são vetores completos clonados para inflar contagens.

Foram acrescentados recortes, limitações, notas dimensionais e 60 relações documentadas. Em Marx, o sinal de comércio e de internacionalismo foi revisto com notas e fontes, distinguindo o contexto de 1848–1875 das recepções do século XX. A ligação com socialismo marxista e comunismo aparece antes das proximidades do modelo; marxismo-leninismo é identificado como recepção posterior. O índice numérico continua exploratório e não determina identidade histórica.

Dimensões sem sustentação são omitidas nas entidades ou recebem relevância zero nas correntes. Não significam posição neutra. A fundamentação é editorial e contextual; os números não foram validados empiricamente. O perfil permite consultar o recorte, a revisão, as notas e os links das fontes.

A comparação usa apenas dimensões observadas em comum. Sem sobreposição, exibe ausência de dados em vez de 100% de compatibilidade. A projeção de Nolan também não inventa um ponto central para perfis sem base suficiente. As distâncias entre tríades consideram a intensidade absoluta além da composição relativa.

## Retratos

**115 retratos** são armazenados offline (aproximadamente 10,1 MB), selecionados por identidade pública e metadados do Wikimedia Commons. Cada arquivo possui acervo, autor, licença, indicação de enquadramento e SHA-256. Nenhuma imagem foi gerada artificialmente ou teve pixels editados. Fotografias, pinturas e reproduções históricas são chamadas de retratos.

As imagens estão sob domínio público, CC0, CC BY ou CC BY-SA conforme o arquivo. Créditos e licença são acessíveis em cada perfil. Os nove perfis sem retrato verificado conservam um avatar identificado; não usam uma imagem de outra pessoa como substituição.

## Evidência

Os testes incluem os percursos originais, navbar em três modalidades nas duas larguras, rolagem das cinco abas do relatório integral em 390 px com fonte 2×, cores por tradição, contraste, carregamento dos retratos, integridade dos caminhos e das fontes, catálogo e vínculos documentados. As imagens de referência incluem Marx e Rothbard nos dois temas e tamanhos.

- Suíte completa: **184 testes PASS** (`rtk flutter test --no-pub --reporter expanded`).
- Análise estática: **sem problemas** (`rtk flutter analyze --no-pub`).
- Regressões de navbar/hierarquia: **20 PASS**, incluídas na suíte; retorno conserva busca, seleção e matriz de câmera nas duas larguras.
- Teia: **11 PASS**, incluídos na suíte, com gestos reais no motor de testes Flutter.
- Referências visuais: **52 imagens**, 13 telas em duas larguras e dois temas.
- [Percurso REA e captura da teia no Chromium](qa/teia-2026-11-04/README.md).
- Build web release: **PASS**. APK Android de depuração: **PASS**. [Logs e hashes dos artefatos](qa/review-2026-11-04/validation.json).

O build web emitiu um aviso de fonte Cupertino não incluída; as telas e ícones Material usados nos percursos verificados renderizaram corretamente. O APK não foi instalado em aparelho físico nesta revisão e não é um artefato assinado para distribuição de produção.

A curadoria é ampliável e provisória. A entrega não afirma esgotar todas as correntes, pessoas ou controvérsias históricas.
