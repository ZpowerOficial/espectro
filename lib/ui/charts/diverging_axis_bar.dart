import 'package:flutter/material.dart';

import '../../domain/models/political_models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'axis_colors.dart';

/// Barra bipolar divergente centrada em 50%, com faixa de incerteza (`±1.96·SE`),
/// alerta visual opcional de tensão interna e marcador fantasma opcional de comparação.
class DivergingAxisBar extends StatelessWidget {
  const DivergingAxisBar({
    required this.dimension,
    this.baselineScore,
    this.onTap,
    super.key,
  });

  final BipolarDimensionScore dimension;

  /// Escore `S` (`-1..+1`) de uma avaliação anterior para sobreposição comparativa.
  final double? baselineScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final AxisColorStrategy strategy = AxisColorStrategyScope.of(context);
    final (Color rawL, Color rawR) =
        AxisColors.pairs[dimension.axisId] ?? (p.poleLeft, p.poleRight);
    final Color anchorColor = AxisColors.primaryFor(dimension.axisId, p);
    final bool isIndeterminate = dimension.isIndeterminate;
    final bool hasObservedLean =
        !isIndeterminate && dimension.score.abs() >= 0.15;
    final bool isObservedBalanced = !isIndeterminate && !hasObservedLean;

    // Estados indeterminados nunca privilegiam polos em nenhuma estratégia.
    // Em primaryAnchor, somente inclinações efetivamente observadas (|S| >= 0.15)
    // recebem destaque unilateral; eixos equilibrados mantêm simetria neutra.
    final (Color, Color) colors = isIndeterminate
        ? (p.muted, p.muted)
        : (strategy == AxisColorStrategy.primaryAnchor
              ? (hasObservedLean
                    ? (dimension.leansLeft
                          ? (anchorColor, p.line)
                          : (p.line, anchorColor))
                    : (p.muted, p.muted))
              : (rawL, rawR));

    final String dominantPole = dimension.leansLeft
        ? dimension.leftPole
        : dimension.rightPole;
    final int dominantPercent = dimension.leansLeft
        ? dimension.leftPercent.round()
        : dimension.rightPercent.round();
    final Color dominantColor = isIndeterminate
        ? p.muted
        : (strategy == AxisColorStrategy.primaryAnchor
              ? anchorColor
              : (hasObservedLean
                    ? (dimension.leansLeft ? colors.$1 : colors.$2)
                    : p.inkSoft));
    final Color dominantInk = isIndeterminate
        ? p.muted
        : AxisColors.readableInk(dominantColor, isDark: p.isDark);
    final IconData axisIcon = AxisColors.iconFor(dimension.axisId);

    final Widget content = Semantics(
      button: onTap != null,
      label:
          '${dimension.label}: ${dimension.summary}. '
          '${dimension.leftPole} ${dimension.leftPercent.round()}%, '
          '${dimension.rightPole} ${dimension.rightPercent.round()}%. '
          'Margem de incerteza entre ${dimension.rightPercentLow.round()}% e '
          '${dimension.rightPercentHigh.round()}% para ${dimension.rightPole}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Icon(axisIcon, size: 15, color: dominantInk),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        dimension.label,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dimension.hasInternalTension) ...<Widget>[
                      const SizedBox(width: 6),
                      Tooltip(
                        message:
                            'Respostas favoráveis a aspectos de ambos os polos',
                        child: Icon(
                          Icons.swap_calls_rounded,
                          size: 15,
                          color: p.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isIndeterminate)
                Text(
                  dimension.summary,
                  style: text.labelLarge?.copyWith(
                    fontSize: 12,
                    color: p.muted,
                  ),
                )
              else if (isObservedBalanced)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: p.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: p.line, width: 1),
                  ),
                  child: Text(
                    'Equilibrado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                      color: p.inkSoft,
                    ),
                  ),
                )
              else
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: dominantColor.withValues(
                        alpha: p.isDark ? 0.18 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: dominantColor.withValues(
                          alpha: p.isDark ? 0.40 : 0.28,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$dominantPercent% $dominantPole',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: dominantInk,
                      ),
                    ),
                  ),
                ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 17, color: p.muted),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 22,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: dimension.score),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 420),
              curve: EspectroMotion.easeOut,
              builder: (context, animScore, _) {
                return CustomPaint(
                  painter: _DivergingBarPainter(
                    score: animScore,
                    scoreLow: dimension.scoreLow,
                    scoreHigh: dimension.scoreHigh,
                    isIndeterminate: isIndeterminate,
                    hasObservedLean: hasObservedLean,
                    baselineScore: baselineScore,
                    palette: p,
                    colors: colors,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Flexible(
                child: PolePill(
                  label: dimension.leftPole,
                  color: hasObservedLean ? colors.$1 : colors.$1,
                  isActive: hasObservedLean && dimension.leansLeft,
                  badge: isIndeterminate ? '—' : '${dimension.leftPercent.round()}%',
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isIndeterminate
                    ? 'sem base'
                    : '±${(dimension.standardError * 98).round()} pp',
                style: text.bodySmall?.copyWith(
                  fontSize: 10,
                  fontFamily: 'IBMPlexMono',
                  color: p.muted,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: PolePill(
                  label: dimension.rightPole,
                  color: colors.$2,
                  isActive: hasObservedLean && !dimension.leansLeft,
                  badge: isIndeterminate ? '—' : '${dimension.rightPercent.round()}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}

class _DivergingBarPainter extends CustomPainter {
  const _DivergingBarPainter({
    required this.score,
    required this.scoreLow,
    required this.scoreHigh,
    required this.isIndeterminate,
    required this.hasObservedLean,
    required this.baselineScore,
    required this.palette,
    required this.colors,
  });

  final double score;
  final double scoreLow;
  final double scoreHigh;
  final bool isIndeterminate;
  final bool hasObservedLean;
  final double? baselineScore;
  final EspectroPalette palette;
  final (Color, Color) colors;

  double _xOf(double s, double width) =>
      ((s.clamp(-1.0, 1.0) + 1.0) / 2.0) * width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final double midY = size.height / 2;
    final double trackHeight = 8.0;
    final double centerX = size.width / 2;
    const double gap = 2.0;

    // Dual-track arredondada no mesmo padrão da Teia e Perfil.
    final double halfW = (size.width - gap) / 2;
    final Color leftColor = colors.$1;
    final Color rightColor = colors.$2;

    Color trackPaintColor(Color trackColor, {required bool activeHalf}) {
      if (isIndeterminate) return palette.surfaceMuted;
      if (!hasObservedLean) {
        return trackColor == palette.muted
            ? palette.muted.withValues(alpha: palette.isDark ? 0.30 : 0.24)
            : trackColor.withValues(alpha: palette.isDark ? 0.42 : 0.34);
      }
      if (trackColor == palette.line) {
        return palette.line.withValues(alpha: palette.isDark ? 0.85 : 0.72);
      }
      return trackColor.withValues(
        alpha: activeHalf
            ? (palette.isDark ? 0.85 : 0.80)
            : (palette.isDark ? 0.24 : 0.16),
      );
    }

    // Trilho esquerdo.
    final RRect leftTrack = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, midY - trackHeight / 2, halfW, trackHeight),
      const Radius.circular(99),
    );
    canvas.drawRRect(
      leftTrack,
      Paint()..color = trackPaintColor(leftColor, activeHalf: score < 0),
    );

    // Trilho direito.
    final RRect rightTrack = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + gap / 2, midY - trackHeight / 2, halfW, trackHeight),
      const Radius.circular(99),
    );
    canvas.drawRRect(
      rightTrack,
      Paint()..color = trackPaintColor(rightColor, activeHalf: score > 0),
    );

    if (!isIndeterminate) {
      // Faixa translúcida de incerteza [scoreLow..scoreHigh].
      final double lowX = _xOf(scoreLow, size.width);
      final double highX = _xOf(scoreHigh, size.width);
      final Color activeColor = !hasObservedLean
          ? palette.inkSoft
          : (score <= 0 ? leftColor : rightColor);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(lowX, midY - 6.5, highX, midY + 6.5),
          const Radius.circular(6),
        ),
        Paint()
          ..color = activeColor.withValues(
            alpha: palette.isDark ? 0.22 : 0.14,
          ),
      );

      // Marcador fantasma da avaliação anterior, se presente.
      if (baselineScore != null) {
        final double baseX = _xOf(baselineScore!, size.width);
        final double scoreX = _xOf(score, size.width);
        canvas.drawLine(
          Offset(baseX, midY),
          Offset(scoreX, midY),
          Paint()
            ..color = palette.muted.withValues(alpha: 0.6)
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          Offset(baseX, midY),
          4.5,
          Paint()..color = palette.surface,
        );
        canvas.drawCircle(
          Offset(baseX, midY),
          4.5,
          Paint()
            ..color = palette.muted
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }

      // Knob indicador do escore atual com borda externa nítida (sem glow blur).
      final double scoreX = _xOf(score, size.width);
      canvas.drawCircle(
        Offset(scoreX, midY),
        7.0,
        Paint()
          ..color = palette.line.withValues(alpha: palette.isDark ? 0.9 : 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      canvas.drawCircle(
        Offset(scoreX, midY),
        6.0,
        Paint()..color = palette.surface,
      );
      canvas.drawCircle(
        Offset(scoreX, midY),
        6.0,
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // Linha central neutra discreta.
    canvas.drawLine(
      Offset(centerX, midY - 6),
      Offset(centerX, midY + 6),
      Paint()
        ..color = palette.ink.withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _DivergingBarPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.scoreLow != scoreLow ||
        oldDelegate.scoreHigh != scoreHigh ||
        oldDelegate.isIndeterminate != isIndeterminate ||
        oldDelegate.hasObservedLean != hasObservedLean ||
        oldDelegate.baselineScore != baselineScore ||
        oldDelegate.palette != palette ||
        oldDelegate.colors != colors;
  }
}
