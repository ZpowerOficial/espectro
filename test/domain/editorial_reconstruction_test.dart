import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_editorial_basis.dart';

import '../../tool/score_editorial_reconstructions.dart' as generator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const input = 'tool/curation/editorial_reconstructions.json';
  const saved = 'tool/curation/editorial_reconstruction_scores.json';
  const update = bool.fromEnvironment('UPDATE_EDITORIAL_RECONSTRUCTIONS');
  test('editorial coordinates reproduce the real scoring engine without session statistics', () {
    final dir = Directory.systemTemp.createTempSync('espectro-editorial-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final output = '${dir.path}/scores.json';
    generator.main([input, output]);
    final contents = File(output).readAsStringSync();
    if (update) {
      File(saved).writeAsStringSync(contents);
    }
    expect(jsonDecode(contents), jsonDecode(File(saved).readAsStringSync()));
    expect(contents, isNot(contains('standardError')));
    expect(contents, isNot(contains('answeredCount')));
  });
  test(
    'completed authors retain answers, scope and caveats for all dimensions',
    () async {
      if (update) return;
      final catalog = StudyCatalog(await AppData.load());
      for (final id in ['murray_rothbard', 'karl_marx', 'ludwig_von_mises']) {
        final subject = catalog.find('personality:$id')!;
        expect(subject.axes, hasLength(12));
        expect(subject.triangles, hasLength(6));
        final basis = subject.entry!.editorialBasis!;
        expect(basis.empiricallyValidated, false);
        expect(basis.dimensionEvidence, hasLength(18));
        expect(
          basis.dimensionEvidence.values.expand((e) => e.reconstructedAnswers),
          hasLength(60),
        );
        for (final e in basis.dimensionEvidence.values) {
          expect(e.status, 'editorial_reconstruction');
          expect(e.hasPrimarySupport, false);
          expect(e.hasDocumentedBasis, true);
          expect(e.sourceUrls, isNotEmpty);
          for (final a in e.reconstructedAnswers) {
            expect(a.rationale, isNotEmpty);
            expect(a.statement, isNotEmpty);
          }
        }
        expect(subject.entry!.compositionNotes[4], contains('Minarquia'));
      }
    },
  );
  test('editorial answers reject invalid values and empty reconstructions', () {
    Map<String, Object?> evidence(Object answer) => {
      'status': 'editorial_reconstruction',
      'locator': 'chapter 1',
      'rationale': 'editorial translation',
      'sourceUrls': ['https://example.test/primary'],
      'reconstructedAnswers': [
        {
          'questionUid': 'axis:moral_01',
          'statement': 'Anchor',
          'answer': answer,
          'rationale': 'A qualified interpretation',
        },
      ],
    };
    expect(
      () => StudyDimensionEvidence.parse(evidence(3), 'e'),
      throwsFormatException,
    );
    expect(
      () => StudyDimensionEvidence.parse({
        ...evidence(1),
        'reconstructedAnswers': <Object?>[],
      }, 'e'),
      throwsFormatException,
    );
    expect(
      () => StudyDimensionEvidence.parse({
        ...evidence(1),
        'status': 'primary_supported',
      }, 'e'),
      throwsFormatException,
    );
  });
  test('targeted supplements preserve other dimensions and never insert unobserved centers', () async {
    if (update) return;
    final catalog = StudyCatalog(await AppData.load());
    for (final id in [
      'anarcocapitalismo',
      'comunismo',
      'socialismo_marxista',
      'liberalismo_classico',
    ]) {
      final subject = catalog.find('current:$id')!;
      expect(subject.axes, hasLength(12));
      expect(subject.triangles, hasLength(6));
    }
    final scores = jsonDecode(File(saved).readAsStringSync()) as Map;
    expect((scores['current:liberalismo_classico'] as Map)['axes'], isEmpty);
    expect(
      ((scores['current:liberalismo_classico'] as Map)['triangles'] as Map)
          .keys,
      ['1'],
    );
    final sa = catalog.find('country:africa_do_sul_mandela')!;
    expect(sa.axes, hasLength(12));
    expect(sa.triangles, hasLength(6));
    expect(
      sa
          .entry!
          .editorialBasis!
          .dimensionEvidence['triad:5']!
          .reconstructedAnswers,
      hasLength(6),
    );
  });
  test(
    'report editorial affinities without prescribing the first result',
    () async {
      if (update) return;
      final catalog = StudyCatalog(await AppData.load());
      final report = <String, Object?>{};
      for (final id in ['murray_rothbard', 'karl_marx', 'ludwig_von_mises']) {
        final s = catalog.find('personality:$id')!;
        final matches = catalog
            .related(s, limit: catalog.subjects.length)
            .where((m) => m.subject.current != null)
            .take(10);
        report[id] = [
          for (final m in matches)
            {'current': m.subject.key, 'similarity': m.similarity},
        ];
      }
      final dir = Directory('build/artifacts/editorial-reconstruction')
        ..createSync(recursive: true);
      File('${dir.path}/affinities.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(report)}\n',
      );
      final rothbard = catalog.find('personality:murray_rothbard')!;
      final marx = catalog.find('personality:karl_marx')!;
      expect(
        catalog
            .compare(rothbard, catalog.find('current:anarcocapitalismo')!)!
            .similarity,
        greaterThan(
          catalog
              .compare(rothbard, catalog.find('current:marxismo_leninismo')!)!
              .similarity,
        ),
      );
      expect(
        catalog
            .compare(marx, catalog.find('current:socialismo_marxista')!)!
            .similarity,
        greaterThan(
          catalog
              .compare(marx, catalog.find('current:anarcocapitalismo')!)!
              .similarity,
        ),
      );
    },
  );
}
