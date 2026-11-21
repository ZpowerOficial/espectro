import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../data/models.dart' as data show Axis;
import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/engine/compatibility_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_media.dart';
import '../../../domain/models/study_models.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../atlas/current_emblem.dart';
import '../../charts/axis_colors.dart';
import '../../shared/metric_presentation.dart';
import '../../shared/resilient_image.dart';
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
    final ShareCardEvidence evidence = ShareCardEvidence.fromRecord(record);
    final BipolarDimensionScore? tension = discovery
        ? evidence.discoveryAxis
        : null;
    final bool hasAxes = record.axes.any((a) => !a.isIndeterminate);
    final bool hasTriads = record.triads.any((t) => !t.isIndeterminate);
    final String scopeBadge = (hasAxes && hasTriads)
        ? '12 eixos · 6 tríades'
        : (hasAxes
              ? '12 eixos bipolares'
              : (hasTriads ? '6 tríades' : 'Espectro'));
    final Size size = shareCardLogicalSize(story: story);
    final bool hasObservedEvidence =
        evidence.axes.isNotEmpty || evidence.triads.isNotEmpty;

    final CurrentCompatibility? primary = hasObservedEvidence
        ? EspectroCompatibilityEngine.evaluate(
            catalog: data.catalog,
            axes: record.axes,
            triads: record.triads,
          ).primaryMatch
        : null;

    final AtlasMatchResult? topThinker = hasObservedEvidence
        ? EspectroAtlasEngine.rankEntries(
            entries: data.atlas.canonicalPersonalities,
            axes: evidence.axes,
            triads: evidence.triads,
          ).firstOrNull
        : null;

    final StudySubject? primarySubject = primary != null
        ? StudySubject.fromCurrent(primary.current)
        : null;
    final StudySpectrum? primarySpectrum = primarySubject != null
        ? spectrumOf(primarySubject)
        : null;

    final Color traditionColor =
        primarySpectrum?.color ?? const Color(0xFFE5A64B);
    final Color traditionInk =
        primarySpectrum?.ink(true) ?? const Color(0xFFE5A64B);
    final String? spectrumLabel = primary != null
        ? (primarySpectrum?.name ?? primary.current.family)
        : null;

    final String dimensions = (hasAxes && hasTriads)
        ? '${evidence.axes.length}/${record.axes.length} eixos · '
              '${evidence.triads.length}/${record.triads.length} tríades com base observada'
        : hasAxes
        ? '${evidence.axes.length}/${record.axes.length} eixos bipolares observados'
        : hasTriads
        ? '${evidence.triads.length}/${record.triads.length} tríades com base observada'
        : 'Base observada insuficiente';
    final List<BipolarDimensionScore> observed = evidence.axes
        .take(story ? 3 : 1)
        .toList();
    final bool hasChartEvidence = evidence.axes.length >= 3;

    // Ordem canônica dos eixos para desenhar o polígono fiel no radar.
    final Map<String, int> orderMap = <String, int>{
      for (int i = 0; i < data.twelveAxes.axes.length; i++)
        data.twelveAxes.axes[i].id: i,
    };
    final List<BipolarDimensionScore> radarAxes =
        List<BipolarDimensionScore>.of(evidence.axes)..sort(
          (a, b) =>
              (orderMap[a.axisId] ?? 99).compareTo(orderMap[b.axisId] ?? 99),
        );

    const Color bgObsidian = Color(0xFF0B101A);
    const Color inkLight = Color(0xFFF7F4EC);
    const Color inkMuted = Color(0xFFA7B2C4);
    const Color ruleBorder = Color(0xFF232D3F);
    const Color brassAccent = Color(0xFFE5A64B);

    final Widget headerBlock =
        (primary != null && primarySubject != null && tension == null)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: story ? 54 : 46,
                height: story ? 54 : 46,
                padding: EdgeInsets.all(story ? 5 : 4),
                decoration: BoxDecoration(
                  color: traditionColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(story ? 13 : 11),
                  border: Border.all(
                    color: traditionColor.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                ),
                child: buildResilientAssetImage(
                  'assets/currents/${primary.current.id}.png',
                  fit: BoxFit.contain,
                  fallback: CurrentHeraldicEmblem(
                    subject: primarySubject,
                    size: story ? 44 : 38,
                  ),
                ),
              ),
              SizedBox(width: story ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${spectrumLabel ?? 'Arquétipo'} · ${MetricPresentation.formatPercent(primary.compatibilityPercent)} de convergência',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: story ? 11 : 10,
                        fontWeight: FontWeight.w700,
                        color: traditionInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      primary.current.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: story ? 20.5 : 17.5,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: inkLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dimensions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 9.5,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tension == null
                    ? 'Meu retrato político'
                    : 'Minha descoberta\nmais surpreendente',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: story
                      ? (tension != null ? 21 : 23)
                      : (tension != null ? 18 : 20),
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.55,
                  color: inkLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dimensions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 10,
                  color: inkMuted,
                ),
              ),
            ],
          );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
        key: const ValueKey('share-card-canvas'),
        width: size.width,
        height: size.height,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const ColoredBox(color: bgObsidian),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ShareCardPlatePainter(
                    accent: traditionColor,
                    ruleColor: ruleBorder,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  story ? 20 : 18,
                  story ? 18 : 16,
                  story ? 20 : 18,
                  story ? 16 : 14,
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
                    children: <Widget>[
                      // Colofão superior
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: FittedBox(child: EspectroBrandMark()),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ESPECTRO',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: inkLight,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${record.suite.title} · ${record.depth.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: inkMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: traditionColor.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              story ? 'STORY 9:16' : 'POST 1:1',
                              style: const TextStyle(
                                fontFamily: 'IBMPlexMono',
                                color: inkMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: story ? 12 : 9),
                      headerBlock,
                      SizedBox(height: story ? 10 : 8),
                      Container(height: 1, color: ruleBorder),
                      SizedBox(height: story ? 10 : 8),

                      if (!story)
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              if (hasChartEvidence) ...<Widget>[
                                Expanded(
                                  flex: 10,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 132,
                                        height: 132,
                                        child: CustomPaint(
                                          painter: _SharePosterRadarPainter(
                                            axes: radarAxes,
                                            axesMeta: data.twelveAxes.axes,
                                            accent: traditionColor,
                                            showShortLabels: false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Radar · ${radarAxes.length} eixos',
                                        style: const TextStyle(
                                          fontFamily: 'IBMPlexSans',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 140,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                  ),
                                  color: ruleBorder,
                                ),
                              ],
                              Expanded(
                                flex: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    _OpenHighlightReadout(
                                      tension: tension,
                                      nolan: evidence.nolan,
                                      accent: traditionColor,
                                      accentInk: traditionInk,
                                      compact: true,
                                    ),
                                    if (observed.isNotEmpty) ...<Widget>[
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 7,
                                        ),
                                        color: ruleBorder,
                                      ),
                                      _ShareAxisMiniBar(
                                        axis: observed.first,
                                        accent: traditionColor,
                                        accentInk: traditionInk,
                                        compact: true,
                                      ),
                                    ],
                                    if (topThinker != null) ...<Widget>[
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 7,
                                        ),
                                        color: ruleBorder,
                                      ),
                                      _ShareThinkerCompactRow(
                                        result: topThinker,
                                        portrait:
                                            data.portraits['personality:${topThinker.entry.id}'],
                                        accent: traditionColor,
                                      ),
                                    ] else if (!hasChartEvidence &&
                                        observed.isEmpty) ...<Widget>[
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        color: ruleBorder,
                                      ),
                                      const Text(
                                        'Responda pelo menos 3 eixos para gerar radar e convergências reais.',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSans',
                                          fontSize: 10.5,
                                          color: inkMuted,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...<Widget>[
                        if (hasChartEvidence) ...<Widget>[
                          Center(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  width: 168,
                                  height: 168,
                                  child: CustomPaint(
                                    painter: _SharePosterRadarPainter(
                                      axes: radarAxes,
                                      axesMeta: data.twelveAxes.axes,
                                      accent: traditionColor,
                                      showShortLabels: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Geometria observada em ${radarAxes.length} eixos',
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(height: 1, color: ruleBorder),
                          const SizedBox(height: 8),
                        ],
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: _OpenHighlightReadout(
                                  tension: tension,
                                  nolan: evidence.nolan,
                                  accent: traditionColor,
                                  accentInk: traditionInk,
                                  compact: false,
                                ),
                              ),
                              if (topThinker != null) ...<Widget>[
                                Container(
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                  ),
                                  color: ruleBorder,
                                ),
                                Expanded(
                                  child: _ShareThinkerCompactRow(
                                    result: topThinker,
                                    portrait:
                                        data.portraits['personality:${topThinker.entry.id}'],
                                    accent: traditionColor,
                                    label: 'Pensador mais próximo',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (observed.isNotEmpty) ...<Widget>[
                          Container(height: 1, color: ruleBorder),
                          const SizedBox(height: 8),
                          const Text(
                            'Eixos mais marcados',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: inkMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          for (int i = 0; i < observed.length; i++) ...<Widget>[
                            if (i > 0)
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                color: ruleBorder.withValues(alpha: 0.7),
                              ),
                            _ShareAxisMiniBar(
                              axis: observed[i],
                              accent: traditionColor,
                              accentInk: traditionInk,
                              compact: false,
                            ),
                          ],
                        ] else if (evidence.triads.isNotEmpty) ...<Widget>[
                          Container(height: 1, color: ruleBorder),
                          const SizedBox(height: 10),
                          Text(
                            evidence.triads.first.label,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: inkLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Apoio absoluto observado: ${MetricPresentation.formatPercent(evidence.triads.first.engagement * 100)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: inkMuted,
                            ),
                          ),
                        ] else ...<Widget>[
                          Container(height: 1, color: ruleBorder),
                          const SizedBox(height: 12),
                          const Text(
                            'Não há dimensões com cobertura suficiente para descrever tendências.',
                            style: TextStyle(fontSize: 11.5, color: inkMuted),
                          ),
                        ],
                        const Spacer(),
                      ],

                      Container(height: 1, color: ruleBorder),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Qual é o seu mapa?',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: inkLight,
                                  ),
                                ),
                                Text(
                                  entryLink ?? 'espectro-politico.web.app',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: brassAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: traditionColor.withValues(alpha: 0.40),
                              ),
                            ),
                            child: Text(
                              scopeBadge,
                              style: const TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: inkMuted,
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
}

class _ShareCardPlatePainter extends CustomPainter {
  const _ShareCardPlatePainter({
    required this.accent,
    required this.ruleColor,
  });

  final Color accent;
  final Color ruleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.032)
      ..strokeWidth = 0.7;
    const double step = 28.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 10), Offset(x, size.height - 10), gridPaint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), gridPaint);
    }

    const double inset = 8.0;
    final Rect frame = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    canvas.drawRect(
      frame,
      Paint()
        ..color = accent.withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    final Paint tickPaint = Paint()
      ..color = accent.withValues(alpha: 0.65)
      ..strokeWidth = 1.1;
    const double mark = 5.0;
    for (final Offset corner in <Offset>[
      frame.topLeft,
      frame.topRight,
      frame.bottomLeft,
      frame.bottomRight,
    ]) {
      canvas.drawLine(
        corner - const Offset(mark, 0),
        corner + const Offset(mark, 0),
        tickPaint,
      );
      canvas.drawLine(
        corner - const Offset(0, mark),
        corner + const Offset(0, mark),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShareCardPlatePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.ruleColor != ruleColor;
}

class _OpenHighlightReadout extends StatelessWidget {
  const _OpenHighlightReadout({
    required this.tension,
    required this.nolan,
    required this.accent,
    required this.accentInk,
    required this.compact,
  });

  final BipolarDimensionScore? tension;
  final NolanCoordinates? nolan;
  final Color accent;
  final Color accentInk;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const Color inkLight = Color(0xFFF7F4EC);
    const Color inkMuted = Color(0xFFA7B2C4);

    if (tension != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            tension!.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w700,
              color: accentInk,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Respostas aos dois polos revelam tensão ou contexto. Não definem contradição pessoal.',
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 9.5 : 10.5,
              color: inkLight.withValues(alpha: 0.88),
              height: 1.25,
            ),
          ),
        ],
      );
    }

    if (nolan != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            child: CustomPaint(
              painter: _MiniNolanCompassPainter(
                economicPct: nolan!.economicFreedom / 100.0,
                civilPct: nolan!.personalFreedom / 100.0,
                accent: accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Bússola de Nolan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE5A64B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Econ. ${nolan!.economicFreedom.round()}%\nCivil ${nolan!.personalFreedom.round()}%',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: compact ? 9.5 : 10.5,
                    fontWeight: FontWeight.w600,
                    color: inkLight,
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Nolan indeterminado',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 11.5 : 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE5A64B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Ainda falta base econômica ou civil. Nenhum ponto central foi atribuído.',
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10 : 10.5,
            color: inkMuted,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _ShareThinkerCompactRow extends StatelessWidget {
  const _ShareThinkerCompactRow({
    required this.result,
    required this.accent,
    this.portrait,
    this.label = 'Referência histórica',
  });

  final AtlasMatchResult result;
  final StudyPortrait? portrait;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String? path = portrait?.assetPath ?? result.entry.photoUrl;
    final String initials = result.entry.name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w.characters.first.toUpperCase())
        .join();
    final Widget fallback = Container(
      color: accent.withValues(alpha: 0.22),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF7F4EC),
        ),
      ),
    );
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.65)),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipOval(
            child: path != null && path.startsWith('assets/')
                ? buildResilientAssetImage(
                    path,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.4),
                    fallback: fallback,
                  )
                : fallback,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA7B2C4),
                ),
              ),
              Text(
                result.entry.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11,
                  height: 1.16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF7F4EC),
                ),
              ),
              Text(
                '${MetricPresentation.formatPercent(result.compatibilityPercent)} prox.',
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE5A64B),
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniNolanCompassPainter extends CustomPainter {
  const _MiniNolanCompassPainter({
    required this.economicPct,
    required this.civilPct,
    required this.accent,
  });

  final double economicPct;
  final double civilPct;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      r,
      Paint()
        ..color = const Color(0xFF2B374D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    final Paint crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 0.7;
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 2),
      crossPaint,
    );
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      crossPaint,
    );

    final double px = 3 + economicPct.clamp(0.0, 1.0) * (size.width - 6);
    final double py = (size.height - 3) - civilPct.clamp(0.0, 1.0) * (size.height - 6);
    canvas.drawCircle(
      Offset(px, py),
      4.5,
      Paint()
        ..color = accent.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(Offset(px, py), 2.3, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _MiniNolanCompassPainter oldDelegate) =>
      oldDelegate.economicPct != economicPct ||
      oldDelegate.civilPct != civilPct ||
      oldDelegate.accent != accent;
}

class _ShareAxisMiniBar extends StatelessWidget {
  const _ShareAxisMiniBar({
    required this.axis,
    required this.accent,
    required this.accentInk,
    this.compact = false,
  });

  final BipolarDimensionScore axis;
  final Color accent;
  final Color accentInk;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double norm = ((axis.score + 1.0) / 2.0).clamp(0.04, 0.96);
    final (Color lCol, Color rCol) = AxisColors.pairs[axis.axisId] ??
        (accent, accent);
    final Color rawAxisColor = axis.isIndeterminate
        ? accent
        : (axis.score <= 0 ? lCol : rCol);
    final Color axisBarColor = AxisColors.readableInk(
      rawAxisColor,
      isDark: true,
      background: const Color(0xFF0B101A),
    );
    final String valueLabel = axis.isIndeterminate
        ? 'Indeterminado'
        : (axis.score.abs() < 0.05
              ? 'Equilibrado (${MetricPresentation.formatPercent(axis.leftPercent)} / ${MetricPresentation.formatPercent(axis.rightPercent)})'
              : '${MetricPresentation.formatPercent(axis.dominantPercent)} ${axis.dominantPole}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (compact) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(
                AxisColors.iconFor(axis.axisId),
                size: 11,
                color: axisBarColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  axis.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF7F4EC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1.5),
          Text(
            valueLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: axisBarColor,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ] else
          Row(
            children: <Widget>[
              Icon(
                AxisColors.iconFor(axis.axisId),
                size: 12,
                color: axisBarColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                flex: 3,
                child: Text(
                  axis.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF7F4EC),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: axisBarColor,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, box) {
            final double w = box.maxWidth;
            final double dotX = math.max(0.0, (w - 8) * norm);
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF232D3F),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ColoredBox(
                          color: lCol.withValues(
                            alpha: axis.score <= 0 ? 0.50 : 0.16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: rCol.withValues(
                            alpha: axis.score > 0 ? 0.50 : 0.16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: w * 0.5 - 0.5,
                  child: Container(
                    width: 1,
                    height: 8,
                    color: Colors.white.withValues(alpha: 0.42),
                  ),
                ),
                Positioned(
                  left: dotX,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: axisBarColor,
                      border: Border.all(
                        color: const Color(0xFFF7F4EC),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                axis.leftPole,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFFA7B2C4),
                ),
              ),
            ),
            Flexible(
              child: Text(
                axis.rightPole,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFFA7B2C4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SharePosterRadarPainter extends CustomPainter {
  const _SharePosterRadarPainter({
    required this.axes,
    required this.axesMeta,
    required this.accent,
    required this.showShortLabels,
  });

  final List<BipolarDimensionScore> axes;
  final List<data.Axis> axesMeta;
  final Color accent;
  final bool showShortLabels;

  static String _shortAxisLabel(String id, String fallback) => switch (id) {
    'estrutura' => 'Estrutura',
    'representacao' => 'Democ.',
    'poder' => 'Poder',
    'imigracao' => 'Imigr.',
    'diplomacia' => 'Diplo.',
    'intervencao' => 'Interv.',
    'economia' => 'Economia',
    'controle' => 'Controle',
    'comercio' => 'Comércio',
    'religiao' => 'Religião',
    'moral' => 'Moral',
    'tecnologia' => 'Tecnol.',
    _ => fallback,
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - (showShortLabels ? 24 : 5);
    if (maxR <= 6) return;

    final Paint ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final double f in const <double>[0.33, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    // Anel neutro 50% tracejado em 24 arcos
    final double midR = maxR * 0.5;
    final Paint neutralRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    const int dashCount = 24;
    const double arcSpan = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: midR),
        i * arcSpan,
        arcSpan * 0.55,
        false,
        neutralRing,
      );
    }

    final int n = axes.length;
    final Path poly = Path();
    final List<Offset> pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);
      final double norm = ((axes[i].score + 1.0) / 2.0).clamp(0.10, 0.98);
      final Offset pt = center + dir * (maxR * norm);
      pts.add(pt);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }

      if (showShortLabels && i.isEven) {
        final String shortLbl = _shortAxisLabel(axes[i].axisId, axes[i].label);
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: shortLbl,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA7B2C4),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final Offset lblCenter = center + dir * (maxR + 13);
        tp.paint(
          canvas,
          Offset(lblCenter.dx - tp.width / 2, lblCenter.dy - tp.height / 2),
        );
      }
    }
    poly.close();
    canvas.drawPath(poly, Paint()..color = accent.withValues(alpha: 0.28));
    canvas.drawPath(
      poly,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    final Paint dotRing = Paint()..color = accent;
    final Paint dotCore = Paint()..color = const Color(0xFFF7F4EC);
    for (final Offset pt in pts) {
      canvas.drawCircle(pt, 2.3, dotRing);
      canvas.drawCircle(pt, 1.0, dotCore);
    }
  }

  @override
  bool shouldRepaint(covariant _SharePosterRadarPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.axes != axes ||
      oldDelegate.showShortLabels != showShortLabels;
}
