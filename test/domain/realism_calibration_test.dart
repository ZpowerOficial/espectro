import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/engine/realism_calibration.dart';
import 'package:politico/domain/models/study_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StudyCatalog catalog;

  setUpAll(() async {
    final data = await AppData.load();
    catalog = StudyCatalog(data);
  });

  group('RealismCalibration unit tests', () {
    test('monotonicity and zero preservation', () {
      expect(RealismCalibration.calibrateAxis(0.0), 0.0);
      expect(RealismCalibration.calibrateAxis(0.2), greaterThan(0.0));
      expect(RealismCalibration.calibrateAxis(0.5), greaterThan(RealismCalibration.calibrateAxis(0.2)));
      expect(RealismCalibration.calibrateAxis(0.8), greaterThan(RealismCalibration.calibrateAxis(0.5)));
      expect(RealismCalibration.calibrateAxis(1.0), greaterThan(RealismCalibration.calibrateAxis(0.8)));

      // Symmetry
      expect(
        RealismCalibration.calibrateAxis(-0.75),
        -RealismCalibration.calibrateAxis(0.75),
      );
    });

    test('anti-ceiling effect: no calibrated axis exceeds strict bound 0.82 (display <= 91%)', () {
      for (final s in catalog.subjects.where((s) => s.kind == 'current')) {
        for (final entry in s.displayAxes.entries) {
          final val = entry.value;
          expect(
            val.abs(),
            lessThanOrEqualTo(0.82),
            reason: '${s.key} axis ${entry.key} exceeds 0.82 ($val)',
          );
        }
      }
    });

    test('tempered triads: no single vertex exceeds 0.85', () {
      for (final s in catalog.subjects.where((s) => s.kind == 'current')) {
        for (final entry in s.displayTriangles.entries) {
          final comp = entry.value;
          for (var i = 0; i < comp.length; i++) {
            expect(
              comp[i],
              lessThanOrEqualTo(0.85),
              reason: '${s.key} triad ${entry.key} vertex $i exceeds 0.85 (${comp[i]})',
            );
          }
          final sum = comp.fold<double>(0.0, (a, b) => a + b);
          expect(sum, closeTo(1.0, 0.005));
        }
      }
    });

    test('fluid percentages distribution: produces varied non-100% values like 73%, 81%, 86%', () {
      final percentages = <int>{};
      for (final s in catalog.subjects.where((s) => s.kind == 'current').take(80)) {
        for (final val in s.displayAxes.values) {
          final norm = ((val + 1.0) / 2.0).clamp(0.0, 1.0);
          final leansLeft = norm <= 0.5;
          final pct = ((leansLeft ? (1.0 - norm) : norm) * 100).round();
          percentages.add(pct);
        }
      }
      expect(percentages, isNotEmpty);
      expect(percentages.contains(100), isFalse, reason: '100% should be absent due to calibration');
      // Contains typical 12axes-like fluid values
      final hasFluidValues = percentages.any((p) => p >= 70 && p <= 89);
      expect(hasFluidValues, isTrue);
    });
  });
}
