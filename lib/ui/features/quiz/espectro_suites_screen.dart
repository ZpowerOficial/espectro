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
        'Federalismo, economia, cultura...',
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
      appBar: AppBar(),
      body: ResponsiveContentFrame(
        maxWidth: 960,
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: isSelected
                              ? EspectroElevation.cardShadows(p)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Material(
                            color: isSelected ? p.accentSoft : p.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: isSelected ? p.accent : p.line,
                                width: isSelected ? 1.6 : 1.0,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _selected = item.$1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (isSelected)
                                    const SpectrumGradientRule(
                                      height: 3.5,
                                      radius: 0,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? p.accent
                                                    : p.surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '0${i + 1}',
                                                style: TextStyle(
                                                  fontFamily: 'IBMPlexMono',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? (p.isDark
                                                            ? const Color(0xFF0A0D14)
                                                            : Colors.white)
                                                      : p.inkSoft,
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
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        item.$2,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: p.ink,
                                                        ),
                                                      ),
                                                      if (item.$5 != null)
                                                        Tag(
                                                          label: item.$5!,
                                                          background: p.accent
                                                              .withValues(
                                                                alpha: 0.16,
                                                              ),
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
                                                  : Icons
                                                      .radio_button_unchecked_rounded,
                                              size: 22,
                                              color:
                                                  isSelected ? p.accent : p.muted,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                    fontFamily: 'IBMPlexMono',
                                                    fontSize: 10.5,
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
                  label: 'Continuar',
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
                color: p.heroBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: EspectroElevation.cardShadows(p),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpectrumGradientRule(height: 3.5, radius: 0),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RESUMO DA MODALIDADE',
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Color(0xFF9FB8E6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${activeSpec.$2} (${activeSpec.$6.take(2).join(' · ')})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          activeSpec.$7,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFFD2DBE8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final badge in activeSpec.$6)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                                color: Color(0xFF9FB8E6),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tudo calculado offline neste dispositivo, com intervalo de confiança explícito e zero pontuação oculta.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: EditorialHeading(
                    eyebrow: 'Descubra sua visão de mundo',
                    title: 'O que vamos\ninvestigar?',
                    description:
                        'Escolha uma modalidade. Você poderá explorar as outras depois.',
                  ),
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
    );
  }
}
