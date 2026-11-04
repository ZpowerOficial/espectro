# Implementação visual do Figma

Referência: https://www.figma.com/design/0D4CcCfuRr85O69DWwmVDO?node-id=4-49

O arquivo foi inspecionado pelo MCP oficial do Figma (contextos de design e renders).
O nó fornecido é a apresentação da marca; a implementação usa também os frames de interface e o handoff do mesmo arquivo.

| Referência | Implementação |
| --- | --- |
| 4:69, 4:90 | Cores, IBM Plex Sans/Mono, botões, cartões, chips e painéis editoriais |
| 7:4 | Início e atalhos |
| 7:8 | Seleção das três modalidades |
| 7:12 | Profundidade com contagens e durações calculadas pelo app |
| 7:16, 7:20 | Questionário, respostas, ajuda e navegação |
| 7:24, 9:12, 9:16, 9:20 | Resultados, explicações, eixos e tríades com dados reais |
| 9:4, 9:8, 9:24, 13:2, 13:6 | Atlas, busca, categorias e detalhes |
| 9:28, 9:32 | Histórico e metodologia |
| 14:15, 14:92 | Navegação desktop, relatório em colunas e modo escuro |

As contagens, resultados, afinidades e conteúdos são derivados dos dados locais. As análises completas continuam acessíveis nas abas e, no desktop, em “Análise completa”. Os slots de retratos do handoff não fornecem fotos licenciadas; os verbetes usam iniciais enquanto não há mídia disponível no catálogo.

O círculo de destaque do Atlas foi exportado pelo MCP para `assets/figma/atlas-circle.png` e é carregado localmente em 51 × 51. Não há dependência de URL temporária do Figma em execução.

## Verificação

- PASS: `flutter analyze` (nenhum problema)
- PASS: `flutter test` (83 testes)
- PASS: `flutter build web --release`
- `test/ui/figma_layout_test.dart`: 32 capturas (8 telas, 2 dimensões, 2 temas), jornada início → modalidade → profundidade → questionário, e layout com texto ampliado.
- `test/ui/espectro_widget_test.dart`: temas, perguntas, pulo, gráficos interativos e dimensões indeterminadas.

As capturas em `test/ui/goldens/` são baselines do Flutter revisadas visualmente, não uma comparação automática pixel a pixel com o Figma. As imagens de referência não são usadas como telas ou fundos do aplicativo. Não foi realizado teste físico Android nesta tarefa.
