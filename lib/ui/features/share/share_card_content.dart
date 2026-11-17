import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/engine/compatibility_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../atlas/study_taxonomy.dart';

Size shareCardLogicalSize({required bool story}) =>
    Size(360, story ? 640 : 360);

/// Presentation reads only observed native dimensions. A tension card requires
/// observed coverage in BOTH poles (at least two answers each), in addition to
/// the existing operational tension rule; this is not statistical validation.
class ShareCardEvidence {
  ShareCardEvidence.fromRecord(EvaluationRecord record)
    : axes = record.axes.where((axis) => !axis.isIndeterminate).toList()
        ..sort((a, b) => b.score.abs().compareTo(a.score.abs())),
      triads = record.triads.where((triad) => !triad.isIndeterminate).toList(),
      nolan = EspectroNolanEngine.fromEvaluation(
        axes: record.axes,
        triads: record.triads,
      );

  final List<BipolarDimensionScore> axes;
  final List<TriadDimensionScore> triads;
  final NolanCoordinates? nolan;

  BipolarDimensionScore? get discoveryAxis => axes
      .where(
        (axis) =>
            axis.poleBreakdownAvailable &&
            axis.answeredLeftCount >= 2 &&
            axis.answeredRightCount >= 2 &&
            axis.minimumPoleCoverage >= .5 &&
            axis.hasInternalTension,
      )
      .firstOrNull;
}

/// Fixed export composition, intentionally independent from accessibility scale.
/// The sheet itself scales with the user's preference and explains the content.
class ShareCardCanvas extends StatelessWidget {
  const ShareCardCanvas({
    required this.record,
    required this.data,
    this.story = false,
    this.discovery = false,
    this.entryLink,
    super.key,
  });
  final EvaluationRecord record;
  final AppData data;
  final bool story;
  final bool discovery;
  final String? entryLink;

  @override
  Widget build(BuildContext context) {
    final evidence = ShareCardEvidence.fromRecord(record);
    final tension = discovery ? evidence.discoveryAxis : null;
    final size = shareCardLogicalSize(story: story);
    final primary = EspectroCompatibilityEngine.evaluate(
      catalog: data.catalog,
      axes: record.axes,
      triads: record.triads,
    ).primaryMatch;
    final Color traditionColor = primary != null
        ? (spectrumOf(StudySubject.fromCurrent(primary.current))?.color ??
              const Color(0xFF63A4FF))
        : const Color(0xFF63A4FF);
    final String? spectrumLabel = primary != null
        ? (spectrumOf(StudySubject.fromCurrent(primary.current))?.name ??
              primary.current.family)
        : null;
    final String dimensions =
        '${evidence.axes.length}/${record.axes.length} eixos · '
        '${evidence.triads.length}/${record.triads.length} tríades com base observada';
    final List<BipolarDimensionScore> observed =
        evidence.axes.take(story ? 3 : 1).toList();
    final bool hasChartEvidence = evidence.axes.length >= 3;

    const Color bgObsidian = Color(0xFF0A0E17);
    const Color panelGlass = Color(0xFF141B29);
    const Color inkLight = Color(0xFFF6F8FC);
    const Color inkMuted = Color(0xFFA3B0C6);
    const Color ruleBorder = Color(0xFF253045);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
        key: const ValueKey('share-card-canvas'),
        width: size.width,
        height: size.height,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: bgObsidian),
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        traditionColor.withValues(alpha: 0.24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SpectrumGradientRule(height: 4, radius: 0),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  story ? 20 : 16,
                  story ? 18 : 16,
                  story ? 20 : 16,
                  story ? 14 : 13,
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 12,
                    height: 1.25,
                    color: inkLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: FittedBox(child: EspectroBrandMark()),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'ESPECTRO',
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: inkLight,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: ruleBorder),
                            ),
                            child: Text(
                              story ? '9:16' : '1:1',
                              style: const TextStyle(
                                fontFamily: 'IBMPlexMono',
                                color: inkMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: story ? 12 : 10),
                      Text(
                        tension == null
                            ? 'Meu retrato político'
                            : 'Minha descoberta\nmais surpreendente',
                        style: TextStyle(
                          fontSize: story
                              ? (tension != null ? 21 : 23)
                              : (tension != null ? 19 : 21),
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: inkLight,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dimensions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, color: inkMuted),
                      ),
                      SizedBox(height: story ? 10 : 10),

                      // Bloco central com síntese + visualização geométrica quando observada.
                      if (!story)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHighlightBlock(
                                    tension: tension,
                                    nolan: evidence.nolan,
                                    accent: traditionColor,
                                    panel: panelGlass,
                                    border: ruleBorder,
                                    compact: true,
                                  ),
                                  if (primary != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: panelGlass,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: traditionColor.withValues(
                                            alpha: 0.45,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            spectrumLabel?.toUpperCase() ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: traditionColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            primary.current.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: inkLight,
                                            ),
                                          ),
                                          Text(
                                            'Índice ${primary.compatibilityPercent.round()}/100',
                                            style: const TextStyle(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 9.5,
                                              color: inkMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (hasChartEvidence) ...[
                              const SizedBox(width: 10),
                              Container(
                                width: 118,
                                height: 118,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: panelGlass,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: ruleBorder),
                                ),
                                child: CustomPaint(
                                  painter: _SharePosterRadarPainter(
                                    axes: evidence.axes,
                                    accent: traditionColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else ...[
                        _buildHighlightBlock(
                          tension: tension,
                          nolan: evidence.nolan,
                          accent: traditionColor,
                          panel: panelGlass,
                          border: ruleBorder,
                          compact: false,
                        ),
                        if (primary != null) ...[
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: panelGlass,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: traditionColor.withValues(alpha: 0.48),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CORRENTE DE REFERÊNCIA · ${spectrumLabel?.toUpperCase() ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: traditionColor,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        primary.current.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.5,
                                          color: inkLight,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Índice exploratório ${primary.compatibilityPercent.round()}/100 · ${primary.evaluatedDimensions} dimensões',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasChartEvidence) ...[
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 82,
                                    height: 82,
                                    child: CustomPaint(
                                      painter: _SharePosterRadarPainter(
                                        axes: evidence.axes,
                                        accent: traditionColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (observed.isNotEmpty) ...[
                          const Text(
                            'EIXOS MAIS MARCADOS (BASE OBSERVADA)',
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: inkMuted,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 6),
                          for (final axis in observed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: _ShareAxisMiniBar(
                                axis: axis,
                                accent: traditionColor,
                              ),
                            ),
                        ] else if (evidence.triads.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: panelGlass,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ruleBorder),
                            ),
                            child: Text(
                              '${evidence.triads.first.label}\nApoio absoluto observado: ${(evidence.triads.first.engagement * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: inkLight,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: panelGlass,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ruleBorder),
                            ),
                            child: const Text(
                              'Não há dimensões com cobertura suficiente para descrever tendências.',
                              style: TextStyle(fontSize: 12, color: inkMuted),
                            ),
                          ),
                      ],
                      const Spacer(),
                      Container(height: 1, color: ruleBorder),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DESCUBRA SUA POSIÇÃO',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF63A4FF),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entryLink ?? 'espectro-politico.web.app',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: inkLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: traditionColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: traditionColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Text(
                              '100% ANÔNIMO',
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: inkLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightBlock({
    required BipolarDimensionScore? tension,
    required NolanCoordinates? nolan,
    required Color accent,
    required Color panel,
    required Color border,
    required bool compact,
  }) {
    if (tension != null) {
      return _block(
        panel: panel,
        border: accent.withValues(alpha: 0.45),
        titleColor: accent,
        title: tension.label,
        body:
            'Respostas aos dois polos revelam tensão ou contexto. Não definem uma contradição pessoal.',
        compact: compact,
      );
    }
    if (nolan != null) {
      return _block(
        panel: panel,
        border: border,
        titleColor: const Color(0xFF7FAFFF),
        title: 'Projeção de Nolan',
        body:
            'Econômica ${nolan.economicFreedom.round()}% · Civil ${nolan.personalFreedom.round()}%',
        compact: compact,
      );
    }
    return _block(
      panel: panel,
      border: border,
      titleColor: const Color(0xFFF59E42),
      title: 'Nolan indeterminado',
      body:
          'Ainda falta base econômica ou civil. Nenhum ponto central foi atribuído.',
      compact: compact,
    );
  }

  Widget _block({
    required Color panel,
    required Color border,
    required Color titleColor,
    required String title,
    required String body,
    required bool compact,
  }) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 10 : 12,
      vertical: compact ? 9 : 10,
    ),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 11.5 : 13.5,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          body,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10.5 : 12,
            color: const Color(0xFFE6ECF6),
            height: 1.25,
          ),
        ),
      ],
    ),
  );
}

class _ShareAxisMiniBar extends StatelessWidget {
  const _ShareAxisMiniBar({required this.axis, required this.accent});

  final BipolarDimensionScore axis;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final double norm = ((axis.score + 1.0) / 2.0).clamp(0.04, 0.96);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141B29),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF253045)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  axis.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF6F8FC),
                  ),
                ),
              ),
              Text(
                axis.summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, box) {
              final double w = box.maxWidth;
              final double dotX = (w - 8) * norm;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF253045),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Positioned(
                    left: w * 0.5 - 0.5,
                    child: Container(
                      width: 1,
                      height: 8,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  Positioned(
                    left: dotX,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  axis.leftPole,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Color(0xFFA3B0C6)),
                ),
              ),
              Flexible(
                child: Text(
                  axis.rightPole,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Color(0xFFA3B0C6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SharePosterRadarPainter extends CustomPainter {
  const _SharePosterRadarPainter({required this.axes, required this.accent});

  final List<BipolarDimensionScore> axes;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - 4;
    if (maxR <= 6) return;

    final Paint ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final double f in const [0.35, 0.7, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    final int n = axes.length;
    final Path poly = Path();
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);
      final double norm = ((axes[i].score + 1.0) / 2.0).clamp(0.1, 0.98);
      final Offset pt = center + dir * (maxR * norm);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }
    }
    poly.close();
    canvas.drawPath(poly, Paint()..color = accent.withValues(alpha: 0.30));
    canvas.drawPath(
      poly,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _SharePosterRadarPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.axes != axes;
}
