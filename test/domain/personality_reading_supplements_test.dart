import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'completion audit agrees with usable coordinates across every catalog',
    () async {
      final audit = jsonDecode(
        File('docs/primary-coverage-audit-2026-11-05.json').readAsStringSync(),
      ) as Map;
      final catalog = StudyCatalog(await AppData.load());
      final axisIds =
          ((jsonDecode(File('assets/data/twelve_axes.json').readAsStringSync())
                      as Map)['axes']
                  as List)
              .map((a) => (a as Map)['id'] as String);
      final subjects = {
        for (final row in audit['subjects'] as List) (row as Map)['key']: row,
      };
      expect(subjects, hasLength(catalog.subjects.length));
      for (final subject in catalog.subjects) {
        final missing = [
          for (final id in axisIds)
            if (!subject.axes.containsKey(id)) 'axis:$id',
          for (var i = 0; i < 6; i++)
            if (!subject.triangles.containsKey(i)) 'triad:$i',
        ];
        expect(
          subjects[subject.key]!['missingNumericalDimensions'],
          unorderedEquals(missing),
          reason: subject.key,
        );
      }
      expect(
        audit['categories']['personality_core']['numericallyComplete'],
        129,
      );
      expect(
        audit['categories']['personality_core']['missingNumericalDimensions'],
        0,
      );
      expect(audit['categories']['personality_core']['documentedComplete'], 9);
      expect(
        audit['categories']['personality']['subjects'],
        greaterThanOrEqualTo(2000),
      );
      expect(
        audit['categories']['current']['missingNumericalDimensions'],
        greaterThanOrEqualTo(0),
      );
    },
  );

  test('individual supplements retain reviewed items without certifying old coordinates', () async {
    final input = jsonDecode(
      File('tool/curation/editorial_reconstructions.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final catalog = StudyCatalog(await AppData.load());
    const ids = {
      'platao',
      'aristoteles',
      'pierre_joseph_proudhon',
      'john_stuart_mill',
      'friedrich_engels',
      'emma_goldman',
      'errico_malatesta',
      'benjamin_tucker',
      'thomas_paine',
      'anton_pannekoek',
      'james_connolly',
      'james_guillaume',
      'alexander_berkman',
      'benjamin_constant',
      'jair_bolsonaro',
      'lysander_spooner',
      'hans_hermann_hoppe',
      'milton_friedman',
      'herbert_spencer',
      'karl_kautsky',
    };
    final rows = (input['profiles'] as List).cast<Map<String, dynamic>>().where(
      (r) => ids.contains((r['key'] as String).split(':').last),
    );
    expect(rows, hasLength(ids.length));
    for (final row in rows) {
      final subject = catalog.find(row['key'] as String)!;
      final basis = subject.entry!.editorialBasis!;
      expect(row['mode'], 'supplement');
      expect(basis.empiricallyValidated, false);
      for (final key in (row['dimensions'] as Map).keys) {
        final evidence = basis.dimensionEvidence[key]!;
        expect(evidence.isReconstructed, true, reason: '${row['key']} $key');
        expect(evidence.hasPrimarySupport, false);
        expect(
          evidence.reconstructedAnswers,
          hasLength((key as String).startsWith('axis:') ? 2 : 6),
        );
        expect(evidence.locator, isNotEmpty);
        expect(evidence.sourceUrls.every(basis.sourceUrls.contains), true);
      }
      final documentedCount = basis.dimensionEvidence.values
          .where((e) => e.hasDocumentedBasis)
          .length;
      if (row['key'] == 'personality:jair_bolsonaro') {
        expect(documentedCount, 18);
      } else {
        expect(
          documentedCount,
          lessThan(18),
          reason:
              'Completing numeric gaps must not certify inherited dimensions',
        );
      }
    }
  });

  test('readings preserve differences about culture, trade, religion and assistance', () async {
    final catalog = StudyCatalog(await AppData.load());
    StudySubject person(String id) => catalog.find('personality:$id')!;
    final engels = person('friedrich_engels');
    final marx = person('karl_marx');
    expect(engels.axes['imigracao'], lessThan(marx.axes['imigracao']!));
    expect(person('alexander_berkman').axes['comercio'], lessThan(0));
    expect(person('hans_hermann_hoppe').axes['religiao'], greaterThan(0));
    expect(person('milton_friedman').axes['religiao'], lessThan(0));
    final bolsonaro = person('jair_bolsonaro').entry!.editorialBasis!;
    final assistance = bolsonaro
        .dimensionEvidence['triad:5']!
        .reconstructedAnswers
        .singleWhere((a) => a.questionUid == 'tri:184');
    expect(
      assistance.answer,
      -2,
      reason: 'The 2018 minimum-income proposal does not reject all assistance',
    );
    expect(
      person('herbert_spencer').entry!.editorialBasis!.scope,
      contains('1851'),
    );
  });
}
