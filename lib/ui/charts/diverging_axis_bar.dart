import 'package:flutter/material.dart';

import '../../domain/models/political_models.dart';
import '../../theme.dart';
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
    final colors =
        AxisColors.pairs[dimension.axisId] ?? (p.poleLeft, p.poleRight);

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
                    Flexible(
                      child: Text(
                        dimension.label,
                        style: text.titleMedium,
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
              Text(
                dimension.summary,
                style: text.labelLarge?.copyWith(
                  fontSize: 12.5,
                  color: dimension.isIndeterminate
                      ? p.muted
                      : (dimension.leansLeft ? colors.$1 : colors.$2),
                ),
              ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 17, color: p.muted),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 22,
            width: double.infinity,
            child: CustomPaint(
              painter: _DivergingBarPainter(
                score: dimension.score,
                scoreLow: dimension.scoreLow,
                scoreHigh: dimension.scoreHigh,
                isIndeterminate: dimension.isIndeterminate,
                baselineScore: baselineScore,
                palette: p,
                colors: colors,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${dimension.leftPole} · ${dimension.leftPercent.round()}%',
                  style: text.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: dimension.leansLeft
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: dimension.leansLeft ? colors.$1 : p.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '±${(dimension.standardError * 98).round()} pp · '
                '${(dimension.coverage * 100).round()}%',
                style: text.bodySmall?.copyWith(fontSize: 10.5, color: p.muted),
              ),
              Expanded(
                child: Text(
                  '${dimension.rightPercent.round()}% · ${dimension.rightPole}',
                  textAlign: TextAlign.right,
                  style: text.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: !dimension.leansLeft
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: !dimension.leansLeft ? colors.$2 : p.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
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
    required this.baselineScore,
    required this.palette,
    required this.colors,
  });

  final double score;
  final double scoreLow;
  final double scoreHigh;
  final bool isIndeterminate;
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
    final RRect track = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, midY),
        width: size.width,
        height: trackHeight,
      ),
      const Radius.circular(99),
    );
    canvas.drawRRect(track, Paint()..color = palette.surfaceMuted);

    final double centerX = size.width / 2;

    if (!isIndeterminate) {
      // Faixa translúcida de incerteza [scoreLow..scoreHigh].
      final double lowX = _xOf(scoreLow, size.width);
      final double highX = _xOf(scoreHigh, size.width);
      final Color activeColor = score <= 0 ? colors.$1 : colors.$2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(lowX, midY - 7, highX, midY + 7),
          const Radius.circular(6),
        ),
        Paint()
          ..color = activeColor.withValues(alpha: palette.isDark ? 0.22 : 0.16),
      );

      // Barra divergente do centro (50%) até o escore atual.
      final double scoreX = _xOf(score, size.width);
      final double barLeft = scoreX < centerX ? scoreX : centerX;
      final double barRight = scoreX < centerX ? centerX : scoreX;
      if ((barRight - barLeft) >= 1.0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              barLeft,
              midY - trackHeight / 2,
              barRight,
              midY + trackHeight / 2,
            ),
            const Radius.circular(99),
          ),
          Paint()..color = activeColor,
        );
      }

      // Marcador fantasma da avaliação anterior, se presente.
      if (baselineScore != null) {
        final double baseX = _xOf(baselineScore!, size.width);
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

      // Ponto principal.
      canvas.drawCircle(
        Offset(scoreX, midY),
        6.0,
        Paint()..color = activeColor,
      );
      canvas.drawCircle(
        Offset(scoreX, midY),
        6.0,
        Paint()
          ..color = palette.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Marca central (0.0 / 50%).
    canvas.drawLine(
      Offset(centerX, midY - 8),
      Offset(centerX, midY + 8),
      Paint()
        ..color = palette.ink.withValues(alpha: 0.35)
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _DivergingBarPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.scoreLow != scoreLow ||
        oldDelegate.scoreHigh != scoreHigh ||
        oldDelegate.isIndeterminate != isIndeterminate ||
        oldDelegate.baselineScore != baselineScore ||
        oldDelegate.palette != palette ||
        oldDelegate.colors != colors;
  }
}
