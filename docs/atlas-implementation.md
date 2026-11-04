# Atlas de estudo — implementação

> Registro da entrega inicial de 2026-11-03. As contagens, cores, retratos e validações atuais estão em [Revisão dos oito pontos — 2026-11-04](ux-corrections-2026-11-04.md). Os números abaixo descrevem a versão anterior.

Implementação da direção aprovada em `ux-audit-2026-11-03/study/README.md`, no aplicativo Flutter existente. A identidade visual e o mascote importado do Figma foram preservados.

## Percursos disponíveis

- **Início → Explorar o Atlas**: catálogo independente de uma avaliação pessoal. Busca única por nome, texto, termos associados e aliases, sem exigir acentos. Filtros por tipo e salvos.
- **Oito caminhos editoriais → corrente → perfil**: oito grupos com cores consistentes e contagens reais. Os grupos particionam as 84 correntes do catálogo; não são uma classificação científica exclusiva.
- **Perfil → Visão geral / Dimensões / Conexões / Fontes e limites**: síntese, princípios, contexto temporal e geográfico quando disponível, paráfrase editorial identificada, eixos e notas, seis tríades, autoria catalogada, vizinhos e contrastes, leituras primárias e limitações.
- **Lista ↔ Teia**: mesmos dados e filtros. Coordenadas de Nolan estáveis, seleção, conexões de vizinhança na projeção, pan/zoom, reenquadramento e câmera suave. Movimento decorativo limitado, pausa, movimento reduzido e suspensão fora da tela. Lista acessível equivalente.
- **Comparar**: dois ou três perfis de qualquer tipo, sem teste prévio; inclusão opcional de avaliações locais. Escalas comuns, ausência de dados explícita, pares com sobreposição, convergências e contrastes. Seleção cheia permite substituir um perfil.
- **Salvar e continuar**: favoritos, doze explorações recentes e seleção de comparação persistem. Início apresenta biblioteca e último retrato.
- **Resultado → ideias para explorar → ficha no Atlas**: afinidades próximas mais cedo na leitura; detalhes e cálculo existentes preservados. Análise completa no desktop abre em sua própria página, sem a área interna fixa de 740 pixels.
- **Compartilhar → copiar link com minhas respostas**: ação explícita explica os dados incluídos. Resultados recebidos abrem somente para leitura e não são gravados automaticamente. Perfis, explorações e comparações também possuem links versionados.

## Dados e método

O catálogo existente contém **428 verbetes**: 84 correntes, 84 personalidades, 56 partidos/movimentos, 48 eras/regimes, 76 livros e 80 países/modelos. Nenhuma contagem foi inflada para reproduzir o concorrente.

A comparação de estudo calcula proximidade geométrica nas dimensões compartilhadas e informa a sobreposição. Não substitui o motor psicométrico, sua cobertura, intensidade, incerteza ou afinidades calibradas. Eixos indeterminados não entram como neutros. Relação de autoria catalogada, leitura primária editorial e proximidade numérica têm rótulos diferentes.

Foram vinculadas **14 leituras primárias verificadas** a 16 correntes, 12 personalidades e 12 obras existentes. Isso é curadoria inicial, não documentação de todas as afirmações: fontes por coordenada, revisão editorial completa, variantes documentais e mídia com licença continuam pendentes. As telas explicitam essas lacunas; não atribuem uma personalidade ou país a uma corrente apenas por semelhança numérica.

## Persistência e links

Web utiliza `localStorage` por origem. Android mantém arquivos locais. Falha de acesso ao armazenamento na inicialização permite explorar o catálogo em modo temporário com aviso permanente; não apaga os registros duráveis. Detalhes e configuração do endereço web em `runtime-persistence.md`.

Links de resultado incluem respostas individuais e metadados após confirmação. O envelope versionado é limitado e validado, mas não assinado: não comprova autenticidade. O aviso de importação permanece visível. Nenhum serviço recebe as respostas automaticamente.

## Verificação

Testes de domínio, persistência, regressão e UI cobrem busca global, aliases reais, partição dos oito grupos, ausência de evidência, comparação simétrica, limite de três perfis, favoritos, links malformados, payloads adulterados, proteção do histórico local, movimento e acesso às telas com texto 2× em 390 e 1440 pixels.

Capturas de referência em `../test/ui/goldens/`: onze telas, duas larguras, dois temas (**44 imagens**). Exemplos: `atlas-1440-light.png`, `perfil-390-light.png`, `comparacao-1440-dark.png`, `teia-1440-dark.png`.

Resultados finais em 2026-11-03:

- `rtk flutter test --no-pub`: **135 testes PASS**.
- `rtk proxy env CHROME_EXECUTABLE=/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome flutter test --platform chrome test/data/web_storage_browser_test.dart --no-pub`: **2 testes Chrome PASS**.
- `rtk flutter analyze --no-pub`: **sem problemas**.
- `rtk flutter build web --release --no-pub`: **PASS**.
- `rtk flutter build apk --debug --no-pub`: **PASS**.

Build web de produção e APK Android de depuração verificados. APK não foi instalado em aparelho físico nesta etapa; não é uma validação de distribuição ou assinatura de produção.
