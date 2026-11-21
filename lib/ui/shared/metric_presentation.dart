import 'package:flutter/material.dart';

import '../../domain/models/atlas_models.dart';
import '../../theme.dart';

/// Utilitários e definições canônicas de apresentação das métricas estatísticas
/// do Espectro (P1.1 e P2.4).
///
/// Nenhuma função aqui altera cálculos ou escalas matemáticas: apenas padroniza
/// o arredondamento em pt-BR (1 casa decimal com vírgula) e deixa inequívoco o
/// referente de cada percentual exibido na interface.
abstract final class MetricPresentation {
  /// Formata um percentual contínuo em `[0, 100]` de maneira uniforme no app
  /// inteiro (ex.: `49,0%`, `62,0%`, `70,0%`).
  static String formatPercent(num? value, {int decimals = 1}) {
    if (value == null || !value.isFinite) return '0,0%';
    final String fixed = value.toStringAsFixed(decimals).replaceAll('.', ',');
    return '$fixed%';
  }

  /// Formata um valor numérico sem o símbolo `%`, mantendo vírgula decimal.
  static String formatScore(num? value, {int decimals = 1}) {
    if (value == null || !value.isFinite) return '0,0';
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  static const String currentConvergenceTooltip =
      'Convergência com a corrente: mede sua aderência ao perfil doutrinário '
      'da corrente pela fórmula 100 × exp(-D² / 2), considerando eixos, tríades '
      'e margem de erro das respostas. Escala distinta da proximidade no Atlas.';

  static const String atlasProximityTooltip =
      'Proximidade no Atlas: compara seu perfil com personalidades, países, '
      'partidos, épocas ou obras usando distância quadrática limitada (effZ²) '
      'e tolerâncias históricas próprias. Por isso não equivale ao percentual de '
      'convergência com correntes.';

  static const String exploratorySimilarityTooltip =
      'Proximidade exploratória entre perfis: calculada por 100 × (1 − RMSD) '
      'sobre as dimensões em comum, com peso igual e sem margem de erro pessoal.';

  static String atlasReferent(AtlasKind kind) => switch (kind) {
    AtlasKind.personality => 'proximidade com a personalidade',
    AtlasKind.country => 'proximidade com o país',
    AtlasKind.party => 'proximidade com o partido',
    AtlasKind.history => 'proximidade com o período',
    AtlasKind.book => 'proximidade com a obra',
  };

  static String atlasShortReferent(AtlasKind kind) => switch (kind) {
    AtlasKind.personality => 'prox. personalidade',
    AtlasKind.country => 'prox. país',
    AtlasKind.party => 'prox. partido',
    AtlasKind.history => 'prox. período',
    AtlasKind.book => 'prox. obra',
  };
}

/// Ícone discreto e acessível com explicação contextual da métrica (suporta
/// toque no mobile via `TooltipTriggerMode.tap` e foco no teclado).
class MetricInfoBadge extends StatelessWidget {
  const MetricInfoBadge({
    required this.tooltip,
    required this.semanticLabel,
    this.color,
    this.size = 14,
    super.key,
  });

  final String tooltip;
  final String semanticLabel;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      child: Semantics(
        button: true,
        label: semanticLabel,
        hint: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.info_outline_rounded,
            size: size,
            color: color ?? p.muted,
          ),
        ),
      ),
    );
  }
}
