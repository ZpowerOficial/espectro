# Ampliação documental — catálogo 4.2.0

O pedido de revisar todo o acervo continua em andamento. Este lote amplia a documentação e corrige lacunas específicas; não declara uma auditoria histórica integral das 862 fichas.

## O que mudou

- Nazismo: Moral agora remete ao discurso de 8 de setembro de 1934 sobre emancipação e papéis de homens e mulheres. Diplomacia remete ao registro Hossbach da reunião de 5 de novembro de 1937. Comércio também recebeu leitura desse registro. O recorte da ficha foi ampliado explicitamente para 1920–1937, distinguindo programa, legislação, discurso e ata posterior à reunião.
- Há **59 novos dossiês bibliográficos**, com **58 conferências de trechos** e uma referência ainda pendente de acesso. Não se confunde conferir um trecho com validar integralmente uma obra ou medir uma coordenada.
- **153 fichas** têm agora pelo menos uma dimensão vinculada a trecho primário; **371 dimensões** possuem esse suporte específico. Isso inclui os três perfis da revisão anterior e novos recortes de livros, personalidades, correntes, partidos e países.
- **524 fichas** têm referências cadastradas, incluindo leituras contextuais anteriores. Esse número não representa 524 fichas inteiramente auditadas, nem 524 fontes únicas.
- Todas as **862 fichas** estão no inventário de cobertura. Há **15.120 dimensões ainda não revisadas**, além de **25 insuficientes no recorte consultado**, de um total de 15.516 possibilidades. Nenhuma ficha tem as 18 dimensões integralmente documentadas nesta etapa. A fila completa permanece em `primary-review-queue-2026-11-05.json`.

## Leitura na interface

“Revisão por dimensão pendente” significa que ainda falta conferir e vincular o trecho. Não significa que inexistam evidências históricas. “O recorte consultado não permite fixar uma posição” é usado quando a documentação já selecionada não permite parametrização suficiente. Uma fonte primária pode sustentar uma discussão qualitativa sem fornecer posição numérica ou composição triangular.

As fichas mostram autoria, data, edição/repositório, localização do trecho e justificativa própria do Espectro. Referências contextuais são diferenciadas de documentos efetivamente vinculados a dimensões. A data do cadastro editorial não é apresentada como certificado de revisão factual completa.

Nas tríades, o corpus pode documentar um vértice ou uma tensão sem fornecer uma escala comum para os três. Por exemplo, ausência de Estado em Rothbard não é idêntica à minarquia; o texto de Mill relaciona liberdade de discussão e busca da verdade. Nesses casos, há fonte e explicação, mas nenhum ponto artificial de composição. Coordenadas ativas continuam sendo estimativas editoriais provisórias, sem validação empírica.

## Fontes e procedência

As novas leituras incluem textos de Marx e Engels, Lênin, Luxemburgo, Bernstein, Pannekoek, Mao, Trotsky, Proudhon, Bakunin, Kropotkin, Goldman, Malatesta, Tucker, Spooner, Mill, Locke, Hobbes, Rousseau, Smith, Burke, Bastiat, Rothbard, Mises e Hayek; documentos católicos; manifestos digitais e da IWW; programa dos Panteras Negras; constituições; e discursos/programas de Roosevelt, Reagan, Thatcher e Allende. Cada vínculo é limitado ao recorte indicado, sem imputar ao autor toda posição de uma tradição ou atribuir a uma declaração sua execução histórica.

O repositório público [12axes](https://github.com/RomanCypherpunk/12axes) foi consultado pelo conector MCP para localizar possíveis referências. Sua [licença](https://github.com/RomanCypherpunk/12axes/blob/main/LICENSE) é de código disponível para leitura, com reutilização restrita. Não foram importados perfis, descrições, respostas, código, vetores ou fórmulas. O arquivo de livros consultado traz diversas URLs vazias; a auditoria de comunismo consultada não fornece bibliografia por trecho. Portanto, o acesso ao repositório não resolveu automaticamente a revisão primária.

As referências do Espectro foram consultadas diretamente. Textos integrais obtidos para leitura ficam temporariamente em `/tmp/espectro-primary-readings`, sem distribuição pelo aplicativo. O manifesto versionado registra títulos, autoria, datas, URLs, trechos e interpretações próprias; não reproduz os livros.

## Reprodução e limites

`tool/curation/build_primary_reading_seed.py` produz os dossiês originais. `tool/fetch_primary_readings.py` registra acesso técnico, separado da leitura. `primary_reading_verification.json` declara as conferências de trechos. `tool/integrate_primary_readings.py` aplica somente as interpretações explicitamente conferidas e produz o inventário de cobertura. A integração é idempotente e reaplicada na regeneração do catálogo.

A Constituição francesa localizada não foi marcada como lida: houve bloqueio/limitação de acesso. Alguns documentos que falharam na busca direta foram lidos pelo navegador de pesquisa, e esse método está registrado. Catálogos bibliográficos e páginas de apresentação não foram usados como se fossem o conteúdo integral da obra.

As estimativas antigas não auditadas continuam identificadas como provisórias. A revisão não converte automaticamente fontes novas em resultados do teste: fichas com novas interpretações parciais permanecem fora da classificação nativa até revisão adequada. Os limites da cobertura são dados do produto e estão registrados sem substituir pesquisa por preenchimento automático.

## Validação

Os resultados finais de testes, análise estática, navegador e builds constam em `qa/sources-expansion-2026-11-05/validation.json`. APK de teste: `build/app/outputs/flutter-apk/espectro-fontes-ampliadas-2026-11-05.apk`. Não há publicação de produção nem teste em Android físico nesta revisão.
