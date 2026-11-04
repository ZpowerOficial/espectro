import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/study_sources.dart';
import '../../../domain/models/study_link_uri.dart';

import '../../../domain/models/study_models.dart';
import '../../../domain/models/study_relations.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../compare/study_comparison_screen.dart';
import '../results/espectro_result_screen.dart';
import 'atlas_explorer_screen.dart';
import 'study_taxonomy.dart';
import 'study_identity.dart';

String studyProfileRoute(String key) =>
    Uri(path: '/atlas', queryParameters: {'v': '1', 'subject': key}).toString();
String publicStudyLink(String route) => buildPublicStudyLink(route);

Future<void> copyStudyLink(BuildContext context, String route) async {
  final link = publicStudyLink(route);
  await Clipboard.setData(ClipboardData(text: link));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          link.startsWith('http') ? 'Link copiado.' : 'Caminho copiado. Para obter um link completo, use a versão web.',
        ),
      ),
    );
  }
}

class StudyProfileScreen extends StatefulWidget {
  const StudyProfileScreen({
    required this.appViewModel,
    required this.subjectKey,
    super.key,
  });
  final AppViewModel appViewModel;
  final String subjectKey;
  @override
  State<StudyProfileScreen> createState() => _StudyProfileScreenState();
}

class _StudyProfileScreenState extends State<StudyProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.appViewModel.visitStudySubject(widget.subjectKey);
    });
  }

  void _open(StudySubject s) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: studyProfileRoute(s.key)),
      builder: (_) => StudyProfileScreen(
        appViewModel: widget.appViewModel,
        subjectKey: s.key,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.appViewModel,
    builder: (context, _) {
      final vm = widget.appViewModel, p = context.palette;
      final catalog = StudyCatalog(vm.data, records: vm.history);
      final s = catalog.find(widget.subjectKey);
      if (s == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Verbete indisponível')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Este perfil não está no catálogo instalado. Avaliações pessoais só podem ser reabertas no dispositivo onde foram salvas.',
              ),
            ),
          ),
        );
      }
      final nearest = catalog.related(s, limit: catalog.subjects.length);
      final documented = relationsForStudy(s.key)
          .where((r) => catalog.find(r.targetKey) != null)
          .toList();
      final traditions = documented
          .where((r) => r.kind == StudyRelationKind.tradition)
          .take(2)
          .toList();
      final spectrum = spectrumOf(s);
      final portrait = vm.data.portraits[s.key];
      final identityAccent = spectrum?.color ?? p.accent;
      final identityInk = spectrum?.ink(p.isDark) ?? p.accent;
      final evidence = evidenceForStudy(s.key);
      final basis = s.current?.editorialBasis ?? s.entry?.editorialBasis;
      final authoredBooks = s.kind == 'personality'
          ? catalog.subjects
                .where(
                  (b) =>
                      b.kind == 'book' &&
                      StudyCatalog.normalize(b.subtitle) ==
                          StudyCatalog.normalize(s.name),
                )
                .toList()
          : <StudySubject>[];
      final author = s.kind == 'book'
          ? catalog.subjects
                .where(
                  (b) =>
                      b.kind == 'personality' &&
                      StudyCatalog.normalize(b.name) ==
                          StudyCatalog.normalize(s.subtitle),
                )
                .toList()
          : <StudySubject>[];
      return DefaultTabController(
        length: 4,
        child: EspectroScaffold(
          appViewModel: vm,
          selectedIndex: 2,
          appBar: AppBar(
            title: Row(
              children: [
                SpectrumBar(color: identityAccent, height: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(s.kindLabel)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: vm.studyFavorites.contains(s.key)
                    ? 'Remover dos salvos'
                    : 'Salvar verbete',
                onPressed: () => vm.toggleStudyFavorite(s.key),
                icon: Icon(
                  vm.studyFavorites.contains(s.key)
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                ),
              ),
              if (s.record == null)
                IconButton(
                  tooltip: 'Copiar link do verbete',
                  onPressed: () =>
                      copyStudyLink(context, studyProfileRoute(s.key)),
                  icon: const Icon(Icons.link),
                ),
              const SizedBox(width: 6),
            ],
            bottom: TabBar(
              labelColor: identityInk,
              indicatorColor: identityAccent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Visão geral'),
                Tab(text: 'Dimensões'),
                Tab(text: 'Conexões'),
                Tab(text: 'Fontes e limites'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _page([
                StudyIdentityHero(subject: s, portrait: portrait),
                if (portrait != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Retrato: ${portrait.author} · ${portrait.licenseName}',
                      style: TextStyle(color: p.inkSoft, fontSize: 11),
                    ),
                  ),
                const SizedBox(height: 18),
                if (s.entry case final entry?) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(entry.era)),
                      Chip(label: Text(entry.origin)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  s.summary,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: identityAccent,
                        foregroundColor:
                            ThemeData.estimateBrightnessForColor(
                                  identityAccent,
                                ) ==
                                Brightness.dark
                            ? Colors.white
                            : const Color(0xFF151A20),
                      ),
                      onPressed: () async {
                        if (!vm.studyComparison.contains(s.key)) {
                          if (vm.studyComparison.length >= 3) {
                            final replace = await showDialog<String>(
                              context: context,
                              builder: (dialogContext) => SimpleDialog(
                                title: const Text('Substituir um perfil'),
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'A comparação comporta até três perfis. Escolha qual substituir.',
                                    ),
                                  ),
                                  for (final key in vm.studyComparison)
                                    SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(key),
                                      child: Text(
                                        catalog.find(key)?.name ?? key,
                                      ),
                                    ),
                                ],
                              ),
                            );
                            if (replace == null || !context.mounted) return;
                            await vm.toggleStudyComparison(replace);
                          }
                          await vm.toggleStudyComparison(s.key);
                        }
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  StudyComparisonScreen(appViewModel: vm),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Comparar perfil'),
                    ),
                    if (s.record case final record?)
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EspectroResultScreen(
                              appViewModel: vm,
                              record: record,
                            ),
                          ),
                        ),
                        child: const Text('Abrir relatório completo'),
                      ),
                    if (spectrum != null)
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AtlasExplorerScreen(
                              appViewModel: vm,
                              initialSpectrum: spectrum.name,
                            ),
                          ),
                        ),
                        child: Text(spectrum.name),
                      ),
                  ],
                ),
                if (s.current != null && s.ideas.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  SectionCard(
                    color: Color.alphaBlend(
                      identityAccent.withValues(alpha: .10),
                      p.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('COMO UM ADEPTO PODERIA RESUMIR'),
                        const SizedBox(height: 12),
                        Text(
                          '“Queremos uma sociedade orientada por ${s.ideas.first.replaceFirst(RegExp(r'[.!]$'), '').toLowerCase()}.”',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Paráfrase editorial baseada no primeiro princípio do catálogo. Não é citação histórica nem representa todas as variantes.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (traditions.isNotEmpty) ...[
                  _heading(context, 'Tradições de referência'),
                  for (final relation in traditions)
                    _relationCard(context, relation, catalog, vm),
                  const SizedBox(height: 20),
                ],
                _heading(
                  context,
                  s.kind == 'current'
                      ? 'Princípios e propostas'
                      : 'Pontos para investigar',
                ),
                for (final idea in s.ideas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.add, size: 18, color: identityInk),
                        const SizedBox(width: 10),
                        Expanded(child: Text(idea)),
                      ],
                    ),
                  ),
                if (s.entry?.quote case final quote?) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('SÍNTESE DO CATÁLOGO'),
                        const SizedBox(height: 10),
                        Text(quote),
                        const SizedBox(height: 10),
                        const Text(
                          'Texto editorial sem referência de página. Não deve ser reproduzido como citação literal da personalidade.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                _heading(context, 'Uma pergunta para continuar'),
                Text(
                  s.current != null
                      ? 'Que tensões aparecem ao aplicar estes princípios a sociedades diferentes? Explore as notas de cada dimensão e contraste correntes vizinhas.'
                      : 'O recorte temporal e a seleção de obras alteram esta leitura? Compare dimensões e verifique os limites da catalogação.',
                ),
                const SizedBox(height: 26),
                _heading(
                  context,
                  traditions.isNotEmpty
                      ? 'Continue pela tradição documentada'
                      : 'Próxima conexão no modelo',
                ),
                if (traditions.isNotEmpty)
                  StudySubjectTile(
                    subject: catalog.find(traditions.first.targetKey)!,
                    portrait: vm.data.portraits[traditions.first.targetKey],
                    onTap: () =>
                        _open(catalog.find(traditions.first.targetKey)!),
                  ),
                if (traditions.isEmpty && nearest.isNotEmpty)
                  StudySubjectTile(
                    subject: nearest.first.subject,
                    portrait: vm.data.portraits[nearest.first.subject.key],
                    onTap: () => _open(nearest.first.subject),
                  ),
                Text(
                  traditions.isNotEmpty
                      ? 'Relação intelectual documentada. Consulte a fonte em Conexões.'
                      : 'Sugestão por proximidade dimensional; não significa filiação ou influência.',
                ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'POSIÇÕES DO PERFIL',
                  title: 'Doze eixos.\nMais de uma leitura.',
                  description: '−1 e +1 são os polos da escala. O centro não significa ausência de dados.',
                ),
                const SizedBox(height: 24),
                for (final axis in vm.data.twelveAxes.axes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: StudyAxisRow(
                        label: axis.label,
                        left: axis.leftPole,
                        right: axis.rightPole,
                        leftColor: axis.leftColor,
                        rightColor: axis.rightColor,
                        values: [(s.name, s.axes[axis.id])],
                        note:
                            s.current?.axes[axis.id]?.note ??
                            s.entry?.coordinateNotes[axis.id],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                _heading(context, 'Seis tríades de valores'),
                const Text(
                  'Composição relativa de três valores. Somar 100% não implica apoio absoluto; no relatório pessoal a intensidade e a incerteza são apresentadas separadamente.',
                ),
                const SizedBox(height: 16),
                for (final triad in vm.data.sixTriangles.categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            triad.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (s.triangles[triad.id] case final values?) ...[
                            for (var i = 0; i < 3; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(triad.subcategories[i]),
                                        ),
                                        Text('${(values[i] * 100).round()}%'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: values[i],
                                      color: triad.color,
                                      backgroundColor: p.surfaceMuted,
                                    ),
                                  ],
                                ),
                              ),
                          ] else
                            const Text('Sem posição disponível nesta tríade.'),
                          if (s.current?.triangles[triad.id]?.note
                              case final note?)
                            Text(
                              note,
                              style: TextStyle(color: p.inkSoft, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'CONEXÕES EXPLICÁVEIS',
                  title: 'Uma ideia leva\na outra.',
                  description: 'Autoria catalogada e semelhança numérica são relações diferentes.',
                ),
                const SizedBox(height: 24),
                _heading(context, 'Relações documentadas'),
                if (documented.isEmpty)
                  const Text(
                    'Ainda não há uma relação intelectual documentada para este verbete. A ausência dessa curadoria não significa ausência de vínculos históricos.',
                  ),
                for (final relation in documented)
                  _relationCard(context, relation, catalog, vm),
                const SizedBox(height: 22),
                _heading(context, 'Proximidade exploratória do modelo'),
                const Text(
                  'Os índices abaixo descrevem apenas as posições editoriais nas dimensões compartilhadas. Não identificam a escola de uma personalidade nem comprovam filiação, influência ou identidade histórica.',
                ),
                const SizedBox(height: 20),
                if (authoredBooks.isNotEmpty || author.isNotEmpty) ...[
                  _heading(context, 'Autoria registrada no catálogo'),
                  for (final item in [...author, ...authoredBooks])
                    StudySubjectTile(
                      subject: item,
                      portrait: vm.data.portraits[item.key],
                      onTap: () => _open(item),
                    ),
                  const SizedBox(height: 22),
                ],
                for (final kind in [
                  'current',
                  'personality',
                  'country',
                  'party',
                  'history',
                  'book',
                ]) ...[
                  if (nearest.any((m) => m.subject.kind == kind))
                    _heading(context, switch (kind) {
                      'current' => 'Correntes próximas',
                      'personality' => 'Personalidades próximas',
                      'country' => 'Recortes de países próximos',
                      'party' => 'Partidos e movimentos próximos',
                      'history' => 'Recortes históricos próximos',
                      _ => 'Biblioteca por proximidade',
                    }),
                  for (final match
                      in nearest
                          .where((m) => m.subject.kind == kind)
                          .take(3)) ...[
                    StudySubjectTile(
                      subject: match.subject,
                      portrait: vm.data.portraits[match.subject.key],
                      onTap: () => _open(match.subject),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 19, bottom: 14),
                      child: Text(
                        'Índice ${match.similarity.round()}/100 · ${match.sharedAxes} eixos e ${match.sharedTriads} tríades em comum',
                        style: TextStyle(color: p.inkSoft, fontSize: 12),
                      ),
                    ),
                  ],
                ],
                _heading(context, 'Contrastes para estudar'),
                for (final match
                    in nearest.reversed
                        .where((m) => m.subject.kind == 'current')
                        .take(3))
                  StudySubjectTile(
                    subject: match.subject,
                    portrait: vm.data.portraits[match.subject.key],
                    onTap: () => _open(match.subject),
                  ),
                const SizedBox(height: 18),
                Text(
                  StudyCatalog.methodDescription,
                  style: TextStyle(color: p.inkSoft, fontSize: 12),
                ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'PROVENIÊNCIA E INCERTEZA',
                  title: 'O que sabemos.\nO que falta verificar.',
                ),
                const SizedBox(height: 24),
                if (basis != null) ...[
                  _heading(context, 'Recorte e revisão editorial'),
                  Text(
                    basis.scope,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Revisado em ${basis.reviewedAt} · ${basis.empiricallyValidated ? 'Validação informada pelo catálogo' : 'Interpretação provisória, sem validação empírica'}',
                    style: TextStyle(color: p.inkSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(basis.coordinateMethod),
                  for (final limitation in basis.limitations)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('• $limitation'),
                    ),
                  const SizedBox(height: 24),
                ],
                _heading(context, 'Origem desta ficha'),
                SelectableText(
                  'Catálogo offline do Espectro · versão ${vm.data.catalog.catalogVersion}\nChave: ${s.key}\nArquivo: ${s.current != null ? 'ideological_currents.json' : switch (s.kind) {
                          'personality' => 'personalities.json',
                          'country' => 'countries.json',
                          'party' => 'parties_movements.json',
                          'history' => 'historical_eras.json',
                          'book' => 'books_catalog.json',
                          _ => 'registro pessoal local',
                        }}',
                ),
                const SizedBox(height: 20),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('ESTADO DA EVIDÊNCIA'),
                      const SizedBox(height: 12),
                      Text(
                        s.record != null
                            ? 'Resultado calculado a partir das respostas locais. Veja cobertura, intensidade e intervalos no relatório.'
                            : basis != null
                            ? 'Recorte, fontes contextuais, notas de interpretação e data de revisão estão disponíveis. Os valores numéricos são provisórios e não foram validados empiricamente; as leituras não justificam precisamente cada coordenada.'
                            : 'Síntese e coordenadas editoriais. Esta ficha ainda não registra fontes primárias por afirmação, justificativa bibliográfica por coordenada ou data de revisão.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A posição de uma pessoa, partido ou país é um recorte interpretativo, não uma essência imutável nem uma medição empírica da população.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _heading(context, 'Limites que afetam a leitura'),
                const Text(
                  '• Proximidade calculada não comprova influência histórica.\n• Composições de tríades não medem intensidade absoluta.\n• A projeção em duas dimensões perde informação.\n• Famílias e espectros são ferramentas editoriais de navegação.\n• Fotografias e reproduções são identificadas pelo acervo e pela licença original.',
                ),
                const SizedBox(height: 24),
                _heading(context, 'Leituras primárias documentadas'),
                if (evidence.sources.isEmpty)
                  const Text(
                    'Ainda não há uma leitura primária vinculada documentalmente a esta ficha. As sugestões em Conexões são calculadas e têm outra função.',
                  ),
                for (final source in evidence.sources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(source.relation),
                          const SizedBox(height: 10),
                          Text(
                            source.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(source.period),
                          const SizedBox(height: 8),
                          Text(source.note),
                          const SizedBox(height: 10),
                          SelectableText(
                            source.url,
                            style: TextStyle(color: p.accent, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Referência conferida em ${source.verifiedOn}',
                            style: TextStyle(color: p.inkSoft, fontSize: 11),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                final opened = await launchUrl(
                                  Uri.parse(source.url),
                                );
                                if (!opened && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Abrir fonte original'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(evidence.coordinateNote),
                const SizedBox(height: 24),
                _heading(context, 'Imagem e créditos'),
                if (portrait == null)
                  const Text(
                    'Este perfil ainda não possui um retrato verificado no acervo. O símbolo exibido identifica sua tradição editorial.',
                  ),
                if (portrait != null)
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retrato de ${s.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Autoria: ${portrait.author}'),
                        Text('Licença: ${portrait.licenseName}'),
                        const SizedBox(height: 8),
                        Text(
                          portrait.changes,
                          style: TextStyle(color: p.inkSoft, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          portrait.sourceUrl,
                          style: TextStyle(color: identityInk, fontSize: 12),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _launchSource(context, portrait.sourceUrl),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Acervo e autoria'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _launchSource(context, portrait.licenseUrl),
                              icon: const Icon(
                                Icons.description_outlined,
                                size: 16,
                              ),
                              label: const Text('Termos da licença'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _heading(context, 'Como aprofundar'),
                const Text(
                  'Use a biblioteca para localizar obras e seus autores. Confronte a síntese com o texto original, uma edição identificada e o contexto histórico. As leituras sugeridas por proximidade não substituem referências documentais.',
                ),
                const SizedBox(height: 20),
                _heading(context, 'Método da comparação exploratória'),
                Text(StudyCatalog.methodDescription),
                const SizedBox(height: 20),
                _heading(context, 'Critérios para uma revisão documental'),
                const Text(
                  'Registrar edição, capítulo ou página, período analisado, justificativa da posição e divergências interpretativas. Cada relação histórica precisa de uma fonte própria; cada imagem, autoria e licença.',
                ),
              ]),
            ],
          ),
        ),
      );
    },
  );
  Widget _relationCard(
    BuildContext context,
    StudyRelation relation,
    StudyCatalog catalog,
    AppViewModel vm,
  ) {
    final target = catalog.find(relation.targetKey)!;
    final ink =
        spectrumOf(target)?.ink(context.palette.isDark) ??
        context.palette.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              relation.kind.label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            StudySubjectTile(
              subject: target,
              portrait: vm.data.portraits[target.key],
              onTap: () => _open(target),
            ),
            Text(
              relation.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(relation.note),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _launchSource(context, relation.sourceUrl),
              icon: const Icon(Icons.open_in_new, size: 15),
              label: const Text('Consultar fonte desta relação'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchSource(BuildContext context, String url) async {
    try {
      if (await launchUrl(Uri.parse(url))) return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir. Copie o endereço da fonte.'),
        ),
      );
    }
  }

  Widget _page(List<Widget> children) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 36),
        children: children,
      ),
    ),
  );
  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

/// Escala compartilhada no perfil e na comparação; ausências são explícitas.
class StudyAxisRow extends StatelessWidget {
  const StudyAxisRow({
    required this.label,
    required this.left,
    required this.right,
    required this.leftColor,
    required this.rightColor,
    required this.values,
    this.note,
    super.key,
  });
  final String label, left, right;
  final Color leftColor, rightColor;
  final List<(String, double?)> values;
  final String? note;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: leftColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Entender $label',
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () => showInfoSheet(
                context,
                title: label,
                child: Text(
                  '$left (−1) ↔ $right (+1). O ponto indica uma posição na escala. Dimensões ausentes não são substituídas pelo centro.\n\n${note ?? 'Posição editorial do catálogo. Consulte Fontes e limites para avaliar a evidência disponível.'}',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                left,
                style: TextStyle(color: p.inkSoft, fontSize: 11),
              ),
            ),
            Expanded(
              child: Text(
                right,
                textAlign: TextAlign.right,
                style: TextStyle(color: p.inkSoft, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.$1,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      value.$2 == null
                          ? 'Sem evidência'
                          : value.$2!.toStringAsFixed(2),
                      style: TextStyle(color: p.inkSoft, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                if (value.$2 != null)
                  Semantics(
                    label:
                        '${value.$1}: ${value.$2!.toStringAsFixed(2)} entre $left e $right',
                    child: SizedBox(
                      height: 18,
                      child: LayoutBuilder(
                        builder: (context, c) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 6,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      leftColor.withValues(alpha: .25),
                                      rightColor.withValues(alpha: .25),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: c.maxWidth / 2,
                              top: 2,
                              height: 14,
                              child: Container(width: 1, color: p.inkSoft),
                            ),
                            Positioned(
                              left:
                                  ((value.$2!.clamp(-1, 1) + 1) / 2) *
                                  (c.maxWidth - 12),
                              top: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: value.$2! < 0 ? leftColor : rightColor,
                                  border: Border.all(
                                    color: p.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (note != null)
          Text(note!, style: TextStyle(color: p.inkSoft, fontSize: 12)),
      ],
    );
  }
}
