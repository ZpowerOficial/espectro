import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../engine/twelve_axes_engine.dart';
import '../../theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

class TwelveResultScreen extends StatelessWidget {
  const TwelveResultScreen({
    required this.result,
    required this.archetype,
    required this.variantLabel,
    super.key,
  });

  final TwelveAxesResult result;
  final List<({String label, String answer})> archetype;
  final String variantLabel;

  Future<void> _copy(BuildContext context) async {
    final StringBuffer buffer = StringBuffer(result.toShareText());
    if (archetype.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln()
        ..writeln('Perfil');
      for (final ({String label, String answer}) item in archetype) {
        buffer.writeln('${item.label}: ${item.answer}');
      }
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumo copiado para a área de transferência.')),
    );
  }

  String get _synthesis {
    final AxisScore strongest = result.strongest;
    final AxisScore balanced = result.mostBalanced;
    final int left = result.leaningLeftCount;
    final String firstPole = result.scores.first.axis.leftPole;
    final String distribution = switch (left) {
      0 => 'Todos os doze eixos apontam para o segundo polo.',
      12 => 'Todos os doze eixos apontam para o primeiro polo.',
      6 => 'Metade dos eixos aponta para cada lado.',
      _ => '$left de 12 eixos apontam para o primeiro polo de cada par.',
    };
    return 'Seu ponto mais forte é ${strongest.axis.label} (${strongest.summary}). '
        'O eixo mais equilibrado é ${balanced.axis.label}. $distribution '
        'O primeiro polo do seu mapa é $firstPole.';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AxisScore strongest = result.strongest;
    final Color strongestColor = strongest.leansLeft
        ? strongest.axis.leftColor
        : strongest.axis.rightColor;
    final int balancedCount = result.scores.where((score) => score.isBalanced).length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  tooltip: 'Voltar ao início',
                ),
                const Spacer(),
                Tag(label: '12 eixos · $variantLabel'),
              ],
            ),
            const SizedBox(height: 18),
            SectionCard(
              color: AppColors.dark,
              borderColor: AppColors.dark,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Seu resultado', color: Color(0xFF9AA69E)),
                  const SizedBox(height: 16),
                  Text(
                    'Seu eixo mais forte',
                    style: text.bodySmall?.copyWith(color: const Color(0xFF9AA69E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strongest.axis.label,
                    style: text.displayMedium?.copyWith(color: AppColors.surface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: strongestColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          strongest.summary,
                          style: text.labelLarge?.copyWith(
                            color: AppColors.surface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppColors.darkSoft),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _HeroStat(value: '${result.leaningLeftCount}/12', label: 'à esquerda'),
                      _HeroStat(value: '$balancedCount', label: 'equilibrados'),
                      _HeroStat(value: '${result.answeredCount}', label: 'respostas'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Mapa'),
                  const SizedBox(height: 12),
                  Center(child: AxisRadialChart(scores: result.scores)),
                  const SizedBox(height: 12),
                  Text(
                    'Cada raio é um eixo. Quanto mais longe do centro, mais forte a '
                    'inclinação; a cor indica o polo dominante.',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Eixo por eixo'),
                  const SizedBox(height: 14),
                  for (var i = 0; i < result.scores.length; i++) ...<Widget>[
                    _AxisRow(score: result.scores[i]),
                    if (i != result.scores.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              color: AppColors.surfaceAlt,
              borderColor: AppColors.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Síntese'),
                  const SizedBox(height: 12),
                  Text(_synthesis, style: text.bodyLarge),
                ],
              ),
            ),
            if (archetype.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Eyebrow('Seu perfil'),
                    const SizedBox(height: 12),
                    for (var i = 0; i < archetype.length; i++) ...<Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 96,
                            child: Text(
                              archetype[i].label.toUpperCase(),
                              style: text.labelSmall?.copyWith(fontSize: 9, color: AppColors.muted),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(archetype[i].answer, style: text.bodyMedium),
                          ),
                        ],
                      ),
                      if (i != archetype.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(),
                        ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            AppButton(
              label: 'Copiar resumo',
              icon: Icons.copy_rounded,
              onPressed: () => _copy(context),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Voltar ao início',
              kind: AppButtonKind.outline,
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            const SizedBox(height: 14),
            Text(
              'Resultado calculado no aparelho. Nenhuma resposta foi enviada.',
              style: text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: text.headlineSmall?.copyWith(color: AppColors.surface, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: text.bodySmall?.copyWith(color: const Color(0xFF9AA69E), fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _AxisRow extends StatelessWidget {
  const _AxisRow({required this.score});

  final AxisScore score;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int left = score.leftPercent.round().clamp(1, 99);
    final int right = 100 - left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                score.axis.label,
                style: text.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              score.summary,
              style: text.labelLarge?.copyWith(fontSize: 12.5, color: AppColors.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 9,
            child: Row(
              children: <Widget>[
                Expanded(flex: left, child: Container(color: score.axis.leftColor)),
                Expanded(flex: right, child: Container(color: score.axis.rightColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${score.axis.leftPole} · ${score.leftPercent.round()}%',
                style: text.bodySmall?.copyWith(
                  color: Color.lerp(score.axis.leftColor, AppColors.ink, 0.15),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${score.rightPercent.round()}% · ${score.axis.rightPole}',
                textAlign: TextAlign.right,
                style: text.bodySmall?.copyWith(
                  color: Color.lerp(score.axis.rightColor, AppColors.ink, 0.15),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
