# Auditoria do dossiê de 60 respostas — motor 2.2.0

## Resultado verificável

O link fornecido pelo usuário foi decodificado localmente. A semente selecionou exatamente o mesmo conjunto de 60 identificadores: 24 itens de eixos (dois por eixo) e 36 de tríades (dois por vértice). Nenhuma resposta foi enviada ao concorrente. O replay preservou os scores do PDF original e o Nolan: **98,8% econômico e 80,9% civil**, incluindo as incertezas heurísticas anteriormente publicadas. As respostas e os resultados reprocessados estão em artefatos locais de build, não em uma fixture pública com a identidade da sessão.

O novo PDF é `build/artifacts/dossier-audit/resultado_reprocessado_60_respostas.pdf`. Não substitui os PDFs do usuário em Downloads. `replay-summary.json` registra o resultado do replay e `record_reprocessado.json` contém os dados locais reprocessados. Estes arquivos contêm preferências pessoais: não foram enviados a serviço externo nem publicados.

## Erro da validação anterior

O teste anterior chamado “vetor extraído com precisão” continha valores diferentes do original:

| Eixo | PDF original | Fixture anterior |
|---|---:|---:|
| Representação | −1,00 | +0,11 |
| Poder | +0,11 | −1,00 |
| Imigração | +0,50 | +1,00 |
| Diplomacia | +0,11 | +0,50 |
| Tecnologia | −0,25 | omitido, virava zero |

Havia também uma chave inexistente `seguranca`. O teste inventava cinco respostas por dimensão, erros-padrão de 0,15 e apoios por vértice iguais às composições. Por isso o PDF “CORRIGIDO” mudou o Nolan civil para 67,5%. Ele não era uma reprodução fiel da sessão. A fixture foi substituída por uma transcrição anônima explicitamente arredondada; o replay das respostas originais é um teste separado. Sem o arquivo privado, esse replay aparece como não executado, não como um teste aprovado silenciosamente.

Os novos testes não exigem um ganhador ideológico, país específico ou percentual mínimo escolhido para agradar ao caso. Conferem fidelidade de entrada, geometria, cobertura e limites. Autocompatibilidade de 100% é identidade matemática do modelo, não prova de validade histórica ou científica.

## Correções desta revisão

1. **Estabilidade da amostra.** Dois itens por eixo ou por vértice não recebem confiança alta apenas porque todos foram respondidos. Eixos com menos de quatro respostas e tríades com menos de três por vértice têm estabilidade baixa; os limiares maiores continuam explicitamente heurísticos. Os scores não foram deslocados para parecer mais moderados.
2. **Tensões visíveis.** A própria sessão original já registrava tensões em Poder, Imigração, Diplomacia, Intervenção e Moral. O PDF antigo só mostrava regras de tensões entre dimensões e dizia “alta consistência” quando estas não disparavam. O PDF agora mostra as tensões entre itens e não certifica coerência. Concordar com proteção criptográfica e compartilhamento de informação bancária sem ordem judicial, por exemplo, pode refletir distinções de contexto; não prova incoerência pessoal.
3. **Elegibilidade reproduzível.** O critério é cobertura, sem blacklist moral ou por espectro: ao menos oito dimensões parametrizadas, mais 60% das dimensões válidas do usuário em comum. Há 117 correntes elegíveis no catálogo e 110 comparáveis nesta sessão. Fisiocracia não vence omitindo a maior parte dos temas. Fascismo e nazismo não são excluídos por um juízo moral; podem participar ou não conforme os mesmos limites de cobertura.
4. **Empate comunicado.** O PDF e a visão resumida do desktop não reduzem proximidades dentro da margem técnica de 4,5 pontos a uma identidade única. No replay atual, as primeiras referências são Libertarianismo Consequencialista (77,3), Voluntarismo (76,5) e Minarquismo (75,5), sem afirmar que o usuário adere a uma delas. Anarcocapitalismo aparece em seguida (71,5). Estes são índices heurísticos, não probabilidades de adesão.
5. **Sínteses menos abrangentes.** Livre comércio e não intervenção não geram automaticamente apoio a governança supranacional. Democracia e descentralização não são usadas como prova isolada de rejeição a toda vigilância.
6. **Transparência do PDF.** Foram removidas a afirmação infundada de “alta consistência” e a promessa de criptografia própria. A composição de 100% num vértice é distinguida do apoio absoluto médio. Distribuições bipolares arredondadas somam 100%, e o número de respostas aparece por eixo e tríade. Na interface, “100% cobertura” virou “60/60 itens desta sessão”: completar uma forma curta não cobre todo o banco nem torna o perfil definitivo.

## O que foi preservado e o que não está validado

A mudança do outro agente para tolerâncias 0,42/0,32 e perda `z²/(1+z²/8)` no Atlas foi preservada, com descrição correta: trata-se de uma quadrática limitada, **não perda de Huber**. O aumento de afinidades de países não comprova calibração melhor. Não há estudo empírico que justifique chamar o modelo do Espectro de “superior” ao do 12axes. O relatório explicita que percentuais de catálogos diferentes não são diretamente comparáveis.

O catálogo ainda tem muitas dimensões sem revisão primária específica. Os limiares de elegibilidade e os scores continuam editoriais. Uma classificação mais convincente neste exemplo não encerra o trabalho de validar o banco, as perguntas, as projeções e os índices em casos diversos. O reenquadramento de igualdade feito anteriormente foi preservado, sem alegar que sua validade conceitual foi demonstrada nesta auditoria.

## Comparação com 12axes

O README foi consultado pelo MCP GitHub e o site foi observado via REA: início e comparação Rothbard/Mises/Hoppe. A referência útil é separar eixos e catálogos, comunicar diferenças e preservar o espectro como rótulo de navegação, sem fazê-lo determinar a distância. O README distingue percentil dentro de cada catálogo de score bruto. Não foi afirmado que o concorrente opera integralmente offline, pois a observação não demonstrou isso; o próprio projeto documenta uma API de resultados.

As evidências em `docs/qa/dossier-audit-2026-11-05` guardam identificadores e hashes, sem importar descrições, perguntas, vetores ou fórmulas do concorrente. Não foi necessária uma autorização adicional para ler o repositório público e observar suas telas dentro do escopo solicitado.

## Verificação

Veja `docs/qa/dossier-audit-2026-11-05/validation.json` para o resultado final dos testes, replay, análise estática, inspeção do PDF e builds. Uma passagem de teste não é validação psicométrica. Android físico e validação empírica permanecem não executados.
