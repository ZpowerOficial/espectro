# Revisão documental e triângulos — 5 de novembro de 2026

> Registro do lote 4.1.0. A ampliação posterior 4.2.0 está em [fontes-ampliacao-2026-11-05.md](fontes-ampliacao-2026-11-05.md); o inventário de cobertura foi atualizado por esse novo lote.

## Critério editorial

O Espectro usa terceira posição para fascismo, nazismo e as variantes explicitadas no manifesto JSON desta revisão, e direita para Jair Bolsonaro. Essa organização atende à convenção solicitada para o aplicativo; não é apresentada como consenso historiográfico. A referência do USHMM classifica fascismo como extrema-direita. A nota na ficha distingue esses critérios em vez de afirmar que um documento resolve, sozinho, a classificação.

## Revisão de conteúdo

Foram refeitos três recortes: fascismo italiano (Carta del Lavoro de 1927 e doutrina de 1932), nazismo (programa de 1920, explicação de 1928 e Lei de Plenos Poderes de 1933) e Jair Bolsonaro (declarações da posse e legislação econômica de 2019).

Os textos são tratados como declarações doutrinárias, registros institucionais ou atos legais; uma declaração não comprova implementação. O programa nazista e a explicação posterior sobre propriedade não foram fundidos em um número artificial. Na ficha de Bolsonaro, segurança e autodefesa não foram convertidas numa nota geral de liberdade civil. Notas de fascismo que misturavam urbanismo, política externa e organização governamental foram removidas/corrigidas.

Cada ficha revista tem um estado independente para os 12 eixos e as 6 tríades, com documento e trecho quando há suporte. A presença de fonte não valida numericamente a posição. Os valores ativos são estimativas editoriais; composições não medem apoio absoluto. Dimensões sem base suficiente permanecem ausentes, inclusive onde o catálogo antigo trazia números.

O PDF de 2018 do TSE retornou403 e páginas da Biblioteca da Presidência falharam no acesso automático. Esses documentos não são marcados como lidos. A lei foi consultada em reprodução institucional da Câmara/CEVS, e as declarações inaugurais em trechos atribuídos diretamente ao orador pela Agência Câmara. A Carta del Lavoro foi lida no texto italiano transcrito; o comentário do site anfitrião não foi usado como documento primário. Dados completos de autoria, edição, data e repositório estão no JSON da revisão e nas fichas.

## Visualização

Fichas e comparação exibem seis diagramas triangulares: vértices nomeados, grade, pontos baricêntricos e legenda com proporções. Toque ou arraste horizontal inspeciona a geometria sem editar o perfil; arraste vertical continua a rolagem. Quando falta composição, o triângulo aparece sem ponto central. Perfis de catálogo não recebem contagens fictícias de respostas, apoio absoluto nem halo de erro estatístico.

## Limite da auditoria

A auditoria estrutural cobre as 862 fichas e torna explícita a falta de referências por dimensão. Apenas os três recortes acima receberam revisão documental detalhada nesta etapa; os outros verbetes não são declarados auditados com fontes primárias. Consulte `primary-coverage-audit-2026-11-05.json`. Revisão completa do restante do acervo permanece pendente, assim como validação empírica das coordenadas. Isso não é resolvido por aumentar contagens, adicionar um link geral ou trocar uma cor.

A geração reproduzível está em `tool/review_primary_profiles.py`, chamada também ao regenerar a expansão. As correções não dependem de edição manual que seria perdida na próxima geração.


## Verificações e artefatos

- Catálogo documental: versão **4.1.0**; IDs estáveis preservados.
- **PASS:** suíte completa com 201 testes; revisão posterior de rótulo e semântica validada pelos testes focados.
- **PASS:** análise estática sem problemas; geometria, toque, ausência de ponto em lacunas e seis triângulos em 390/1440 px com texto 2x.
- Build e inspeção no navegador: veja `docs/qa/primary-triangles-2026-11-05/validation.json` e screenshots na mesma pasta. O relatório registra separadamente o que foi observado em runtime e o que foi verificado em widgets.
- APK de teste: `build/app/outputs/flutter-apk/espectro-fontes-triades-2026-11-05.apk`. Não houve teste em Android físico nem publicação de produção.

## Referências consultadas

- [Doutrina fascista de 1932, excertos traduzidos — Fordham IHSP](https://sourcebooks.web.fordham.edu/mod/mussolini-fascism.asp).
- [Carta del Lavoro de 1927 — transcrição italiana](https://www.polyarchy.org/basta/documenti/carta.lavoro.1927.html).
- [Programa NSDAP e explicação de 1928 — documento 1708-PS, Avalon/Yale](https://avalon.law.yale.edu/imt/1708-ps.asp).
- [Lei de Plenos Poderes de 1933 — texto primário traduzido, GHDI](https://germanhistorydocs.org/en/nazi-germany-1933-1945/ghdi:document-1496).
- [Declarações na posse de 2019 — Agência Câmara](https://www.camara.leg.br/noticias/550448-ao-tomar-posse-bolsonaro-pede-apoio-ao-congresso-para-restaurar-e-reerguer-o-brasil).
- [Lei nº 13.874 — edição da Câmara arquivada no CEVS/RS](https://www.cevs.rs.gov.br/upload/arquivos/202009/01143704-lei-da-liberdade-economica-federal.pdf).
- [Classificação histórica de contexto — USHMM](https://encyclopedia.ushmm.org/content/en/article/fascism-1).
