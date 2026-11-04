import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../engine/six_triangles_engine.dart';
import '../../theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

class SixResultScreen extends StatelessWidget {
  const SixResultScreen({
    required this.result,
    required this.variantLabel,
    super.key,
  });

  final SixTrianglesResult result;
  final String variantLabel;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.toShareText()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumo copiado para a área de transferência.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double wheelSize = (MediaQuery.sizeOf(context).width - 84).clamp(
      190,
      320,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  tooltip: 'Voltar ao início',
                ),
                const Spacer(),
                Tag(label: 'six triangles · $variantLabel'),
              ],
            ),
            const SizedBox(height: 18),
            SectionCard(
              color: AppColors.dark,
              borderColor: AppColors.dark,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Eyebrow('Seu resultado', color: Color(0xFF9AA69E)),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Seus seis triângulos',
                      style: text.headlineLarge?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cada ponto mostra o peso dos três vértices no seu perfil.',
                      style: text.bodySmall?.copyWith(
                        color: const Color(0xFF9AA69E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SixWheel(
                    triangles: result.triangles,
                    size: wheelSize,
                    gapColor: AppColors.dark,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      for (final TriangleScore triangle in result.triangles)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: triangle.category.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  triangle.category.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall?.copyWith(
                                    fontSize: 8.5,
                                    height: 1.15,
                                    color: const Color(0xFFC3CCC6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final TriangleScore triangle in result.triangles) ...<Widget>[
              _TriangleCard(triangle: triangle),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 6),
            SectionCard(
              color: AppColors.surfaceAlt,
              borderColor: AppColors.surfaceAlt,
              child: Text(
                'Cada triângulo soma 100%. O ponto é a média ponderada dos três vértices; '
                'quanto mais perto de um canto, mais concentrado aquele lado do seu perfil.',
                style: text.bodySmall,
              ),
            ),
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
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
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

class _TriangleCard extends StatelessWidget {
  const _TriangleCard({required this.triangle});

  final TriangleScore triangle;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color barColor =
        Color.lerp(triangle.category.color, AppColors.ink, 0.35) ??
        AppColors.ink;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TriangleMini(triangle: triangle, size: 66),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Eyebrow(triangle.category.label),
                    const SizedBox(height: 6),
                    Text(triangle.classification, style: text.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    triangle.category.subcategories[i],
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  '${triangle.percents[i].toStringAsFixed(1)}%',
                  style: text.labelLarge?.copyWith(
                    fontSize: 12.5,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: 7,
                color: AppColors.line,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (triangle.percents[i] / 100).clamp(0, 1),
                  child: ColoredBox(color: barColor),
                ),
              ),
            ),
            if (i != 2) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
