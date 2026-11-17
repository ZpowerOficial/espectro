import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/atlas_models.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/atlas/atlas_explorer_screen.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late StudyCatalog catalog;

  setUpAll(() async {
    data = await AppData.load();
    catalog = StudyCatalog(data);
  });

  test('catálogo supera 2.000 personalidades únicas cobrindo os 3 níveis e 8 espectros', () {
    final personalities = data.atlas.personalities;
    expect(personalities.length, greaterThanOrEqualTo(2000));
    expect(
      personalities.map((p) => p.id).toSet().length,
      personalities.length,
    );

    final tier1 = personalities
        .where(
          (p) => p.editorialBasis?.evidenceTier == 'tier1_editorial_reconstruction',
        )
        .toList();
    final tier2 = personalities
        .where((p) => p.editorialBasis?.evidenceTier == 'tier2_institutional_record')
        .toList();
    final tier3 = personalities
        .where((p) => p.editorialBasis?.evidenceTier == 'tier3_preliminary_curation')
        .toList();

    expect(tier1, hasLength(68));
    expect(tier2.length, greaterThanOrEqualTo(1300));
    expect(tier3.length, greaterThanOrEqualTo(600));
    expect(tier1.length + tier2.length + tier3.length, personalities.length);

    final personalitySubjects = catalog.subjects
        .where((s) => s.kind == 'personality')
        .toList();
    expect(personalitySubjects, hasLength(personalities.length));
    final seenSpectra = <String>{};
    for (final s in personalitySubjects) {
      final spec = spectrumOf(s);
      expect(spec, isNotNull, reason: 'Espectro ausente em ${s.key}');
      seenSpectra.add(spec!.id);
    }
    expect(seenSpectra, containsAll(studySpectra.map((s) => s.id)));
  });

  test('Catálogo base mantém 129 personalidades 18/18 e Nível 1 exige evidência primária/reconstruída', () {
    final core129 = data.atlas.personalities
        .where((p) => p.editorialBasis?.dossierShard == null)
        .toList();
    expect(core129, hasLength(129));
    for (final entry in core129) {
      expect(entry.axes, hasLength(12), reason: entry.id);
      expect(entry.triangles, hasLength(6), reason: entry.id);
    }

    final tier1 = data.atlas.personalities
        .where(
          (p) => p.editorialBasis?.evidenceTier == 'tier1_editorial_reconstruction',
        )
        .toList();
    expect(tier1, hasLength(68));
    for (final entry in tier1) {
      final basis = entry.editorialBasis!;
      expect(basis.empiricallyValidated, isFalse);
      expect(basis.dossierShard, isNull);
      expect(basis.sourceUrls, isNotEmpty, reason: entry.id);
      expect(
        basis.dimensionEvidence.values.any(
          (e) => e.hasPrimarySupport || e.isReconstructed,
        ),
        isTrue,
        reason: entry.id,
      );
    }
  });

  test('Nível 2 carrega votações nominais sob demanda por shard sem preencher lacunas com 0', () async {
    final tier2 = data.atlas.personalities
        .where((p) => p.editorialBasis?.evidenceTier == 'tier2_institutional_record')
        .toList();
    expect(tier2.length, greaterThanOrEqualTo(1300));

    for (final entry in tier2) {
      final basis = entry.editorialBasis!;
      expect(basis.empiricallyValidated, isFalse);
      expect(basis.nativeMatchingEligible, isFalse);
      expect(basis.dossierShard, matches(RegExp(r'^shard_[0-9]{2}$')));
      expect(basis.dimensionEvidence, isEmpty);
      expect(entry.axes, hasLength(12), reason: entry.id);
      expect(entry.triangles, hasLength(6), reason: entry.id);
      expect(
        basis.sourceUrls.every(
          (u) =>
              u.startsWith('https://www.camara.leg.br/') ||
              u.startsWith('https://dadosabertos.camara.leg.br/') ||
              u.startsWith('https://www25.senado.leg.br/') ||
              u.startsWith('https://legis.senado.leg.br/'),
        ),
        isTrue,
        reason: entry.id,
      );
    }

    final sample = tier2.first;
    final loaded = await data.loadDossierEvidence(
      'personality:${sample.id}',
      shard: sample.editorialBasis!.dossierShard!,
      allowedSourceUrls: sample.editorialBasis!.sourceUrls,
    );
    expect(
      loaded,
      hasLength(sample.axes.length + sample.triangles.length),
    );
    expect(loaded.values.every((e) => e.isInstitutionalVote), isTrue);
    expect(loaded.values.every((e) => e.hasDocumentedBasis), isTrue);
  });

  test('Nível 3 estendido preserva vetores distintos não-clonados e status unreviewed no shard', () async {
    final tier3Extended = data.atlas.personalities
        .where(
          (p) =>
              p.editorialBasis?.evidenceTier == 'tier3_preliminary_curation' &&
              p.editorialBasis?.dossierShard != null,
        )
        .toList();
    expect(tier3Extended.length, greaterThanOrEqualTo(500));

    final vectorSignatures = <String>{};
    for (final entry in tier3Extended) {
      expect(entry.axes, hasLength(12), reason: entry.id);
      expect(entry.triangles, hasLength(6), reason: entry.id);
      final sig = entry.axes.entries
          .map((e) => '${e.key}:${e.value.toStringAsFixed(4)}')
          .join('|');
      expect(
        vectorSignatures.add(sig),
        isTrue,
        reason: 'Vetor clonado em ${entry.id}',
      );
      final basis = entry.editorialBasis!;
      expect(basis.empiricallyValidated, isFalse);
      expect(basis.nativeMatchingEligible, isFalse);
      expect(basis.dossierShard, matches(RegExp(r'^shard_[0-9]{2}$')));
    }

    final sample = tier3Extended.first;
    final loaded = await data.loadDossierEvidence(
      'personality:${sample.id}',
      shard: sample.editorialBasis!.dossierShard!,
      allowedSourceUrls: sample.editorialBasis!.sourceUrls,
    );
    expect(loaded, hasLength(18));
    expect(loaded.values.every((e) => e.status == 'unreviewed'), isTrue);
  });

  testWidgets('StudyProfileScreen e AtlasExplorerScreen exibem selos e filtros de nível com carregamento sob demanda', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final vm = AppViewModel(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
    );
    await vm.initialize();
    addTearDown(vm.dispose);

    final AtlasEntry sampleTier2 = data.atlas.personalities.firstWhere(
      (p) =>
          p.editorialBasis?.evidenceTier == 'tier2_institutional_record' &&
          p.axes.containsKey('estrutura'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.dark),
        home: StudyProfileScreen(
          appViewModel: vm,
          subjectKey: 'personality:${sampleTier2.id}',
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nível 2 · Votações nominais / registro oficial'),
      findsWidgets,
    );
    await tester.tap(find.text('Dimensões'));
    await tester.pumpAndSettle();
    expect(
      find.text('Votações nominais e registro oficial'),
      findsWidgets,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.dark),
        home: Scaffold(body: AtlasExplorerScreen(appViewModel: vm)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Personalidade (').first);
    await tester.pumpAndSettle();
    expect(find.text('Nível 1 · Reconstrução primária'), findsOneWidget);
    expect(find.text('Nível 2 · Votações nominais'), findsOneWidget);
    expect(find.text('Nível 3 · Curadoria preliminar'), findsOneWidget);
  });
}
