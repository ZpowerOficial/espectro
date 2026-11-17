import 'package:flutter/material.dart';

import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/engine/raio_x_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/nolan_diagram_chart.dart';
import '../../charts/study_ternary_chart.dart';
import '../../charts/study_comparative_radar_chart.dart';
import '../../view_models/app_view_model.dart';
import '../atlas/study_identity.dart';
import '../atlas/study_profile_screen.dart';
import '../atlas/study_taxonomy.dart';
import 'raio_x_card.dart';

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
    final subject = StudyCatalog(
      appViewModel.data,
      records: appViewModel.history,
    ).find(comparison.targetId);
    final rawTargetColor = subject != null ? spectrumOf(subject)?.color : null;
    final targetColor = (rawTargetColor != null && rawTargetColor != p.accent)
        ? rawTargetColor
        : const Color(0xFF10B981);

    final userSubject = StudySubject(
      key: 'user',
      name: 'Você',
      kind: 'evaluation',
      kindLabel: 'Seu resultado',
      axes: comparison.userAxes,
      triangles: comparison.userTriads,
    );
    final targetSubject = subject ??
        StudySubject(
          key: comparison.targetId,
          name: comparison.targetName,
          kind: 'target',
          kindLabel: comparison.targetKindLabel,
          axes: comparison.targetAxes,
          triangles: comparison.targetTriads,
          photoUrl: comparison.photoUrl,
        );
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: EspectroElevation.cardShadows(p),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Container(
                      color: p.surface,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subject != null) ...[
                                StudyIdentityAvatar(
                                  subject: subject,
                                  size: 56,
                                  rectangular:
                                      subject.kind == 'personality' ||
                                      subject.kind == 'book',
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Eyebrow(comparison.targetKindLabel),
                                    const SizedBox(height: 6),
                                    Text(
                                      comparison.targetName,
                                      style: text.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comparison.targetSubtitle,
                                      style: text.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (comparison.compatibilityPercent != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.accentSoft,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: p.accent.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    '${comparison.compatibilityPercent!.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexMono',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: p.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (comparison.compatibilityPercent == null)
                            Text(
                              'Sem dimensões em comum',
                              style: text.titleMedium?.copyWith(
                                color: p.muted,
                              ),
                            )
                          else
                            ProgressRail(
                              value: (comparison.compatibilityPercent! / 100.0)
                                  .clamp(0.0, 1.0),
                              color: targetColor,
                            ),
                          const SizedBox(height: 10),
                          Text(
                            '${comparison.axisDeltas.length} eixos e ${comparison.triadDeltas.length} tríades em comum. Ausência de posição não significa neutralidade.',
                            style: text.bodySmall?.copyWith(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(comparison.summary),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 4,
                      child: Row(
                        children: [
                          Expanded(child: ColoredBox(color: p.accent)),
                          Expanded(child: ColoredBox(color: targetColor)),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: p.line),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            RaioXDiagnosticCard(
              diagnostic: RaioXEngine.fromEntityComparison(
                comparison: comparison,
                twelveAxes: appViewModel.data.twelveAxes,
                sixTriangles: appViewModel.data.sixTriangles,
                subject: subject,
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
            if (comparison.axisDeltas.isNotEmpty) ...[
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('VISÃO EM TEIA: 12 EIXOS SOBREPOSTOS'),
                    const SizedBox(height: 8),
                    Text(
                      'Sobreposição radial direta entre seu perfil e ${comparison.targetName}. As áreas destacadas mostram a convergência geométrica.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: StudyComparativeRadarChart(
                        axes: appViewModel.data.twelveAxes.axes,
                        subjects: [userSubject, targetSubject],
                        colors: [p.accent, targetColor],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('CONTRASTE POR EIXO'),
                    const SizedBox(height: 10),
                    const Text(
                      'Sobreposição direta da sua posição e da entidade na mesma régua dual (−100% a +100%). O indicador Δ marca a distância em pontos percentuais.',
                    ),
                    const SizedBox(height: 18),
                    for (final delta in comparison.axisDeltas.entries) ...[
                      Builder(
                        builder: (_) {
                          final axisDef = appViewModel.data.twelveAxes.axes
                              .where((a) => a.id == delta.key)
                              .firstOrNull;
                          if (axisDef == null) return const SizedBox.shrink();
                          final uVal = comparison.userAxes[delta.key];
                          final tVal = comparison.targetAxes[delta.key];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: StudyAxisRow(
                              label: axisDef.label,
                              left: axisDef.leftPole,
                              right: axisDef.rightPole,
                              leftColor: axisDef.leftColor,
                              rightColor: axisDef.rightColor,
                              isOverlaid: true,
                              seriesColors: [p.accent, targetColor],
                              seriesPhotos: [null, targetSubject.photoUrl],
                              values: [
                                ('Você', uVal),
                                (comparison.targetName, tVal),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (comparison.triadDeltas.isNotEmpty) ...[
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('CONTRASTE POR TRÍADE'),
                    const SizedBox(height: 10),
                    const Text(
                      'Sobreposição triangular das composições relativas. Os chips exibem a proporção em cada polo e a diferença Δ correspondente.',
                    ),
                    const SizedBox(height: 16),
                    for (final delta in comparison.triadDeltas.entries) ...[
                      Builder(
                        builder: (_) {
                          final triadCategory = appViewModel.data.sixTriangles.categories
                              .where((t) => t.id == delta.key)
                              .firstOrNull;
                          if (triadCategory == null) return const SizedBox.shrink();
                          final uTriad = comparison.userTriads[delta.key];
                          final tTriad = comparison.targetTriads[delta.key];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  triadCategory.label,
                                  style: text.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  triadCategory.subcategories.join(' / '),
                                  style: TextStyle(color: p.muted, fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                StudyTernaryChart(
                                  vertices: triadCategory.subcategories,
                                  isOverlaid: true,
                                  series: [
                                    StudyTernarySeries('Você', uTriad, p.accent),
                                    StudyTernarySeries(
                                      comparison.targetName,
                                      tTriad,
                                      targetColor,
                                      photoUrl: targetSubject.photoUrl,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
