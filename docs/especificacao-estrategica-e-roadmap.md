# ESPECTRO — Especificação Estratégica, Metodologia e Roadmap de Implementação

> **Documento de alinhamento técnico e de produto para o desenvolvedor principal.**  
> Este documento consolida a estratégia, os princípios metodológicos e o roadmap P0–P4. **Não comprova o estado da branch atual**: toda afirmação sobre funcionalidades implementadas, testes e quantidades de catálogo deve ser verificada no repositório antes de codificar.
> **Status:** especificação revisada para execução; valores ilustrativos não representam medições reais.

---

## 1. Visão e Posicionamento da Marca

### Slogan e Proposta de Valor
> ### *"Sua política não termina no resultado.*  
> *Traga seus testes, explore novas dimensões e descubra onde suas ideias se encontram — ou divergem."*

### Panorama de referências (hipóteses, não pesquisa de mercado conclusiva)
1. **Instrumentos consultados:**
   * **Political Compass:** representação conhecida em dois eixos; simplicidade pode facilitar divulgação, mas não cobre toda a complexidade política.
   * **Six Triangles:** referência de uso de seis diagramas ternários para explorar combinações de atributos políticos. **Não inventou a geometria baricêntrica**, nem está demonstrado que a complexidade visual explique, isoladamente, seu alcance.
   * **12 Axes (`https://12axes.vercel.app/`):** oferece 12 eixos, formatos de 36/60/240 perguntas e comparações com correntes, personalidades e países. Não afirmar que só fornece um rótulo estático; conferir funcionalidades atuais e licenças antes de integrar.
2. **A tese do Espectro**:
   * O Espectro não compete para ser apenas "mais um teste com números maiores".
   * O Espectro se posiciona como um **ambiente contínuo de investigação, interoperabilidade e aprofundamento**. Quem já fez outros testes encontra aqui um espaço para entender o que seus resultados anteriores mediram, o que deixaram em aberto e para onde suas ideias apontam.

---

## 2. Princípios Metodológicos e de Segurança Invioláveis

Nenhuma funcionalidade nova deve depender de classificações mais precisas do que a metodologia consegue sustentar.

### 1. Cobertura Mínima de Evidência vs. Confiabilidade Estatística
* **Não confundir cobertura com confiabilidade**: 36, 60 ou 72 perguntas garantem apenas maior número de observações, não propriedades psicométricas validadas por si sós.
* **Geometria das 6 Tríades**: 6 tríades possuem 18 vértices nominais, mas cada tríade possui apenas 2 graus de liberdade composicionais normalizados ($x + y + z = 1$) mais a intensidade absoluta de engajamento.
* **Regra de Amostragem**: 
  * 12 a 18 perguntas podem oferecer uma **prévia exploratória**, **sem promessa de seis tríades completas**. Cada dimensão deve ter seu estado determinado individualmente; não presumir que todas ficam indeterminadas nem que todas ficam determinadas.
  * Calcular e exibir a posição quantitativa interpretável somente após atingir os critérios de **cobertura por dimensão, por polo e por vértice**, com quantidade mínima de itens e balanceamento semântico documentados.
  * Um limiar de cobertura é **regra operacional**, não prova de confiabilidade ou validade psicométrica. Não usar "intervalo de confiança" ou "erro estatisticamente significativo" sem validação apropriada.
  * **Não confundir apoio absoluto 0% observado com dimensão ausente**: a primeira informação é mensurável e a segunda permanece nula.

### 2. Ausência Explícita de Dados (Zero Centro Falso)
* Quando uma dimensão não foi avaliada ou tem relevância operacional zero por falta de evidência, o sistema **nunca** deve preencher com 50%, centro artificial ou média da população. Atenção: valores *efetivamente observados* em 50%/50% ou apoio 0% são legítimos e não podem ser apagados. `relevance: 0.0` por si só é implementação específica: validar como o motor distingue ausência de dados de resultados substantivos.
* A ausência de dados deve ser tratada como valor nulo/indeterminado em **toda a cadeia**: motores de cálculo, diagramas de Nolan, gráficos de barras divergentes, radares, histórico, exportação PDF e cartões visuais.

### 3. Dualidade de Perfis e Proveniência de Dados
* Resultados importados de outros testes (ex: 12 Axes) não são respostas a itens do Espectro.
* O sistema deve separar e apresentar explicitamente:
  * **Perfil Combinado por Fontes**: Exibe dados externos rotulados com sua origem e dados nativos observados.
  * **Perfil Nativo Espectro**: Apresenta exclusivamente dimensões medidas pela metodologia e banco de afirmações do Espectro.
* Uma visualização combinada **não** é um resultado nativo completo. Nenhuma porcentagem externa pode ser injetada em `EvaluationRecord` ou no motor nativo como se tivesse vindo de respostas locais. Não comparar diretamente instrumentos com metodologias distintas sem calibração documentada.
* Preservar proveniência e versões (instrumento, domínio, edição/modalidade, escala e polos, data, método de importação, versão do mapeamento e respostas nativas em registros separados).

### 4. Privacidade e LGPD por Padrão
* Opiniões políticas vinculadas a pessoas identificadas ou identificáveis são **dados pessoais sensíveis** (Art. 5º, II da LGPD).
* Princípio da minimização:
  * Sem cadastro obrigatório.
  * Processamento local no dispositivo.
  * Armazenamento local com avaliação de ameaças específica para Web e Android; **`localStorage` não é um cofre criptográfico** e é vulnerável a scripts executados na mesma origem. Não prometer segurança absoluta apenas por usar armazenamento local.
  * Evitar URLs, QR codes, logs e ferramentas analíticas que contenham pontuações, identificadores ou opiniões políticas sem escolha explícita do usuário.
  * Comparações entre usuários ("Duelo") devem ser **privadas por padrão, consensuais e baseadas em dados mínimos**, sem rankings públicos ou telemetria de respostas.
  * Definir política de exclusão, exportação e retenção; tratamento de dados pessoais sensíveis requer análise de finalidade, base legal e segurança conforme a LGPD. Consentimento para compartilhar não resolve sozinho todas essas obrigações.

---

## 3. Roadmap Priorizado (P0 a P4) e Critérios de Aceite

---

### P0 — O Primeiro Ciclo Perfeito de Produto (Foco Imediato)

> **Objetivo**: Fechar um ciclo ponta a ponta perfeito: responder ao questionário nativo com navegação fluida, receber uma análise fundamentada, gerar cartões visuais atraentes e permitir que um terceiro acesse a plataforma com clareza.

#### Escopo do P0:
1. **Hierarquia e Design System (Figma)**:
   * Usar o arquivo Figma `https://www.figma.com/design/0D4CcCfuRr85O69DWwmVDO`, com nós de referência `4:49` (identidade), `7:16` (questionário), `7:24` (síntese) e `14:15` (desktop). São **referências de design**, não evidências de implementação nem de código final.
   * Tipografia IBM Plex Sans / IBM Plex Mono, paleta ardósia/petróleo/âmbar (`#0C1C27`); verificar instalação, configuração do `pubspec.yaml` e licenças das fontes no projeto Flutter. Priorizar componentes nativos com estados acessíveis e texto escalável.
2. **Diagnóstico Fundamentado (Sem rótulos vazios)**:
   * A tela de resultados deve mostrar:
     * O que aproxima o usuário das correntes históricas.
     * O que o diferencia (contrastes e tensões observadas).
     * O que permaneceu indeterminado, a cobertura real e as limitações do instrumento (sem rotular cobertura baixa como incerteza estatística formal).
3. **Cartões Compartilháveis com Substância**:
   * Formato Story 9:16 e Feed 1:1.
   * Não gerar caricaturas ("comunista de boutique"). A opção **"Minha Descoberta Mais Surpreendente"** só pode aparecer quando houver evidência suficiente de uma tensão efetivamente observada. Caso contrário, oferecer um cartão descritivo neutro ou de principais dimensões.
   * O arquivo original já possuía `shareable_card_sheet.dart` com captura PNG e modos 1:1/9:16: **auditar, preservar e aprimorar antes de reimplementar**.
   * Link público/QR code deve direcionar para **landing page ou início de avaliação**, nunca carregar pontuações ou respostas pessoais na URL por padrão. Para preview em redes, a landing page precisa de metadados OpenGraph server-side/estáticos, sem revelar perfil do usuário sem autorização.

#### Critérios de Aceite do P0:
* [ ] Fluxo início → questionário → resultado → compartilhamento executável sem erros em **390 e 1440 pixels lógicos** (Flutter), com testes de texto ampliado, Android e Web.
* [ ] Nenhuma dimensão sem resposta assume 50% ou ponto central no diagrama de Nolan ou no gráfico divergente.
* [ ] Cartão 1:1 e Story 9:16 exporta imagem legível de alta resolução, com identificação do Espectro, versão do instrumento, origem dos dados, limites da interpretação e apenas evidência observada.
* [ ] Quando faltam dados para uma "descoberta surpreendente", há fallback informativo, sem fabricar contradições ou afinidades.
* [ ] QR code/link abre página de entrada funcional em navegador e/ou Android sem transmitir resultado sensível.
* [ ] Há revisão de contraste, recorte de texto, compartilhamento/armazenamento e estados sem conexão.
* [ ] Testes existentes e novos testes de integração/layout/motores passam; registrar quais foram executados, quais falharam e em qual ambiente.

---

### P1 — Importador Universal de Resultados: 12 Axes (Fiel e Manual)

> **Objetivo**: Permitir que usuários que já concluíram o 12 Axes (`12axes.vercel.app`: versões de **36, 60 ou 240 questões**) tragam seus resultados anteriores sem refazer um teste apenas para visualizar os dados importados.

#### Escopo do P1:
1. **Entrada Manual Confiável**:
   * Interface para inserir as porcentagens dos 12 eixos bipolares do 12 Axes.
   * Validação de complementariedade ($p_{left} + p_{right} \approx 100\%$), faixa 0–100, orientação exata dos polos e tolerância **documentada** a arredondamentos. Não corrigir diferenças maiores silenciosamente.
   * Exibir os 12 rótulos na **ordem correta da edição de origem** e solicitar revisão/confirmação dos valores. Não presumir que nomes parecidos signifiquem instrumentos equivalentes.
2. **Modelo de Dados Isolado**:
   * Criar entidades independentes de `EvaluationRecord`:
     * `ImportedPoliticalResult`
     * `ImportedAxisValue`
   * Guardar ID/domínio da fonte, versão/modalidade (quando conhecidas), data, método, ordem/polos/escala, valores originais, validação e confirmação. Ausências permanecem `null`.
   * Proibido reconstruir respostas individuais, inferir contradições específicas ou inventar pontuações para as 6 tríades. Não injetar valores externos em avaliações nativas.
3. **Visualização do Resultado Importado**:
   * Gráfico fiel dos 12 eixos originais.
   * Painel: *"O que seu teste anterior mediu"* (12 eixos agregados) vs. *"O que ainda não sabemos"* (6 tríades, intensidade de apoio, contradições específicas).

#### Critérios de Aceite do P1:
* [ ] Importação manual armazena os dados sem criar registros fictícios em `EvaluationRecord`.
* [ ] A tela de visualização rotula explicitamente a origem como "12 Axes (Importado)".
* [ ] Não há cálculo de compatibilidade direta com correntes nativas baseado apenas em dados externos sem calibração (o **ZIP de referência possui 84 correntes**, não 124; conferir a contagem do repositório atualizado).
* [ ] Entrada manual, revisão, leitura, exclusão e persistência funcionam offline, independentemente de APIs; importação de links ou OCR ficam fora do P1 se não forem comprovadamente suportadas.
* [ ] Duplicação, erros de arredondamento, inversão de polos, dados ausentes e formato desconhecido são cobertos por testes.
* [ ] Importação não copia código, perguntas, vetores de perfis ou materiais protegidos do 12 Axes; apenas dados fornecidos pelo próprio usuário.

---

### P2 — Aprofundamento Progressivo e Investigação por Curiosidade

> **Objetivo**: Oferecer caminhos para que o usuário explore dimensões adicionais e esclareça divergências sem ser obrigado a recomeçar questionários do zero.

#### Escopo do P2:
1. **Sessão Suplementar Nativa**:
   * Usuários com teste importado ou teste rápido podem responder a blocos complementares (ex: afirmações exclusivas das tríades).
   * As respostas nativas são armazenadas em `NativeSupplementSession`, com IDs de questões, semente/seleção, versões de banco e motor, cobertura efetiva e identificação da importação associada, sem modificar o resultado externo.
2. **Investigação Dirigida por Curiosidade**:
   * Ao consultar duas correntes no Atlas (ex: Liberalismo Clássico vs. Anarcocapitalismo), o usuário tem a opção: *"Descubra o que diferencia sua visão dessas duas correntes"*.
   * O sistema poderá apresentar perguntas relacionadas às dimensões que diferenciam as correntes, **com justificativa documental dos perfis do Atlas**, balanceamento semântico e sem exibir antecipadamente respostas "esperadas". Não direcionar para um resultado desejado.
   * Se as posições dessas correntes não possuírem fontes confiáveis ou calibração suficiente, permitir comparação **qualitativa**, sem seleção automatizada de itens ou compatibilidade numérica.
3. **Apresentação de Cobertura**:
   * Indicador de **cobertura observacional** por dimensão (Indeterminado → Cobertura inicial → Cobertura ampliada/suficiente segundo regra operacional). Evitar "consolidada" ou "confiável" sem validação psicométrica.

#### Critérios de Aceite do P2:
* [ ] Respostas complementares permanecem registradas como observações nativas, sem reescrever a importação externa.
* [ ] Dimensões que não atingiram a cobertura mínima de afirmações mantêm o estado de incerteza/indeterminação.
* [ ] A investigação dirigida não induz respostas; diferenças numéricas só são calculadas entre **observações nativas comparáveis sob versões compatíveis**, nunca diretamente entre agregados do 12 Axes e escores nativos.
* [ ] O perfil combinado rotula cada dimensão por sua fonte; não é chamado de "teste completo do Espectro".
* [ ] Cada vértice triádico e cada polo recebem cobertura suficiente conforme critérios aprovados; 12–18 perguntas não desbloqueiam automaticamente seis tríades completas.

---

### P3 — Atlas Público e SEO (Páginas Estáticas)

> **Objetivo**: Construir um canal permanente de aquisição orgânica via busca no Google para quem pesquisa sobre ideologias, autores e obras históricas.

#### Escopo do P3:
1. **Desacoplamento do Flutter Web para SEO**:
   * Criar um gerador de páginas estáticas (SSG em Python/Node) a partir de dados **revisados** de `assets/data/` (`ideological_currents.json`, `personalities.json`, `books_catalog.json`). **Não publicar automaticamente entradas sem referências.** O ZIP analisado possui 84 correntes, 84 personalidades e 76 livros, e esses três arquivos **não exibem campos de fontes nas primeiras entradas inspecionadas**.
   * Gerar HTML semanticamente completo, leve, com URL estável e canônica (por exemplo, `/atlas/socialismo-marxista/`), sem exigir CanvasKit para ler a página. Verificar rotas e deploy para não conflitar com rotas Flutter.
2. **Conteúdo de Autoridade e Fontes Primárias**:
   * Cada página exibe síntese original revisada, **fontes verificáveis com autoria/obra/data/link**, período e unidade de análise, distinção entre fatos e parametrização editorial, conexões com outras correntes e limitações. Trechos protegidos, imagens e capas exigem análise de licença.
   * Se uma entrada não possui fontes e validação suficientes, mantê-la fora da indexação pública ou publicá-la apenas após revisão editorial, sem alegar dados documentados.
3. **Ponte de Conversão**:
   * Cada página estática inclui `<title>`, descrição, URL canônica, OpenGraph/Twitter, imagem com direitos verificados e CTA contextual como *"Explore sua relação com estas ideias no Espectro"*; não prometer percentual de proximidade quando não houver evidência/calibração.
   * Gerar `sitemap.xml`, `robots.txt`, páginas 404 reais e links internos; confirmar o HTML entregue sem JavaScript e monitorar indexação.

#### Critérios de Aceite do P3:
* [ ] As páginas entregam o conteúdo principal no HTML inicial, sem depender do CanvasKit/Wasm. Indexabilidade é **capacidade técnica**, não garantia de que o Google vá indexar cada URL.
* [ ] Metatags, títulos e descrições únicas por verbete estruturadas para motores de busca.
* [ ] Links funcionais conectando Atlas estático, telas Flutter e pesquisa interna, sem quebrar deep links existentes.
* [ ] Verbetes selecionados foram revisados editorialmente, com fontes verificadas, direitos de mídia conferidos e sem dados inventados.

---

### P4 — Duelo de Ideias com Arquitetura de Privacidade

> **Objetivo**: Permitir comparação temática voluntária entre duas pessoas, **iniciando localmente** e com modelo de ameaça e conformidade à LGPD avaliados. **Não prometer criptografia ponta a ponta nem conformidade jurídica integral sem auditoria.**

#### Escopo do P4:
1. **Comparação Temática (Não Apenas Nota Geral)**:
   * Exibir convergências e divergências por grandes áreas:
     * Ex: *"Convergência em Liberdades Civis: 84% | Convergência em Organização Econômica: 31%"*.
     * Narrativa construtiva que destaca onde há pontos de contato em vez de estimular polarização estéril.
2. **Modelo de Segurança e Consentimento**:
   * **MVP recomendado:** comparação local no mesmo dispositivo, com confirmação explícita das duas pessoas; se usar exportação manual, compartilhar somente atributos agregados minimizados, nunca o banco completo de respostas por padrão.
   * Links, envelopes criptografados e servidores são escopo separado, condicionado a ameaça-modelagem, controle de acesso, expiração e revisão de segurança.
   * Não criar banco central de opiniões políticas no P4 local. Garantir exclusão local e permitir descartar uma sessão de comparação. **Não prometer revogar retroativamente arquivos que outra pessoa já copiou**.

#### Critérios de Aceite do P4:
* [ ] Antes da comparação, ambos compreendem os dados utilizados e confirmam a ação; cada participante consegue encerrar/excluir seus dados locais da sessão.
* [ ] Não expor respostas item a item por padrão; utilizar somente dimensões **comparáveis** e justificar matematicamente a métrica. Não apresentar 84% de convergência como probabilidade ou compatibilidade psicométrica validada.
* [ ] Não há ranking público, feed, telemetria de opiniões nem upload implícito.
* [ ] Testes de ausência de consentimento, exclusão, comparação com dimensões ausentes, versões incompatíveis e falha de armazenamento são executados.

---

## 4. Instruções Diretas para o Coder na Retomada dos Créditos

Quando a cota do Codex recarregar, o trabalho prático deve seguir estritamente o seguinte roteiro:

1. **Auditoria de estado antes de editar:** conferir `git branch --show-current`, `git status`, HEAD, commits recentes, arquivos modificados, testes e se a branch `visual/figma-design-polish` existe. A informação de que o Hero Figma `4:49` já está implementado/compilando é **relato do coder 2, ainda não verificado aqui**. Preservar mudanças não commitadas e criar checkpoint antes de alterações.
2. **Executar o P0 Imediato**:
   * Refinar as telas de resultado do Figma (`lib/ui/features/results/espectro_result_screen.dart`), assegurando que dimensões com dados ausentes ou indeterminados não desenhem porcentagens artificiais de 50%.
   * **Auditar e concluir** o gerador já existente de cartões em `lib/ui/features/share/shareable_card_sheet.dart`: captura PNG, proporções 9:16 e 1:1, contraste, mensagens derivadas de evidências, QR/URL público sem resultados pessoais e funcionamento Android/Web. Não substituí-lo cegamente.
   * Rodar `flutter analyze`, testes Flutter e, se disponível, testes de integração e inspeção em Android/Web. Relatar comandos, evidências, falhas e pendências, sem afirmar validação não executada.
3. **Não pular para o P1 ou P4 antes de validar o P0 completo**:
   * O ciclo *Questionário → Diagnóstico com Evidências → Cartão Fundamentado → Entrada Limpa de Novo Usuário* é a base de sustentação do produto. Substituímos "diagnóstico confiável" por linguagem compatível com o estágio atual de validação metodológica.
4. **Entrega por etapa:** registrar arquivos alterados, migrações, testes efetivamente executados, screenshots, limitações, decisões de metodologia, licenças e riscos de privacidade. Não expandir escopo sem completar os critérios de aceite da etapa.

---

## 5. Premissas verificadas, pendências e fontes

### Verificado na cópia `espectro-b.zip` compartilhada anteriormente (não necessariamente branch atual)

- `assets/data/ideological_currents.json`: **84** correntes.
- `assets/data/personalities.json`: **84** personalidades.
- `assets/data/books_catalog.json`: **76** obras.
- `lib/ui/features/share/shareable_card_sheet.dart`: recurso existente, com `RepaintBoundary`, exportação PNG e formatos 1:1/9:16.
- `pubspec.yaml` da cópia inspecionada **não declara fontes IBM Plex**; checar se a branch de design já corrigiu isso.
- O ZIP não comprova o estado atual da branch, nem autoriza presumir que a implementação atual do Flutter Web funciona, ou que todos os testes estão passando.

### Fontes externas consultadas

- 12 Axes especificado: https://12axes.vercel.app/br (36/60/240 perguntas).
- Repositório e licenciamento da implementação: https://github.com/RomanCypherpunk/12axes (código e catálogo *source-available*, não livre para cópia comercial sem autorização).
- Six Triangles: https://sixtriangles.github.io/ (72/144 perguntas; seis diagramas ternários).
- LGPD, art. 5º, II: https://www2.camara.leg.br/legin/fed/lei/2018/lei-13709-14-agosto-2018-787077-normaatualizada-pl.html
- Google Search Central, JS e rastreamento: https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics

### Decisões a registrar na retomada

1. Qual é a contagem real e a proveniência de cada catálogo na branch atual? Existe alteração documentada de 84 para 124?
2. Quais regras quantitativas de cobertura têm justificativa? Há validação empírica dos índices ou apenas heurísticas transparentes?
3. Como o compartilhamento em Flutter Web recebe e baixa imagem sem falha por APIs de plataforma?
4. Qual política de retenção de dados políticos vale para Android/Web e futuras exportações?
5. Quais URLs e páginas de resultados podem ser divulgadas sem expor atributos políticos sensíveis?
6. Que critérios de publicação e revisão editorial serão exigidos para tornar os verbetes do Atlas públicos?

