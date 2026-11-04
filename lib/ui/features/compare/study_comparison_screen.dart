import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../atlas/study_profile_screen.dart';

/// Comparação livre de posições do catálogo e, por escolha, registros locais.
class StudyComparisonScreen extends StatefulWidget {
  const StudyComparisonScreen({
    required this.appViewModel,
    this.initialKeys,
    super.key,
  });
  final AppViewModel appViewModel;
  final List<String>? initialKeys;
  @override
  State<StudyComparisonScreen> createState() => _StudyComparisonScreenState();
}

class _StudyComparisonScreenState extends State<StudyComparisonScreen> {
  final _query = TextEditingController();
  List<String>? _linkedKeys;
  @override
  void initState() {
    super.initState();
    _linkedKeys = widget.initialKeys?.take(3).toList();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<String> get _keys => _linkedKeys ?? widget.appViewModel.studyComparison;
  void _toggle(String key) {
    if (_linkedKeys != null) {
      setState(() {
        if (_linkedKeys!.contains(key)) {
          _linkedKeys!.remove(key);
        } else if (_linkedKeys!.length < 3) {
          _linkedKeys!.add(key);
        }
      });
    } else {
      widget.appViewModel.toggleStudyComparison(key);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.appViewModel,
    builder: (context, _) {
      final vm = widget.appViewModel, p = context.palette;
      final catalog = StudyCatalog(vm.data, records: vm.history);
      final selected = [for (final key in _keys) ?catalog.find(key)];
      final missing = _keys.where((key) => catalog.find(key) == null).toList();
      final results = catalog
          .search(_query.text)
          .where((s) => !selected.any((v) => s.key == v.key))
          .take(18)
          .toList();
      return EspectroScaffold(
        appViewModel: vm,
        selectedIndex: 4,
        isSectionRoot: true,
        appBar: AppBar(
          title: const Text('Comparação livre'),
          actions: [
            if (selected.length >= 2 && selected.every((s) => s.record == null))
              IconButton(
                tooltip: 'Copiar link da comparação',
                icon: const Icon(Icons.link),
                onPressed: () => copyStudyLink(
                  context,
                  Uri(
                    path: '/compare',
                    queryParameters: {
                      'v': '1',
                      'items': selected.map((s) => s.key).join(','),
                    },
                  ).toString(),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const EditorialHeading(
                    eyebrow: 'LADO A LADO',
                    title: 'Compare ideias.\nEncontre as diferenças.',
                    description: 'Escolha de dois a três perfis. Correntes, pessoas, países, obras e suas avaliações podem ocupar a mesma escala.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in selected)
                        InputChip(
                          label: Text(s.name),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudyProfileScreen(
                                appViewModel: vm,
                                subjectKey: s.key,
                              ),
                            ),
                          ),
                          onDeleted: () => _toggle(s.key),
                        ),
                      for (final key in missing)
                        InputChip(
                          label: Text('Indisponível: $key'),
                          onDeleted: () => _toggle(key),
                        ),
                    ],
                  ),
                  if (missing.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Alguns perfis deste link não estão no catálogo instalado. Registros pessoais exigem o dispositivo original.',
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_keys.length < 3) ...[
                    TextField(
                      controller: _query,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Adicionar um perfil',
                        hintText: 'Busque qualquer nome ou ideia',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: selected.isEmpty ? 270 : 180,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: p.line),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, i) => ListTile(
                            dense: true,
                            title: Text(results[i].name),
                            subtitle: Text(results[i].kindLabel),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              _toggle(results[i].key);
                              _query.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                    if (results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Nenhum perfil encontrado. Experimente outro termo.',
                        ),
                      ),
                  ] else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          if (_linkedKeys != null) {
                            setState(() => _linkedKeys = []);
                          } else {
                            vm.clearStudyComparison();
                          }
                        },
                        child: const Text('Limpar seleção'),
                      ),
                    ),
                  if (selected.length < 2)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'Adicione ao menos dois perfis para revelar convergências e contrastes. Nenhum teste é necessário.',
                      ),
                    ),
                  if (selected.length >= 2) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Proximidade por par',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < selected.length; i++)
                      for (var j = i + 1; j < selected.length; j++)
                        _pair(context, catalog, selected[i], selected[j]),
                    const SizedBox(height: 24),
                    Text(
                      'Mesmos eixos, mesma régua',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A ausência de evidência não vira uma posição neutra. Posições de catálogo são editoriais; avaliações pessoais vêm das respostas.',
                    ),
                    const SizedBox(height: 18),
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
                            values: [
                              for (final s in selected)
                                (s.name, s.axes[axis.id]),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    Text(
                      'Tríades: composições relativas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
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
                              const SizedBox(height: 8),
                              Text(
                                triad.subcategories.join(' / '),
                                style: TextStyle(color: p.muted, fontSize: 12),
                              ),
                              const SizedBox(height: 14),
                              for (final s in selected)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        s.triangles[triad.id]
                                                ?.map(
                                                  (v) =>
                                                      '${(v * 100).round()}%',
                                                )
                                                .join(' / ') ??
                                            'Sem evidência nesta tríade',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('COMO LER A COMPARAÇÃO'),
                          const SizedBox(height: 12),
                          Text(StudyCatalog.methodDescription),
                          const SizedBox(height: 12),
                          const Text(
                            'Este índice de estudo não substitui as afinidades, a cobertura e os intervalos do relatório pessoal.',
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (vm.studyStorageError != null)
                    Text(
                      vm.studyStorageError!,
                      style: TextStyle(color: p.warning),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget _pair(
    BuildContext context,
    StudyCatalog catalog,
    StudySubject a,
    StudySubject b,
  ) {
    final match = catalog.compare(a, b);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${a.name} × ${b.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (match == null)
              const Text(
                'Não há dimensões em comum suficientes para calcular proximidade.',
              )
            else ...[
              Text(
                '${match.similarity.round()}%',
                style: Theme.of(context).textTheme.displayMedium
                    ?.copyWith(color: context.palette.accent),
              ),
              Text(
                '${match.sharedAxes} eixos · ${match.sharedTriads} tríades · ${(match.coverage * 100).round()}% de sobreposição disponível',
              ),
              const SizedBox(height: 12),
              if (match.similarities.isNotEmpty) ...[
                const Text(
                  'Convergências',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final text in match.similarities) Text(text),
              ],
              const SizedBox(height: 8),
              if (match.differences.isNotEmpty) ...[
                const Text(
                  'Contrastes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final text in match.differences) Text(text),
              ] else
                const Text(
                  'Nenhuma divergência acima do limiar exploratório de 25% da distância máxima.',
                ),
            ],
          ],
        ),
      ),
    );
  }
}
