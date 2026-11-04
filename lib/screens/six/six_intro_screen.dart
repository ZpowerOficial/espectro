import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../data/models.dart';
import '../../engine/six_triangles_engine.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'six_quiz_screen.dart';

class SixIntroScreen extends StatefulWidget {
  const SixIntroScreen({required this.data, super.key});

  final AppData data;

  @override
  State<SixIntroScreen> createState() => _SixIntroScreenState();
}

class _SixIntroScreenState extends State<SixIntroScreen> {
  SixVariant _variant = SixVariant.short;

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SixQuizScreen(data: widget.data, variant: _variant),
      ),
    );
  }

  void _showMethod() {
    showInfoSheet(
      context,
      title: 'Como o triângulo funciona',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Cada uma das seis áreas tem três vértices. Suas respostas somam peso para '
            'cada vértice; o total de cada triângulo é normalizado para 100%.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'O ponto dentro do triângulo é a média ponderada dos três vértices. '
            'Quanto mais perto de um canto, mais concentrado naquele vértice.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const Eyebrow('Classificações'),
          const SizedBox(height: 10),
          for (final (String title, String text) in <(String, String)>[
            ('Centrista', 'Os três vértices ficam próximos entre si.'),
            ('Em destaque', 'Um vértice passa de 50%, mas sem dominar.'),
            ('Extremo', 'Um vértice passa de 75%.'),
            ('Fanático', 'Um vértice passa de 90%.'),
            ('Anti-', 'Um vértice fica muito abaixo dos outros dois.'),
          ]) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: '$title: ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: text),
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<SixCategory> categories = widget.data.sixTriangles.categories;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Voltar',
                ),
                const Spacer(),
                const Tag(label: 'offline'),
              ],
            ),
            const SizedBox(height: 28),
            const Eyebrow('Six Triangles'),
            const SizedBox(height: 12),
            Text(
              'Seis triângulos.\nDezoito vértices.',
              style: text.displayMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Cada área tem três caminhos possíveis. Responda e veja onde o seu '
              'ponto cai dentro de cada triângulo.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            SectionCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('As seis áreas'),
                  const SizedBox(height: 12),
                  for (var i = 0; i < categories.length; i++) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              categories[i].color,
                              AppColors.ink,
                              0.25,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          categories[i].label,
                          style: text.titleMedium?.copyWith(fontSize: 14),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            categories[i].subcategories.join(' · '),
                            textAlign: TextAlign.right,
                            style: text.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    if (i != categories.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Divider(),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Escolha a duração', style: text.titleMedium),
            const SizedBox(height: 10),
            for (final SixVariant variant in SixVariant.values) ...<Widget>[
              _SixVariantCard(
                variant: variant,
                selected: _variant == variant,
                onTap: () => setState(() => _variant = variant),
              ),
              if (variant != SixVariant.values.last) const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Começar · ${_variant.label}',
              icon: Icons.arrow_forward_rounded,
              onPressed: _start,
            ),
            const SizedBox(height: 12),
            Text(
              'Escala de 5 respostas. A pergunta avança assim que você escolhe; '
              'dá para voltar e revisar.',
              style: text.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _showMethod,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.inkSoft,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Como o triângulo é calculado',
                    style: text.labelLarge?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 15,
                    color: AppColors.inkSoft,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SixVariantCard extends StatelessWidget {
  const _SixVariantCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final SixVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${variant.questionCount}',
                  style: text.titleLarge?.copyWith(
                    color: selected ? AppColors.surface : AppColors.ink,
                    fontSize: 19,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(variant.label, style: text.titleMedium),
                        const SizedBox(width: 8),
                        Text('· ${variant.duration}', style: text.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      variant == SixVariant.short
                          ? 'Uma pergunta por célula, leitura rápida.'
                          : 'Duas perguntas por célula, retrato mais firme.',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 22,
                color: selected ? AppColors.ink : AppColors.line,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
