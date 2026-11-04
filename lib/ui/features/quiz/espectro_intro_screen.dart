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
    super.key,
  });

  final AppViewModel appViewModel;
  final TestSuite suite;

  @override
  State<EspectroIntroScreen> createState() => _EspectroIntroScreenState();
}

class _EspectroIntroScreenState extends State<EspectroIntroScreen> {
  TestDepth _depth = TestDepth.quick;

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
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(19, 12, 19, 32),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: EditorialHeading(
                eyebrow: 'Etapa 02 / 02',
                title: 'Quanto quer\naprofundar?',
                description: 'Escolha o número de perguntas. Quanto maior a cobertura, mais nuances são observadas.',
              ),
            ),
            const SizedBox(height: 48),
            for (final depth in TestDepth.values) ...[
              Builder(
                builder: (_) {
                  final n = depth.expectedCount(
                    widget.suite,
                    totalAxesPool: axesPool,
                    totalTriadsPool: triadsPool,
                  );
                  final selected = _depth == depth;
                  return Semantics(
                    selected: selected,
                    button: true,
                    child: Material(
                      color: selected ? p.accentSoft : p.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: selected ? p.accent : p.line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => _depth = depth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 84,
                                child: Text(
                                  '$n',
                                  style: text.headlineLarge?.copyWith(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 27,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      depth.label,
                                      style: text.titleLarge?.copyWith(
                                        fontSize: 19,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      switch (depth) {
                                        TestDepth.quick => 'Panorama inicial',
                                        TestDepth.standard => 'Mais equilíbrio',
                                        TestDepth.deep => 'Mais nuances',
                                        TestDepth.exhaustive =>
                                          'Banco completo',
                                      },
                                      style: text.bodySmall?.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? p.accent.withValues(alpha: .10)
                                      : p.canvas,
                                  borderRadius: BorderRadius.circular(7),
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
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Text(
              'Pode pausar e continuar depois. Sem cronômetro.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Iniciar avaliação · $count perguntas',
              icon: Icons.arrow_forward_rounded,
              onPressed: _start,
            ),
          ],
        ),
      ),
    );
  }
}
