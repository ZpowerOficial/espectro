import 'package:flutter/material.dart';

import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import 'espectro_intro_screen.dart';

class EspectroSuitesScreen extends StatefulWidget {
  const EspectroSuitesScreen({required this.appViewModel, super.key});
  final AppViewModel appViewModel;
  @override
  State<EspectroSuitesScreen> createState() => _EspectroSuitesScreenState();
}

class _EspectroSuitesScreenState extends State<EspectroSuitesScreen> {
  TestSuite _selected = TestSuite.espectroIntegrated;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final suites = [
      (
        TestSuite.espectroIntegrated,
        'Espectro integrado',
        '12 eixos + 6 tríades',
        'Um retrato político mais completo.',
        'Recomendado',
        ['12 eixos', '6 tríades', 'Nolan', '289 correntes'],
        'Cruza os 12 eixos bipolares com as 6 tríades ternárias na mesma escala, calculando projeção de Nolan e proximidade com o Atlas completo.',
      ),
      (
        TestSuite.bipolarAxes,
        '12 eixos bipolares',
        'Federalismo, economia, cultura…',
        'Tensões entre pares de posições.',
        null,
        ['12 eixos', 'Nolan', 'Mapa 12x12'],
        'Foca exclusivamente nos 12 contínuos bipolares (economia, poder, representação, cultura e geopolítica), detectando tensões internas entre polos.',
      ),
      (
        TestSuite.triads,
        '6 tríades políticas',
        'Três perspectivas por tema',
        'Além das escolhas binárias.',
        null,
        ['6 tríades', 'Baricêntrico', 'Intensidade real'],
        'Avalia triângulos conceituais independentes sem forçar soma zero artificial: mede tanto sua proporção quanto o apoio absoluto em cada vértice.',
      ),
    ];
    final activeSpec = suites.firstWhere((s) => s.$1 == _selected);

    return EspectroScaffold(
      appViewModel: widget.appViewModel,
      selectedIndex: 1,
      isSectionRoot: true,
      body: SafeArea(
        bottom: false,
        child: ResponsiveContentFrame(
          maxWidth: EspectroLayout.workspaceMaxWidth,
          child: LayoutBuilder(
          builder: (context, constraints) {
            final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
            final bool sideBySide = constraints.maxWidth >= 820 && scale <= 1.35;

            final Widget selectorColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < suites.length; i++) ...[
                  () {
                    final item = suites[i];
                    final bool isSelected = _selected == item.$1;
                    return Semantics(
                      selected: isSelected,
                      button: true,
                      child: TactilePress(
                        scale: 0.988,
                        child: Material(
                        color: isSelected ? p.accentSoft : p.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? p.accent : p.line,
                            width: isSelected ? 1.6 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => setState(() => _selected = item.$1),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        '0${i + 1}',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFeatures: const <FontFeature>[
                                            FontFeature.tabularFigures(),
                                          ],
                                          color: isSelected
                                              ? p.accent
                                              : p.muted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                                                item.$2,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: p.ink,
                                                ),
                                              ),
                                              if (item.$5 != null)
                                                Tag(
                                                  label: item.$5!,
                                                  background: p.accent
                                                      .withValues(alpha: 0.14),
                                                  foreground: p.accent,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.$3,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: p.inkSoft,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 22,
                                      color: isSelected ? p.accent : p.muted,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.$4,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: p.inkSoft,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final chip in item.$6)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? p.surface
                                              : p.surfaceMuted,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: p.line,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          chip,
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexSans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: p.inkSoft,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    );
                  }(),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                Text(
                  'Método público e resultados sempre explicados.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Escolher profundidade',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EspectroIntroScreen(
                        appViewModel: widget.appViewModel,
                        suite: _selected,
                      ),
                    ),
                  ),
                ),
              ],
            );

            final Widget briefCard = Container(
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
                    'Escopo da modalidade',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activeSpec.$2} (${activeSpec.$3})',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeSpec.$7,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: p.inkSoft,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: p.line)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 17,
                          color: p.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tudo calculado offline neste dispositivo, com intervalo de confiança explícito e zero pontuação oculta.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: p.inkSoft,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return ListView(
              padding: EspectroLayout.pagePadding,
              children: [
                const EditorialHeading(
                  eyebrow: 'Descubra sua visão de mundo',
                  title: 'O que vamos\ninvestigar?',
                  description:
                      'Escolha uma modalidade. Você poderá explorar as outras depois.',
                ),
                const SizedBox(height: 28),
                if (sideBySide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: selectorColumn),
                      const SizedBox(width: 22),
                      Expanded(flex: 5, child: briefCard),
                    ],
                  )
                else
                  selectorColumn,
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}
