import 'package:flutter/material.dart' hide Axis;

import '../../data/app_data.dart';
import '../../data/models.dart';
import '../../engine/twelve_axes_engine.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'twelve_quiz_screen.dart';

class TwelveIntroScreen extends StatefulWidget {
  const TwelveIntroScreen({required this.data, super.key});

  final AppData data;

  @override
  State<TwelveIntroScreen> createState() => _TwelveIntroScreenState();
}

class _TwelveIntroScreenState extends State<TwelveIntroScreen> {
  TwelveVariant _variant = TwelveVariant.short;

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            TwelveQuizScreen(data: widget.data, variant: _variant),
      ),
    );
  }

  void _showAxes() {
    final List<Axis> axes = widget.data.twelveAxes.axes;
    showInfoSheet(
      context,
      title: 'Os doze eixos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Cada eixo é um par de polos. Seu resultado mostra o quanto você pende '
            'para cada lado — o centro não é uma resposta "certa".',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          for (final Axis axis in axes) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: axis.leftColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: axis.rightColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          axis.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: axis.leftPole,
                                style: TextStyle(
                                  color: Color.lerp(
                                    axis.leftColor,
                                    AppColors.ink,
                                    0.15,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '  ·  '),
                              TextSpan(
                                text: axis.rightPole,
                                style: TextStyle(
                                  color: Color.lerp(
                                    axis.rightColor,
                                    AppColors.ink,
                                    0.15,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
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
            const Eyebrow('12 Eixos'),
            const SizedBox(height: 12),
            Text(
              'Doze eixos.\nUm retrato do seu poder.',
              style: text.displayMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Responda a afirmações sobre como o poder, a economia e a sociedade '
              'deveriam funcionar. O resultado mostra onde você fica em cada par de polos.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 26),
            Text('Escolha a duração', style: text.titleMedium),
            const SizedBox(height: 10),
            for (final TwelveVariant variant
                in TwelveVariant.values) ...<Widget>[
              _VariantCard(
                variant: variant,
                selected: _variant == variant,
                onTap: () => setState(() => _variant = variant),
              ),
              if (variant != TwelveVariant.values.last)
                const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Começar · ${_variant.label}',
              icon: Icons.arrow_forward_rounded,
              onPressed: _start,
            ),
            const SizedBox(height: 12),
            Text(
              'Escala de 5 respostas. Você pode voltar e trocar antes de terminar. '
              'Nada é enviado para a internet.',
              style: text.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            SectionCard(
              color: AppColors.surfaceAlt,
              borderColor: AppColors.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Como ler o resultado'),
                  const SizedBox(height: 12),
                  Text(
                    'Cada barra tem dois lados. O ponto mais próximo de um polo indica '
                    'a sua tendência naquele eixo; perto do centro, o eixo é equilibrado.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _showAxes,
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Conhecer os doze eixos',
                          style: text.labelLarge?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
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

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final TwelveVariant variant;
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
                    Text(variant.description, style: text.bodySmall),
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
