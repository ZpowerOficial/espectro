# Reconstrução editorial dos perfis

## Entrega e alcance

Rothbard, Marx e Mises agora têm 12 eixos e seis tríades derivados de 60 respostas editoriais por perfil: 180 respostas com enunciado original do Espectro, fonte, localizador, justificativa e ressalvas. São reconstruções de programas e textos identificados, não entrevistas, medições de personalidade ou precisão histórica absoluta.

As respostas estão disponíveis em **Atlas → perfil → Dimensões → Respostas reconstruídas e fontes**. Os links levam aos textos primários. A seleção de itens é temática e varia entre perfis para reduzir anacronismos; portanto, não representa uma forma aleatória ou psicometricamente equivalente ao questionário pessoal.

O recorte de Rothbard usa *For a New Liberty*, edição revista de 1978, e não importa suas posições migratórias dos anos 1990. Marx reúne documentos de 1842–1875, distinguindo Comuna, transição e fases da sociedade comunista. Mises usa *Liberalismo* de 1927 e mantém a defesa de instituições supranacionais, divergente do programa sem Estado de Rothbard.

## O que os números não resolvem

- A tríade Governo não possui vértice Anarquia. Concordar com itens críticos ao Estado pode gerar peso em Minarquia sem tornar Marx ou Rothbard minarquistas; essa limitação aparece na nota da dimensão.
- O vértice Verdade combina compromisso com fatos e punição por falsidades. As respostas distinguem ética informativa de censura.
- O eixo Religião, nos itens usados, mede laicidade jurídica; não identifica a crença privada do autor.
- Itens de moral, imigração e tecnologia que extrapolam o vocabulário histórico são identificados como interpretação. Preenchê-los não transforma a hipótese em declaração textual.
- Os perfis antigos de correntes ainda usam estimativas editoriais heterogêneas. Uma afinidade geométrica não certifica filiação. Não se ajustaram respostas para obrigar anarcocapitalismo ou marxismo a ocupar o primeiro lugar.

## Correção adicional nas sugestões

A checagem encontrou fichas esparsas liderando sugestões por coincidirem em poucos temas. `StudyCatalog.related` agora exige no mínimo oito dimensões compartilhadas e sobreposição de 60% da união disponível. A comparação manual continua informando a cobertura mesmo abaixo desse patamar. O limite é editorial, não uma validação estatística.

No diagnóstico atual do Atlas, Rothbard tem proximidade de 76,0 com anarcocapitalismo; Marx, 79,1 com comunismo e 78,6 com socialismo marxista; Mises, 82,5 com liberalismo clássico. Esses valores são índices exploratórios, não probabilidades. As sugestões de primeiro lugar ainda divergem de algumas filiações intelectuais documentadas. Isso permanece uma pendência de revisão das correntes, da seleção de itens e da adequação dos constructos, sem ajuste dirigido ao resultado esperado.

## Reprodução

1. Editar as interpretações e fontes em `tool/curation/build_editorial_reconstructions.py`; executar o arquivo com Python.
2. Gerar as coordenadas com `flutter test test/domain/editorial_reconstruction_test.dart --dart-define=UPDATE_EDITORIAL_RECONSTRUCTIONS=true --plain-name 'editorial coordinates reproduce'`.
3. Executar `python3 tool/integrate_primary_readings.py`. O replay editorial ocorre depois das revisões antigas e impede que campos completados sejam apagados.
4. Executar os testes normalmente, sem a opção de atualização. Os números devem reproduzir o motor real.

O artefato de escores inclui o dossiê de entrada e os enunciados, pesos e polaridades usados. A integração rejeita mudanças não recalculadas nesses dados. As estatísticas de respondentes e erros padrão do motor não são transferidas à reconstrução histórica. A integração repetida produziu arquivos idênticos.

## Saldo do catálogo

Inventário após esta rodada, separando presença numérica de documentação:

| Categoria | Fichas | Com 18 posições numéricas | Posições ausentes |
|---|---:|---:|---:|
| Correntes | 289 | 79 | 2.666 |
| Personalidades | 124 | 81 | 169 |
| Países e modelos | 80 | 79 | 1 |
| Partidos e movimentos | 110 | 56 | 806 |
| Episódios históricos | 94 | 47 | 687 |
| Obras | 165 | 71 | 1.378 |
| Total | 862 | 413 | 5.707 |

Há 355 dimensões com leitura primária direta vinculada e 54 com reconstrução editorial identificada. Dezesseis leituras diretas anteriores dos três autores passaram à categoria reconstrução porque agora sua coordenada depende de respostas atribuídas; a mudança da contagem não indica perda das fontes. Dimensões antigas sem conferência permanecem na fila documental. Nenhuma das demais fichas é declarada integralmente revisada nesta entrega. Obras podem continuar parciais quando seu escopo não cobre uma dimensão.

Evidências de navegação e screenshots: `docs/qa/editorial-reconstruction-2026-11-05/`. Afinidades calculadas: `build/artifacts/editorial-reconstruction/affinities.json`. O inventário completo e a fila de revisão continuam em `docs/primary-coverage-audit-2026-11-05.json` e `docs/primary-review-queue-2026-11-05.json`.

## Validação desta rodada

- Suíte completa: 214 testes aprovados, incluindo regressões de resultados pessoais, catálogo, navegação e referências visuais.
- Após limitar o aviso de inelegibilidade às correntes, 11 testes de perfis e reconstrução passaram novamente.
- Análise estática: nenhum problema encontrado. Compilação web aprovada.
- Navegador: fontes e respostas dos três autores acessíveis em 390 e 1440 px, sem erros de página nos seis cenários.
- MCP REA: captura local com evidência registrada em `docs/qa/editorial-reconstruction-2026-11-05/rea.json`.
- Dispositivo físico: não executado nesta rodada. Testes matemáticos não validam a verdade histórica das interpretações.

A próxima revisão documental deve tratar as correntes usadas como referência — começando por anarcocapitalismo, comunismo, socialismo marxista e liberalismo clássico — sem herdar automaticamente o vetor de seu autor mais conhecido. As divergências do diagnóstico de afinidades são parte dessa fila, não algo a esconder ajustando rótulos.
