import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_editorial_basis.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StudyCatalog catalog;
  setUpAll(() async => catalog = StudyCatalog(await AppData.load()));
  test('editorial taxonomy separates fascist group and Brazilian right consistently', () {
    for (final id in [
      'fascismo_historico',
      'nazismo',
      'neonazismo',
      'neofascismo',
      'falangismo_nacional_sindicalismo',
      'integralismo_brasileiro',
    ]) {
      final s = catalog.find('current:$id')!;
      expect(s.spectrumId, 'third_position');
      expect(spectrumOf(s)!.id, 'third_position');
    }
    expect(
      spectrumOf(catalog.find('personality:jair_bolsonaro')!)!.id,
      'right',
    );
    expect(spectrumFor('personality:jair_bolsonaro')!.id, 'right');
    expect(spectrumFor('current:fascismo_historico')!.id, 'third_position');
  });
  test('each reviewed profile declares separate source state for all 18 dimensions', () {
    for (final key in [
      'current:fascismo_historico',
      'current:nazismo',
      'personality:jair_bolsonaro',
    ]) {
      final s = catalog.find(key)!;
      final basis = (s.current?.editorialBasis ?? s.entry?.editorialBasis)!;
      expect(basis.dimensionEvidence, hasLength(18));
      expect(basis.nativeMatchingEligible, s.current != null);
      expect(basis.empiricallyValidated, false);
      for (final e in basis.dimensionEvidence.values) {
        expect(e.rationale, isNotEmpty);
        expect(e.locator, isNotEmpty);
        if (e.hasPrimarySupport) expect(e.sourceUrls, isNotEmpty);
        for (final url in e.sourceUrls) {
          expect(basis.sourceUrls, contains(url));
          expect(basis.sourceMetadata[url], isNotEmpty);
        }
      }
    }
  });
  test('source conflicts and unreviewed dimensions remain absent, not fake centers', () {
    final nazi = catalog.find('current:nazismo')!;
    expect(nazi.axes.containsKey('economia'), true);
    expect(nazi.axes.containsKey('tecnologia'), true);
    expect(
      nazi.current!.editorialBasis!.dimensionEvidence['axis:economia']!
          .isReconstructed,
      true,
    );
    expect(nazi.triangles.containsKey(0), true);
    final fascism = catalog.find('current:fascismo_historico')!;
    expect(fascism.current!.axes['intervencao']!.note, contains('imperial'));
    expect(fascism.current!.triangles[4]!.note, contains('autoridade'));
    expect(fascism.triangles.containsKey(3), true);
    final bolsonaro = catalog.find('personality:jair_bolsonaro')!;
    expect(bolsonaro.axes.containsKey('imigracao'), true);
    expect(bolsonaro.axes.containsKey('poder'), true);
    expect(
      bolsonaro
          .entry!
          .editorialBasis!
          .dimensionEvidence['axis:imigracao']!
          .isReconstructed,
      true,
    );
    expect(
      bolsonaro
          .entry!
          .editorialBasis!
          .dimensionEvidence['axis:poder']!
          .isReconstructed,
      true,
    );
    expect(bolsonaro.triangles.keys, unorderedEquals([0, 1, 2, 3, 4, 5]));
    expect(bolsonaro.entry!.editorialBasis!.scope, contains('2018'));
    expect(bolsonaro.entry!.editorialBasis!.scope, contains('2019'));
  });
  test('primary support cannot reference an undeclared source', () {
    expect(
      () => StudyEditorialBasis.parse({
        'reviewedAt': '2026-11-05',
        'scope': 'test',
        'coordinateMethod': 'test',
        'limitations': ['test'],
        'sourceUrls': ['https://example.test/a'],
        'empiricallyValidated': false,
        'dimensionEvidence': {
          'axis:poder': {
            'status': 'primary_supported',
            'locator': 'section 1',
            'rationale': 'test',
            'sourceUrls': ['https://example.test/b'],
          },
        },
      }, 'basis'),
      throwsFormatException,
    );
  });
  test('Nazism moral and diplomacy use the enlarged 1934 and 1937 corpus', () {
    final nazi = catalog.find('current:nazismo')!;
    final basis = nazi.current!.editorialBasis!;
    expect(nazi.axes['moral'], .8);
    expect(nazi.axes['diplomacia'], -.9);
    expect(nazi.axes['comercio'], -.65);
    expect(basis.scope, contains('1920–1937'));
    expect(basis.dimensionEvidence['axis:moral']!.hasPrimarySupport, true);
    expect(basis.dimensionEvidence['axis:diplomacia']!.hasPrimarySupport, true);
    expect(
      basis.dimensionEvidence['axis:moral']!.sourceUrls.single,
      contains('document-1557'),
    );
    expect(
      basis.dimensionEvidence['axis:diplomacia']!.sourceUrls.single,
      contains('document-1540'),
    );
    // Culture composition is reconstructed explicitly with caveats, not treated as direct measurement.
    expect(basis.dimensionEvidence['triad:2']!.isReconstructed, true);
    expect(nazi.triangles.containsKey(2), true);
  });
  test(
    'primary sources span distinct traditions and never imply measured vectors',
    () {
      for (final key in [
        'personality:karl_marx',
        'personality:murray_rothbard',
        'personality:john_stuart_mill',
        'personality:piotr_kropotkin',
        'personality:edmund_burke',
        'personality:margaret_thatcher',
        'party:black_panther_party',
        'country:japao_pos_guerra',
      ]) {
        final s = catalog.find(key)!;
        final basis = (s.current?.editorialBasis ?? s.entry?.editorialBasis)!;
        expect(
          basis.dimensionEvidence.values.any((e) => e.hasDocumentedBasis),
          true,
          reason: key,
        );
        expect(basis.empiricallyValidated, false);
        expect(basis.nativeMatchingEligible, false);
        for (final e in basis.dimensionEvidence.values) {
          for (final url in e.sourceUrls) {
            expect(basis.sourceUrls, contains(url));
            expect(basis.sourceMetadata[url], isNotEmpty);
          }
        }
      }
    },
  );
  test(
    'bibliography inventory does not promote pending research to evidence',
    () {
      final gaullist = catalog.find('country:franca_gaullista')!;
      final basis = gaullist.entry!.editorialBasis!;
      expect(
        basis.sourceUrls.any((url) => url.contains('conseil-constitutionnel')),
        true,
      );
      expect(basis.dimensionEvidence['axis:estrutura'], isNull);
      expect(
        basis.sourceMetadata.values.join(),
        contains('ainda não foi conferido'),
      );
      for (final subject in catalog.subjects) {
        expect(
          subject.current?.editorialBasis ?? subject.entry?.editorialBasis,
          isNotNull,
          reason: subject.key,
        );
      }
    },
  );
}
