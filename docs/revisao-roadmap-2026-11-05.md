# Revisão do Espectro — 5 de novembro de 2026

Esta entrega conclui a revisão de teia, organização visual e expansão do acervo solicitada na conversa, junto das correções P0 encontradas ao ler `especificacao-estrategica-e-roadmap.md`. As etapas futuras P1–P4 do documento não são declaradas implementadas.

## Resultado entregue

- Teia ocupa o viewport, com diagrama de Nolan quadrado, pan, pinça, roda, zoom, reenquadramento, seleção e abertura de perfil. Todos os 289 verbetes de correntes participam do layout, sem corte de quantidade.
- 227 correntes possuem base para Nolan. Outras 62 aparecem na área selecionável **Sem posição**, fora do quadrado; seu lugar nessa área é apenas organização visual. Não há ponto central artificial nem conexões por proximidade entre essas fichas.
- Seletor permite explorar quaisquer dois dos 12 eixos, mantendo dados ausentes explícitos. Busca e filtros incluem todos os verbetes, inclusive pontos sobrepostos e fichas sem projeção.
- Oito espectros na ordem pedida: esquerda radical, esquerda, centro, direita, extrema-direita, anarquistas, libertários e terceira posição. Identificação por barra colorida, sem ícones políticos. Lista agrupada e ordenada por espectro e nome.
- Catálogo offline: **289 correntes, 124 personalidades, 165 livros, 110 partidos/movimentos, 94 experiências históricas e 80 países/modelos**; total de 862 fichas.
- Foram acrescentadas 165 correntes, 85 livros, 54 partidos/movimentos e 46 recortes históricos. Vinte candidatos redundantes foram removidos; sete registros com referências exatas quebradas foram excluídos desta ampliação. Não foram copiados textos ou vetores do 12 Axes.
- As fichas expõem referências contextuais, escopo, limites e parametrização editorial. As novas posições parciais permanecem provisórias e ficam fora do classificador nativo até revisão dimensional suficiente; quantidade de catálogo não implica validade psicométrica.
- Cartões 1:1 e 9:16 usam o mesmo canvas no preview e na captura. Capturas reais de teste têm 1080×1080 e 1080×1920. Nolan ausente permanece indeterminado no cartão e no PDF; ausência não vira porcentagem nem composição triádica artificial.
- Download e compartilhamento têm ações e tratamento de erros próprios. Links de entrada não carregam respostas; exportação explícita de respostas exige confirmação. Metadados da entrada Web e nome/cores do manifesto identificam o Espectro.
- CTA de explicação do resultado agora abre evidências de um eixo observado. Linguagem de confiança empírica foi substituída por limites de cobertura e estimativas do modelo.

## Validação

- **PASS:** 192 testes Flutter, incluindo motores, dados, navegação, restauração de câmera, texto ampliado, gestos, regressões visuais e PNG real.
- **PASS:** análise estática de `lib` e `test`, sem problemas.
- **PASS:** build Web release e build APK debug. O APK é uma versão para teste, não publicação de produção.
- **PASS:** inspeção MCP REA do seletor de eixos no build Web, com screenshot, acessibilidade e nenhum erro de página. Evidência em `docs/qa/revision-2026-11-05/rea-axes.json`.
- A verificação de gestos reais no Chromium em 390 e 1440 px tem relatório separado `docs/qa/revision-2026-11-05/browser.json`; screenshots e árvores acessíveis ficam na mesma pasta.
- Referências: 341 vínculos editoriais para 317 URLs únicas; 242 responderam HTTP200, nenhuma respondeu404. Os demais registram bloqueios403, DNS/TLS ou indisponibilidade em `docs/catalog-round2-reference-access.json`. HTTP200 não certifica uma interpretação histórica nem um valor numérico.
- **NOT_RUN:** instalação e sessão em Android físico, galeria/share sheet do sistema, deploy público e indexação de produção. Não há origem pública Android configurada nesta sessão; nesse ambiente, o recurso informa ausência do link completo.

## Artefatos

- APK: `build/app/outputs/flutter-apk/espectro-revisao-2026-11-05.apk`.
- SHA256: `b4a491f7ef3794f9777d13ff0c0cb4209d270d35909b7c87a15c87e7a4969876`.
- Web: `build/web`.
- Manifesto de validação: `docs/qa/revision-2026-11-05/validation.json`.
- Curadoria reproduzível: `tool/curation/*_round2.tsv` e `tool/expand_catalog_round2.py`.

A interrupção por limite de uso da revisão automática registrada anteriormente foi superada nesta continuação. Os resultados acima substituem o estado parcial do relatório anterior, sem atribuir às etapas futuras ou a dispositivos não testados uma validação inexistente.
