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
    const suites = [
      (
        TestSuite.espectroIntegrated,
        "Espectro integrado",
        "12 eixos + 6 tríades",
        "Um retrato político mais completo.",
      ),
      (
        TestSuite.bipolarAxes,
        "12 eixos bipolares",
        "Federalismo, economia, cultura...",
        "Tensões entre pares de posições.",
      ),
      (
        TestSuite.triads,
        "6 tríades políticas",
        "Três perspectivas por tema",
        "Além das escolhas binárias.",
      ),
    ];
    return EspectroScaffold(
      appViewModel: widget.appViewModel,
      selectedIndex: 1,
      isSectionRoot: true,
      appBar: AppBar(),
      body: ResponsiveContentFrame(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: EditorialHeading(
                eyebrow: "Descubra sua visão de mundo",
                title: "O que vamos\ninvestigar?",
                description: "Escolha uma modalidade. Você poderá explorar as outras depois.",
              ),
            ),
            const SizedBox(height: 36),
            for (var i = 0; i < suites.length; i++) ...[
              Semantics(
                selected: _selected == suites[i].$1,
                button: true,
                child: Material(
                  color: _selected == suites[i].$1
                      ? p.heroBackground
                      : p.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                    side: BorderSide(
                      color: _selected == suites[i].$1
                          ? p.heroBackground
                          : p.line,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => setState(() => _selected = suites[i].$1),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "0${i + 1}",
                                style: TextStyle(
                                  fontFamily: "IBMPlexMono",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selected == suites[i].$1
                                      ? const Color(0xFF6AE0CB)
                                      : p.accent,
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suites[i].$2,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        color: _selected == suites[i].$1
                                            ? Colors.white
                                            : p.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      suites[i].$3,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _selected == suites[i].$1
                                            ? const Color(0xFFB9CFD1)
                                            : p.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            suites[i].$4,
                            style: TextStyle(
                              fontSize: 13,
                              color: _selected == suites[i].$1
                                  ? const Color(0xFFB9CFD1)
                                  : p.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            Text(
              "Método público e resultados sempre explicados.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: "Continuar",
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
        ),
      ),
    );
  }
}
