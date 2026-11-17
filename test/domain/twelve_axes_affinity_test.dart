import 'package:flutter_test/flutter_test.dart';
import 'package:politico/domain/models/twelve_axes_affinity.dart';

Map<String, double> _vector(double value) => {
  for (final String axis in twelveAxisIds) axis: value,
};

void main() {
  group('TwelveAxesAffinity', () {
    test('perfis idênticos alcançam 100 e cobertura completa', () {
      final affinity = TwelveAxesAffinity.between(_vector(0.4), _vector(0.4));
      expect(affinity, isNotNull);
      expect(affinity!.percent, closeTo(100, 0.01));
      expect(affinity.sharedAxes, 12);
      expect(affinity.coverage, 1);
      expect(affinity.maxDifference, 0);
    });

    test('perfis opostos ficam abaixo de perfis próximos', () {
      final near = TwelveAxesAffinity.between(_vector(0.2), _vector(0.25));
      final opposite = TwelveAxesAffinity.between(_vector(-0.8), _vector(0.8));
      expect(near, isNotNull);
      expect(opposite, isNotNull);
      expect(opposite!.percent, lessThan(near!.percent));
    });

    test('não preenche dimensões ausentes com centro', () {
      final affinity = TwelveAxesAffinity.between(
        {'estrutura': 0.5, 'economia': -0.5},
        {'estrutura': 0.5, 'economia': -0.5},
      );
      expect(affinity, isNull);
    });

    test('cobertura parcial é explícita e reduz o fator de confiabilidade', () {
      final user = <String, double>{
        for (var i = 0; i < 6; i++) twelveAxisIds[i]: 0.5,
      };
      final affinity = TwelveAxesAffinity.between(user, user);
      expect(affinity, isNotNull);
      expect(affinity!.sharedAxes, 6);
      expect(affinity.coverage, 0.5);
      expect(affinity.reliabilityFactor, closeTo(0.9, 0.0001));
      expect(affinity.percent, closeTo(affinity.rawPercent * 0.9, 0.01));
    });
  });
}
