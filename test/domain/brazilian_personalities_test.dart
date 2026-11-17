import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_relations.dart';
import 'package:politico/domain/models/study_sources.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late StudyCatalog catalog;
  const ids = [
    'raphael_lima',
    'gilson_marques',
    'peter_turguniev',
    'jones_manoel',
  ];
  setUpAll(() async {
    data = await AppData.load();
    catalog = StudyCatalog(data);
  });
  test('the four requested profiles carry 60 auditable answers and all 18 dimensions', () {
    for (final id in ids) {
      final subject = catalog.find('personality:$id')!;
      expect(subject.axes, hasLength(12));
      expect(subject.triangles, hasLength(6));
      expect(sourcesForStudy(subject.key), isNotEmpty);
      expect(relationsForStudy(subject.key), isNotEmpty);
      final basis = subject.entry!.editorialBasis!;
      expect(basis.empiricallyValidated, false);
      expect(basis.dimensionEvidence, hasLength(18));
      final answers = basis.dimensionEvidence.values
          .expand((e) => e.reconstructedAnswers)
          .toList();
      expect(answers, hasLength(60));
      expect(answers.map((a) => a.questionUid).toSet(), hasLength(60));
      for (final e in basis.dimensionEvidence.entries) {
        expect(e.value.status, 'editorial_reconstruction');
        expect(e.value.sourceUrls, isNotEmpty);
        for (final a in e.value.reconstructedAnswers) {
          final question = data.questionByUid[a.questionUid]!;
          expect(question.text, a.statement);
          final dimension = a.questionUid.startsWith('axis:')
              ? 'axis:${question.axisQuestion!.axisId}'
              : 'triad:${question.sixQuestion!.category}';
          expect(dimension, e.key);
          expect(a.rationale, isNotEmpty);
        }
      }
    }
  });
  test('aliases and spectrum colors resolve the actual requested people', () {
    for (final pair in [
      ('Raphael Lima', 'raphael_lima'),
      ('Ideias Radicais', 'raphael_lima'),
      ('Ancapsu', 'peter_turguniev'),
      ('Ancap.su', 'peter_turguniev'),
      ('Gilson Marques', 'gilson_marques'),
      ('Jones Manoel', 'jones_manoel'),
    ]) {
      expect(
        catalog.search(pair.$1).map((s) => s.key),
        contains('personality:${pair.$2}'),
      );
    }
    expect(
      spectrumOf(catalog.find('personality:jones_manoel')!)!.id,
      'radical_left',
    );
    for (final id in ids.where((id) => id != 'jones_manoel')) {
      expect(spectrumOf(catalog.find('personality:$id')!)!.id, 'libertarian');
    }
  });
  test('sources preserve differences instead of assigning one vector per political family', () {
    final raphael = catalog.find('personality:raphael_lima')!;
    final gilson = catalog.find('personality:gilson_marques')!;
    final peter = catalog.find('personality:peter_turguniev')!;
    final jones = catalog.find('personality:jones_manoel')!;
    expect(raphael.axes['religiao'], greaterThan(peter.axes['religiao']!));
    expect(gilson.axes['moral'], greaterThan(0));
    expect(jones.axes['moral'], lessThan(0));
    expect(jones.axes['diplomacia'], lessThan(0));
    expect(
      jones
          .entry!
          .editorialBasis!
          .dimensionEvidence['axis:diplomacia']!
          .locator,
      contains('38'),
    );
    expect(peter.entry!.editorialBasis!.scope, contains('colaboradores'));
    expect(
      gilson.entry!.editorialBasis!.limitations.join(' '),
      contains('NOVO'),
    );

    // Libertarian Brazilian figures must have nuanced, realistic, distinct scores:
    // 1. All three are pro-liberty (poder > 0), not authoritarian law-and-order.
    expect(raphael.displayAxes['poder'], greaterThan(0.5));
    expect(peter.displayAxes['poder'], greaterThan(0.5));
    expect(gilson.displayAxes['poder'], greaterThan(0.5));

    // 2. Clear differences across key axes (no cloned/identical numbers):
    expect(raphael.displayAxes['estrutura'], isNot(equals(peter.displayAxes['estrutura'])));
    expect(raphael.displayAxes['estrutura'], isNot(equals(gilson.displayAxes['estrutura'])));
    expect(raphael.displayAxes['representacao'], isNot(equals(peter.displayAxes['representacao'])));
    expect(raphael.displayAxes['moral'], isNot(equals(gilson.displayAxes['moral'])));
    expect(peter.displayAxes['moral'], isNot(equals(gilson.displayAxes['moral'])));
  });
}
