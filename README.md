# politico

Aplicativo Flutter do Espectro Político: questionários de 12 Eixos e Six
Triangles, leitura de resultados e um Atlas offline de correntes,
personalidades, partidos, regimes históricos, países e obras.

## Catálogo e documentação

Os dados ficam em `assets/data/` e são carregados integralmente offline. Cada
verbete declara `editorialBasis` com escopo, data de revisão, limitações,
fontes e o estado de evidência de cada dimensão:

- `primary_supported`: leitura de trecho primário;
- `editorial_reconstruction`: respostas atribuídas ao banco do Espectro, com
  item, justificativa e ressalvas;
- `institutional_vote`: posição derivada de votação nominal oficial;
- `editorial_synthesis`: leitura temática da doutrina ancorada em fonte já
  registrada, sem alegar citação literal página a página;
- `insufficient` / `unreviewed`: ausência documentada, nunca preenchimento
  artificial com centro.

As relações entre correntes, personalidades e obras são curadas em
`assets/data/study_relations_extended.json` e no bloco Dart de relações
históricas. Elas não são inferidas por proximidade numérica; quando não há
documento ou entidade correspondente, a ausência permanece explícita.

Documentos de referência:

- [Protocolo de completude do catálogo](docs/protocolo-completude-catalogo.md)
- [Enriquecimento documental de 13/11/2026](docs/enriquecimento-documental-2026-11-13.md)
- [Auditoria de cobertura primária](docs/primary-coverage-audit-2026-11-05.json)

### Rodada documental reproduzível

```bash
python3 tool/curation/enrich_currents_documentation.py
python3 tool/curation/enrich_study_relations.py
```

Os scripts são idempotentes e não criam fontes novas: reutilizam as notas
doutrinárias, os metadados e as URLs já registrados no acervo.

## Plataformas e modo offline

O app é offline-first em todas as plataformas: catálogo, questão, resultados,
favoritos e histórico são lidos de assets ou do armazenamento local. Não há
dependência de rede para navegar, responder ou comparar perfis.

Alvos configurados:

- **Web/PWA:** `flutter build web --release`
- **Android:** `flutter build apk --release`
- **Linux:** `flutter build linux --release`
- **Windows:** `flutter build windows --release` (compilar em Windows)

O script `tool/build_portable.sh` automatiza os alvos disponíveis:

```bash
./tool/build_portable.sh web
./tool/build_portable.sh android
./tool/build_portable.sh all
```

No primeiro acesso web, o worker próprio `web/espectro_sw.js` pré-cacheia o
shell, as fontes, o CanvasKit e os dados do app para abrir offline nas visitas
seguintes. O worker gerado pelo Flutter 3.47 é intencionalmente ignorado: nesta
versão ele se desregistra sozinho. Não desregistre o worker do Espectro nem
apague os caches em produção.

Para publicar a web, sirva `build/web` por HTTPS. O `manifest.json` permite
instalação como PWA em desktop e Android; `start_url`, `scope` e os ícones já
estão configurados.

## Catálogo externo licenciado

O 12axes é publicado com licença **“All rights reserved”**. O Espectro não
copia nem redistribui os perfis, vetores, textos ou o algoritmo desse projeto.

Para ampliar a cobertura com dados que você tenha direito de usar, existe um
slot separado em `assets/data/external_catalog.json` e um importador
com confirmação explícita de direitos:

```bash
python3 tool/curation/import_external_catalog.py \
  --source-dir /caminho/do/export \
  --source-url https://exemplo.org/licenca \
  --confirm-rights
```

As fichas importadas não sobrescrevem o acervo editorial, não recebem tríades
inventadas e ficam fora do diagnóstico nativo até revisão. Veja
[o formato e as garantias](docs/importacao-catalogo-externo.md).

## Leitura complementar em 12 eixos

O motor principal do Atlas continua usando as 18 dimensões (12 eixos + 6
tríades), com `sigma`, erro-padrão e relevância. Ao lado dele, o app calcula uma
afinidade restrita aos 12 eixos, decomposta em similaridade de eixos, direção,
magnitude e maior outlier. A cobertura (`n/12`) é exibida junto da nota: uma
afinidade calculada com 6 eixos não é apresentada como equivalente a uma com os
12. Essa leitura é complementar e não substitui o ranking principal.

## Desenvolvimento

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
