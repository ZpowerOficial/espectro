# ESPECTRO — Especificação Estratégica, Metodologia e Roadmap de Implementação

> **Documento de alinhamento técnico e de produto para o desenvolvedor principal.**  
> Este documento consolida a síntese estratégica aprovada, os princípios metodológicos invioláveis, a arquitetura de interoperabilidade e o roadmap de implementação priorizado (P0 a P4) com critérios objetivos de aceite.

---

## 1. Visão e Posicionamento da Marca

### Slogan e Proposta de Valor
> ### *"Sua política não termina no resultado.*  
> *Traga seus testes, explore novas dimensões e descubra onde suas ideias se encontram — ou divergem."*

### Diagnóstico de Mercado
1. **Onde outros testes falham**:
   * **Political Compass**: 2 eixos estáticos e anacrônicos.
   * **Six Triangles**: Pioneiro na aplicação da geometria ternária/baricêntrica à política, mas permaneceu de nicho pela complexidade matemática abstrata e baixa moeda social imediata.
   * **12 Axes**: Popularizou-se pelo formato compartilhável e catálogo extenso (230+ ideologias, 390+ figuras históricas), mas funciona como um "rótulo final estático" de sentido único.
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
  * 12 a 18 perguntas fornecem apenas **prévia exploratória**, devendo manter a maior parte das dimensões como **explicitamente indeterminadas**.
  * A classificação quantitativa só deve ser computada e exibida quando a dimensão atingir o limiar documentado de cobertura mínima.

### 2. Ausência Explícita de Dados (Zero Centro Falso)
* Quando uma dimensão não foi avaliada ou possui `relevance: 0.0`, o sistema **nunca** deve preencher com 50%, centro artificial ou média da população.
* A ausência de dados deve ser tratada como valor nulo/indeterminado em **toda a cadeia**: motores de cálculo, diagramas de Nolan, gráficos de barras divergentes, radares, histórico, exportação PDF e cartões visuais.

### 3. Dualidade de Perfis e Proveniência de Dados
* Resultados importados de outros testes (ex: 12 Axes) não são respostas a itens do Espectro.
* O sistema deve separar e apresentar explicitamente:
  * **Perfil Combinado por Fontes**: Exibe dados externos rotulados com sua origem e dados nativos observados.
  * **Perfil Nativo Espectro**: Apresenta exclusivamente dimensões medidas pela metodologia e banco de afirmações do Espectro.

### 4. Privacidade e LGPD por Padrão
* Opiniões políticas vinculadas a pessoas identificadas ou identificáveis são **dados pessoais sensíveis** (Art. 5º, II da LGPD).
* Princípio da minimização:
  * Sem cadastro obrigatório.
  * Processamento local no dispositivo.
  * Armazenamento seguro: evitar persistência de identificadores políticos em `localStorage` aberto sem controle de origem.
  * Comparações entre usuários ("Duelo") devem ser **estritamente privadas e consensuais**, sem rankings públicos ou telemetria de respostas.

---

## 3. Roadmap Priorizado (P0 a P4) e Critérios de Aceite

---

### P0 — O Primeiro Ciclo Perfeito de Produto (Foco Imediato)

> **Objetivo**: Fechar um ciclo ponta a ponta perfeito: responder ao questionário nativo com navegação fluida, receber uma análise fundamentada, gerar cartões visuais atraentes e permitir que um terceiro acesse a plataforma com clareza.

#### Escopo do P0:
1. **Hierarquia e Design System (Figma)**:
   * Alinhar as telas de resultado e questionário à linguagem visual oficial do Figma (nós `4:49`, `7:16`, `7:24`, `14:15`).
   * Tipografia consistente em `IBMPlexSans` e `IBMPlexMono`, paleta ardósia/petróleo/âmbar (`#0C1C27`).
2. **Diagnóstico Fundamentado (Sem rótulos vazios)**:
   * A tela de resultados deve mostrar:
     * O que aproxima o usuário das correntes históricas.
     * O que o diferencia (contrastes e tensões observadas).
     * O que permaneceu indeterminado ou com incerteza amostral.
3. **Cartões Compartilháveis com Substância**:
   * Formato Story 9:16 e Feed 1:1.
   * Não gerar caricaturas ("comunista de boutique"), mas sim **"Minha Descoberta Mais Surpreendente"**: tensões reais entre dimensões com dados comprovados pelas respostas.
   * Inclusão de link limpo ou QR code que aponte para o início de uma nova avaliação.

#### Critérios de Aceite do P0:
* [ ] Fluxo início → questionário → resultado → compartilhamento executável sem erros de renderização ou overflow de tela em 390 px e 1440 px.
* [ ] Nenhuma dimensão sem resposta assume 50% ou ponto central no diagrama de Nolan ou no gráfico divergente.
* [ ] Cartão compartilhado exporta imagem de alta resolução com proveniência e texto fundamentado nas respostas reais.
* [ ] Todos os testes de layout e motores passam sem falhas de regressão.

---

### P1 — Importador Universal de Resultados: 12 Axes (Fiel e Manual)

> **Objetivo**: Permitir que usuários que já concluíram o 12 Axes tragam seus resultados anteriores para dentro do Espectro sem o atrito de refazer um teste de 70+ itens.

#### Escopo do P1:
1. **Entrada Manual Confiável**:
   * Interface para inserir as porcentagens dos 12 eixos bipolares do 12 Axes.
   * Validação de complementariedade ($p_{left} + p_{right} \approx 100\%$) com tolerância a arredondamentos.
2. **Modelo de Dados Isolado**:
   * Criar entidades independentes de `EvaluationRecord`:
     * `ImportedPoliticalResult`
     * `ImportedAxisValue`
   * Proibido reconstruir respostas individuais ou inventar pontuações para as 6 tríades.
3. **Visualização do Resultado Importado**:
   * Gráfico fiel dos 12 eixos originais.
   * Painel: *"O que seu teste anterior mediu"* (12 eixos agregados) vs. *"O que ainda não sabemos"* (6 tríades, intensidade de apoio, contradições específicas).

#### Critérios de Aceite do P1:
* [ ] Importação manual armazena os dados sem criar registros fictícios em `EvaluationRecord`.
* [ ] A tela de visualização rotula explicitamente a origem como "12 Axes (Importado)".
* [ ] Não há cálculo de compatibilidade direta com as 124 correntes nativas baseado apenas em dados externos sem calibração.
* [ ] Funciona 100% offline e com persistência local independente.

---

### P2 — Aprofundamento Progressivo e Investigação por Curiosidade

> **Objetivo**: Oferecer caminhos para que o usuário explore dimensões adicionais e esclareça divergências sem ser obrigado a recomeçar questionários do zero.

#### Escopo do P2:
1. **Sessão Suplementar Nativa**:
   * Usuários com teste importado ou teste rápido podem responder a blocos complementares (ex: afirmações exclusivas das tríades).
   * As respostas nativas são armazenadas em `NativeSupplementSession`.
2. **Investigação Dirigida por Curiosidade**:
   * Ao consultar duas correntes no Atlas (ex: Liberalismo Clássico vs. Anarcocapitalismo), o usuário tem a opção: *"Descubra o que diferencia sua visão dessas duas correntes"*.
   * O sistema apresenta perguntas focadas exclusivamente nos eixos de divergência entre elas, sem induzir o resultado nem ensinar como obter determinado rótulo.
3. **Apresentação de Cobertura**:
   * Indicador visual claro de progresso por dimensão (Indeterminado → Cobertura Inicial → Cobertura Consolidada).

#### Critérios de Aceite do P2:
* [ ] Respostas complementares permanecem registradas como observações nativas, sem reescrever a importação externa.
* [ ] Dimensões que não atingiram a cobertura mínima de afirmações mantêm o estado de incerteza/indeterminação.
* [ ] A investigação dirigida não induz respostas e calcula deltas apenas sobre os eixos efetivamente respondidos.

---

### P3 — Atlas Público e SEO (Páginas Estáticas)

> **Objetivo**: Construir um canal permanente de aquisição orgânica via busca no Google para quem pesquisa sobre ideologias, autores e obras históricas.

#### Escopo do P3:
1. **Desacoplamento do Flutter Web para SEO**:
   * Criar um script gerador de site estático (SSG em Python/Node) que consome `assets/data/` (`ideological_currents.json`, `personalities.json`, `books_catalog.json`).
   * Gera páginas HTML estáticas, leves e semanticamente ricas para cada verbete (`/atlas/socialismo_marxista.html`, `/atlas/adam_smith.html`).
2. **Conteúdo de Autoridade e Fontes Primárias**:
   * Cada página exibe síntese histórica, eixos documentados, leituras primárias com referências reais (sem alucinações) e conexões com outras correntes.
3. **Ponte de Conversão**:
   * Cada página estática contém metatags OpenGraph ricas e um CTA explícito: *"Descubra sua proximidade com estas ideias no Espectro"*, direcionando para a aplicação interativa.

#### Critérios de Aceite do P3:
* [ ] As páginas estáticas são indexáveis sem depender da execução do CanvasKit/Wasm do Flutter.
* [ ] Metatags, títulos e descrições únicas por verbete estruturadas para motores de busca.
* [ ] Links funcionais conectando o Atlas estático à avaliação interativa do app.

---

### P4 — Duelo de Ideias com Arquitetura de Privacidade

> **Objetivo**: Permitir a comparação direta e temática entre amigos com segurança criptográfica e conformidade integral com a LGPD.

#### Escopo do P4:
1. **Comparação Temática (Não Apenas Nota Geral)**:
   * Exibir convergências e divergências por grandes áreas:
     * Ex: *"Convergência em Liberdades Civis: 84% | Convergência em Organização Econômica: 31%"*.
     * Narrativa construtiva que destaca onde há pontos de contato em vez de estimular polarização estéril.
2. **Modelo de Segurança e Consentimento**:
   * Comparação local imediata ou via envelope de dados assinado/criptografado.
   * Não armazenar pares de identificadores pessoais e votos em banco de dados centralizado sem criptografia.
   * Opção explícita de revogação e exclusão mútua dos dados compartilhados.

#### Critérios de Aceite do P4:
* [ ] Dados de dois participantes só são processados mediante ação e consentimento explícito de ambos.
* [ ] A comparação não expõe respostas individuais item a item, operando sobre deltas dimensionais agregados.
* [ ] Nenhum ranking público ou feed de terceiros é gerado.

---

## 4. Instruções Diretas para o Coder na Retomada dos Créditos

Quando a cota do Codex recarregar, o trabalho prático deve seguir estritamente o seguinte roteiro:

1. **Branch de Trabalho**: Continuar na branch `visual/figma-design-polish` (onde o Hero `4:49` já está implementado e compilando).
2. **Executar o P0 Imediato**:
   * Refinar as telas de resultado do Figma (`lib/ui/features/results/espectro_result_screen.dart`), assegurando que dimensões com dados ausentes ou indeterminados não desenhem porcentagens artificiais de 50%.
   * Concluir o gerador de cartões de descoberta compartilháveis em formato Story (9:16) em `lib/ui/features/share/shareable_card_sheet.dart`.
   * Rodar testes de regressão de layout e motores.
3. **Não pular para o P1 ou P4 antes de validar o P0 completo**:
   * O ciclo *Questionário → Diagnóstico Confiável → Cartão Fundamentado → Entrada Limpa de Novo Usuário* é a base de sustentação de todo o produto. Sem ele, nenhum mecanismo viral se sustenta.
