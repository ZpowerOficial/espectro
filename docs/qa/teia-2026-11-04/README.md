# Teia — investigação e correções de interação

QA local controlado em 2026-11-04. Não representa teste em aparelho físico nem publicação.

## Falhas reproduzidas antes da correção

1. `arrasto vertical na teia move câmera em vez de rolar a página`: esperado `outer.offset == 0`, observado `80.0`. O reconhecedor de rolagem vertical do pai ganhava a arena contra o scale recognizer do InteractiveViewer.
2. `gesto do usuário interrompe voo de seleção sem perder o pan`: a translação final mudava de `137.87473547625714` para `126.27272727272725` depois do gesto, porque a animação de seleção continuava sobrescrevendo a câmera.
3. Na compilação web intermediária, os botões DOM gerados pelos pontos coincidentes Platão/A República se sobrepunham. O clique CDP no retângulo de Platão produziu seleção de A República; os locators Playwright do ponto inferior sofriam interceptação. Ver `browser-buttons-before.json`, `browser-pointer-report.json` e `after-selected-mobile.png` (o nome deste PNG é anterior ao fix de acessibilidade e mostra a seleção equivocada intermediária). `before-browser-pointer-check.mjs` é um reprodutor dessa compilação intermediária, não um teste da versão final.
4. Na versão inicial, raio e fontes estavam em unidades do canvas: o enquadramento mobile reduzia raio 4 para aproximadamente 1,6 px e fonte 13 para aproximadamente 5 px. Ver `before-mobile.png` e `before-rea.json`. SHA-256 do main.dart.js dessa observação inicial: `03e6e58a2c1faf1520fd7bc2e63839f8247eedf01774ddedbc2fb4a089b68f67`.

## Correção

- Um único reconhecedor de escala prioriza os gestos do mapa, conservando pan, pinch de dois dedos e trackpad. Gesto interrompe voo anterior; roda do mouse é consumida pelo mapa. A câmera tem limites e os alvos usam a inversa da transformação uma única vez.
- Tamanhos de pontos e rótulos ficam constantes em pixels de tela; as coordenadas com dados suficientes permanecem analíticas e não são deslocadas para resolver colisões. Perfis sem base suficiente não recebem um centro artificial (ver a revisão geral de dados ausentes).
- Sobreposições semânticas invisíveis foram removidas. A imagem tem descrição acessível; o controle Escolher ponto abre uma lista pesquisável com alvos nativos independentes.
- Nome selecionado e controles ficam acima do canvas em uma área de altura estável. Abrir perfil é uma ação explícita. Selecionar não desloca o mapa por mudança de layout.

## Verificação automatizada

`rtk flutter test test/ui/study_constellation_test.dart --no-pub`: **11 PASS**. Inclui os dois testes que falhavam, coincidência e escolha individual, dois ponteiros reais, pan horizontal/vertical contra a página, zoom e roda, toque após transformação, abertura de StudyProfileScreen e retorno preservando câmera e seleção. Executado com TargetPlatform.android/touch e TargetPlatform.linux/mouse no motor de testes Flutter; não é teste em Android físico. Analyzer dos dois arquivos sem problemas.

O MCP REA é usado para capturas e cliques de controles no Chromium local. O tool de cenário não oferece drag/pinch; esses gestos são verificados por PointerEvents no Flutter.

## Percurso no navegador após a correção

`final-rea.json` registra 19 etapas concluídas em Chromium, viewport 390 × 844, contra o build web release local final (`main.dart.js` SHA-256 `8acc5f34d4657ee00e649c5cae6fe578d1b5e61b76d2c10d30cfdd50d322452e`). O seletor escolheu **Platão**, abriu `subject=personality:platao` e voltou à teia pela navbar **Atlas**. Em seguida escolheu **A República**, abriu `subject=book:a_republica_platao`, voltou pela mesma navbar e acionou o zoom. A escolha individual funciona mesmo com as mesmas coordenadas. Nenhum evento `page-error` foi observado nesse percurso.

`final-mobile.png` é a captura final com A República selecionada. As etapas e árvores de acessibilidade permanecem no registro, inclusive o retorno de cada perfil. Essa evidência cobre controles e navegação no navegador; a cobertura de pan e pinça permanece nos 11 testes Flutter acima.
