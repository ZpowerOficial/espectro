import 'package:flutter/material.dart';

import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/nolan_diagram_chart.dart';
import '../../view_models/app_view_model.dart';

/// Tela dedicada para comparar em profundidade a avaliação do usuário com
/// qualquer entidade do sistema: País / Modelo Estatal, Personalidade Histórica,
/// Corrente Ideológica ou Partido/Movimento.
class EntityComparisonScreen extends StatelessWidget {
  const EntityComparisonScreen({
    required this.comparison,
    required this.appViewModel,
    super.key,
  });

  final EntityComparisonResult comparison;
  final AppViewModel appViewModel;

  static void showAtlasEntry(
    BuildContext context, {
    required EvaluationRecord record,
    required AtlasEntry entry,
    required AppViewModel appViewModel,
  }) {
    final EntityComparisonResult res =
        EspectroAtlasEngine.compareWithAtlasEntry(
          entry: entry,
          userAxes: record.axes,
          userTriads: record.triads,
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EntityComparisonScreen(comparison: res, appViewModel: appViewModel),
      ),
    );
  }

  static void showCurrent(
    BuildContext context, {
    required EvaluationRecord record,
    required IdeologicalCurrent current,
    required AppViewModel appViewModel,
  }) {
    final EntityComparisonResult res = EspectroAtlasEngine.compareWithCurrent(
      current: current,
      userAxes: record.axes,
      userTriads: record.triads,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EntityComparisonScreen(comparison: res, appViewModel: appViewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final user = comparison.nolanUser;
    final target = comparison.nolanTarget;
    final canProject = user != null && target != null;
    String axisLabel(String id) =>
        appViewModel.data.twelveAxes.axes
            .where((a) => a.id == id)
            .firstOrNull
            ?.label ??
        id;
    String triadLabel(int id) =>
        appViewModel.data.sixTriangles.categories
            .where((t) => t.id == id)
            .firstOrNull
            ?.label ??
        'Tríade $id';
    return EspectroScaffold(
      appViewModel: appViewModel,
      selectedIndex: 2,
      appBar: AppBar(title: Text('Você e ${comparison.targetName}')),
      body: ResponsiveContentFrame(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const EditorialHeading(
              eyebrow: 'PERFIL / COMPARAÇÃO',
              title: 'Onde vocês\nconvergem?',
              description:
                  'A comparação usa somente dimensões observadas em comum.',
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(comparison.targetKindLabel),
                  const SizedBox(height: 10),
                  Text(comparison.targetName, style: text.headlineMedium),
                  const SizedBox(height: 8),
                  Text(comparison.targetSubtitle, style: text.bodySmall),
                  const SizedBox(height: 16),
                  Text(
                    comparison.compatibilityPercent == null
                        ? 'Sem dimensões em comum'
                        : '${comparison.compatibilityPercent!.round()}%',
                    style: text.headlineLarge?.copyWith(color: p.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${comparison.axisDeltas.length} eixos e ${comparison.triadDeltas.length} tríades em comum. Ausência de posição não significa neutralidade.',
                  ),
                  const SizedBox(height: 14),
                  Text(comparison.summary),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('PROJEÇÃO DE NOLAN'),
                  const SizedBox(height: 12),
                  if (canProject) ...[
                    SizedBox(
                      height: 280,
                      child: NolanDiagramChart(
                        coordinates: user,
                        referencePins: [
                          NolanReferencePin(
                            id: comparison.targetId,
                            label: comparison.targetName,
                            category: comparison.targetKindLabel,
                            economicFreedom: target.economicFreedom,
                            personalFreedom: target.personalFreedom,
                            quadrantLabel: target.quadrantLabel,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Você: economia ${user.economicFreedom.round()} · liberdade civil ${user.personalFreedom.round()}',
                    ),
                    Text(
                      '${comparison.targetName}: economia ${target.economicFreedom.round()} · liberdade civil ${target.personalFreedom.round()}',
                    ),
                  ] else
                    const Text(
                      'Sem projeção bidimensional: falta uma base econômica ou civil suficiente em pelo menos um perfil. Nenhum ponto central foi inventado.',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (comparison.axisDeltas.isNotEmpty)
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('CONTRASTE POR EIXO'),
                    const SizedBox(height: 10),
                    const Text(
                      'Diferença assinada entre sua posição e a do perfil (−2 a +2). O sinal se refere aos polos próprios de cada eixo, não a uma identidade geral de esquerda ou direita.',
                    ),
                    const SizedBox(height: 16),
                    for (final delta in comparison.axisDeltas.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(axisLabel(delta.key), style: text.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Diferença: ${delta.value > 0 ? '+' : ''}${delta.value.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (comparison.triadDeltas.isNotEmpty) ...[
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('CONTRASTE POR TRÍADE'),
                    const SizedBox(height: 10),
                    const Text(
                      'Distância entre composições, incluindo a intensidade absoluta das respostas. Zero indica coincidência na dimensão observada.',
                    ),
                    const SizedBox(height: 16),
                    for (final delta in comparison.triadDeltas.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              triadLabel(delta.key),
                              style: text.titleMedium,
                            ),
                            Text(
                              'Distância: ${delta.value.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'O índice de afinidade é uma estimativa do modelo editorial. Ele não estabelece identidade política, filiação histórica ou probabilidade de concordância.',
            ),
          ],
        ),
      ),
    );
  }
}
