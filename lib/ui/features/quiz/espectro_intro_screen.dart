import 'package:flutter/material.dart' hide Axis;

import '../../../data/models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../../view_models/quiz_view_model.dart';
import 'espectro_quiz_screen.dart';

/// Tela de configuração pré-teste para qualquer modalidade do Espectro.
class EspectroIntroScreen extends StatefulWidget {
  const EspectroIntroScreen({
    required this.appViewModel,
    required this.suite,
    this.initialDepth = TestDepth.express,
    super.key,
  });

  final AppViewModel appViewModel;
  final TestSuite suite;
  final TestDepth initialDepth;

  @override
  State<EspectroIntroScreen> createState() => _EspectroIntroScreenState();
}

class _EspectroIntroScreenState extends State<EspectroIntroScreen> {
  late TestDepth _depth = widget.initialDepth;

  void _start() {
    final QuizViewModel quizVm = QuizViewModel.startNew(
      data: widget.appViewModel.data,
      repository: widget.appViewModel.repository,
      suite: widget.suite,
      depth: _depth,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroQuizScreen(
          appViewModel: widget.appViewModel,
          quizViewModel: quizVm,
        ),
      ),
    );
  }

  void _showDimensionsSheet() {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final List<Axis> axes = widget.appViewModel.data.twelveAxes.axes;
    final List<SixCategory> cats =
        widget.appViewModel.data.sixTriangles.categories;

    showInfoSheet(
      context,
      title: 'Dimensões avaliadas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.suite.includesAxes) ...<Widget>[
            const Eyebrow('12 Eixos Bipolares'),
            const SizedBox(height: 12),
            for (final Axis axis in axes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        axis.label,
                        style: text.titleMedium?.copyWith(fontSize: 13.5),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        '${axis.leftPole}  ↔  ${axis.rightPole}',
                        textAlign: TextAlign.right,
                        style: text.bodySmall?.copyWith(color: p.inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (widget.suite.includesAxes && widget.suite.includesTriads)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
          if (widget.suite.includesTriads) ...<Widget>[
            const Eyebrow('6 Tríades Políticas'),
            const SizedBox(height: 12),
            for (final SixCategory cat in cats)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: p.triadColor(cat.id),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Text(
                        cat.label,
                        style: text.titleMedium?.copyWith(fontSize: 13.5),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        cat.subcategories.join(' · '),
                        textAlign: TextAlign.right,
                        style: text.bodySmall?.copyWith(color: p.inkSoft),
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
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final axesPool = widget.appViewModel.data.twelveAxes.questions.length;
    final triadsPool = widget.appViewModel.data.sixTriangles.questions.length;
    final count = _depth.expectedCount(
      widget.suite,
      totalAxesPool: axesPool,
      totalTriadsPool: triadsPool,
    );
    return EspectroScaffold(
      appViewModel: widget.appViewModel,
      selectedIndex: 1,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _showDimensionsSheet,
            child: const Text('Dimensões'),
          ),
        ],
      ),
      body: ResponsiveContentFrame(
        maxWidth: EspectroLayout.workspaceMaxWidth,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
            final bool sideBySide = constraints.maxWidth >= 820 && scale <= 1.35;

            final Widget depthList = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var idx = 0; idx < TestDepth.values.length; idx++) ...[
                  () {
                    final depth = TestDepth.values[idx];
                    final n = depth.expectedCount(
                      widget.suite,
                      totalAxesPool: axesPool,
                      totalTriadsPool: triadsPool,
                    );
                    final selected = _depth == depth;
                    final int level = idx + 1;
                    final int totalLevels = TestDepth.values.length;
                    final String? badgeText = switch (depth) {
                      TestDepth.express =>
                        widget.suite == TestSuite.espectroIntegrated
                            ? 'Só eixos'
                            : 'Mais rápido',
                      TestDepth.standard => 'Equilibrada',
                      TestDepth.exhaustive => 'Completa',
                      _ => null,
                    };
                    return Semantics(
                      selected: selected,
                      button: true,
                      child: TactilePress(
                        scale: 0.988,
                        child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? EspectroElevation.cardShadows(p)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: selected ? p.accentSoft : p.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: selected ? p.accent : p.line,
                                width: selected ? 1.6 : 1.0,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _depth = depth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (selected)
                                    Container(height: 3, color: p.accent),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 13,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 72,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? p.surface
                                                : p.surfaceMuted,
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            border: Border.all(
                                              color: selected
                                                  ? p.accent.withValues(
                                                      alpha: 0.45,
                                                    )
                                                  : p.line,
                                            ),
                                          ),
                                          child: Text(
                                            '$n',
                                            style: text.headlineLarge?.copyWith(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 24,
                                              color: selected ? p.accent : p.ink,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    depth.label,
                                                    style: text.titleLarge
                                                        ?.copyWith(fontSize: 18),
                                                  ),
                                                  if (badgeText != null)
                                                    Tag(
                                                      label: badgeText,
                                                      background: selected
                                                          ? p.accent.withValues(
                                                              alpha: 0.16,
                                                            )
                                                          : p.surfaceMuted,
                                                      foreground: selected
                                                          ? p.accent
                                                          : p.inkSoft,
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                switch (depth) {
                                                  TestDepth.express =>
                                                    switch (widget.suite) {
                                                      TestSuite.espectroIntegrated =>
                                                        '12 eixos agora · Tríades (+18) depois',
                                                      TestSuite.bipolarAxes =>
                                                        '1 item por polo em cada eixo',
                                                      TestSuite.triads =>
                                                        '1 item por vértice em cada tríade',
                                                    },
                                                  TestDepth.quick =>
                                                    'Panorama inicial',
                                                  TestDepth.standard =>
                                                    'Mais equilíbrio',
                                                  TestDepth.deep =>
                                                    'Mais nuances',
                                                  TestDepth.exhaustive =>
                                                    'Banco completo',
                                                },
                                                style: text.bodySmall?.copyWith(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  for (
                                                    var b = 1;
                                                    b <= totalLevels;
                                                    b++
                                                  )
                                                    Expanded(
                                                      child: Container(
                                                        height: 3.5,
                                                        margin: EdgeInsets.only(
                                                          right: b < totalLevels
                                                              ? 4
                                                              : 0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                        999,
                                                                      ),
                                                              color: b <= level
                                                                  ? (selected
                                                                        ? p.accent
                                                                        : p.inkSoft
                                                                              .withValues(
                                                                                alpha: 0.55,
                                                                              ))
                                                                  : p.line,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? p.surface
                                                : p.canvas,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(color: p.line),
                                          ),
                                          child: Text(
                                            depth.estimatedDuration(n),
                                            style: text.labelSmall?.copyWith(
                                              fontSize: 10,
                                              color: p.accent,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    );
                  }(),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                Text(
                  'Pode pausar e continuar depois. Sem cronômetro.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Iniciar avaliação ($count perguntas)',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _start,
                ),
              ],
            );

            final Widget telemetryCard = Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.line),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.suite.title,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count afirmações',
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_depth.label} — ${_depth.estimatedDuration(count)} estimados',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: p.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: p.line)),
                    ),
                    child: Text(
                      widget.suite == TestSuite.espectroIntegrated &&
                              _depth == TestDepth.express
                          ? 'Avaliação Expressa: avalia os 12 eixos com ambos os polos (24 itens) para um resultado rápido e confiável. Na tela de resultado, você poderá completar as 6 Tríades (+18 perguntas) quando quiser.'
                          : 'Progresso adaptativo em blocos: você pode consultar o resultado preliminar após o marco inicial ou pausar a qualquer momento sem perder respostas.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: p.inkSoft,
                        height: 1.48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _showDimensionsSheet,
                    icon: const Icon(Icons.list_alt_rounded, size: 17),
                    label: const Text('Inspecionar dimensões'),
                  ),
                ],
              ),
            );

            return ListView(
              padding: EspectroLayout.pagePadding,
              children: [
                const EditorialHeading(
                  eyebrow: 'Etapa 02 / 02',
                  title: 'Quanto quer\naprofundar?',
                  description:
                      'Escolha o número de perguntas. Quanto maior a cobertura, mais nuances são observadas.',
                ),
                const SizedBox(height: 28),
                if (sideBySide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: depthList),
                      const SizedBox(width: 22),
                      Expanded(flex: 5, child: telemetryCard),
                    ],
                  )
                else
                  depthList,
              ],
            );
          },
        ),
      ),
    );
  }
}
