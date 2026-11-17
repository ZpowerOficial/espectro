import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_sources.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late StudyCatalog catalog;

  setUpAll(() async {
    data = await AppData.load();
    catalog = StudyCatalog(data);
  });

  group('Parliamentary Profiles and Nominal Roll-Call Audit', () {
    test('extended personalities contain 1404 Brazilian parliamentarians scored from roll calls', () {
      final extJson = jsonDecode(File('assets/data/personalities_extended.json').readAsStringSync()) as Map<String, dynamic>;
      final entries = (extJson['entries'] as List<dynamic>).cast<Map<String, dynamic>>();
      final parliamentarians = entries.where((e) {
        final category = e['category'] as String? ?? '';
        return category.contains('Parlamentar');
      }).toList();

      expect(parliamentarians.length, 1404);

      for (final p in parliamentarians) {
        expect(p['id'], isNotEmpty);
        expect(p['name'], contains('('));
        expect(p['origin'], startsWith('Brasil'));
        expect(p['spectrumId'], isIn(['radical_left', 'left', 'center', 'right', 'far_right', 'libertarian']));

        final basis = p['editorialBasis'] as Map<String, dynamic>;
        expect(basis['evidenceTier'], 'tier2_institutional_record');
        expect(basis['dossierShard'], matches(RegExp(r'^shard_[0-9]{2}$')));

        final sourceUrls = (basis['sourceUrls'] as List<dynamic>).cast<String>();
        expect(sourceUrls, isNotEmpty);
        for (final url in sourceUrls) {
          expect(
            url.contains('camara.leg.br') || url.contains('senado.leg.br'),
            isTrue,
            reason: 'URL must point to official legislative portal: $url',
          );
        }

        // Axes must only contain observed dimensions, with no 0.0 filling
        final axes = (p['axes'] as Map<String, dynamic>).cast<String, num>();
        expect(axes.length, inInclusiveRange(1, 12));
      }
    });

    test('prominent parliamentarians across all political spectra have verified votes', () {
      final sample = <String, ({String spectrum, int minAxes})>{
        'Tabata Amaral (SP)': (spectrum: 'left', minAxes: 10),
        'Marcel van Hattem (RS)': (spectrum: 'right', minAxes: 10),
        'Kim Kataguiri (SP)': (spectrum: 'right', minAxes: 10),
        'Eduardo Bolsonaro (SP)': (spectrum: 'right', minAxes: 10),
        'Gleisi Hoffmann (PR)': (spectrum: 'left', minAxes: 8),
        'Guilherme Boulos (SP)': (spectrum: 'radical_left', minAxes: 8),
        'Erika Hilton (SP)': (spectrum: 'radical_left', minAxes: 8),
        'Nikolas Ferreira (MG)': (spectrum: 'right', minAxes: 8),
        'Bia Kicis (DF)': (spectrum: 'far_right', minAxes: 10),
        'Arthur Lira (AL)': (spectrum: 'far_right', minAxes: 8),
        'Flávio Bolsonaro (RJ)': (spectrum: 'far_right', minAxes: 6),
        'Romário (RJ)': (spectrum: 'right', minAxes: 8),
        'Sergio Moro (PR)': (spectrum: 'right', minAxes: 5),
      };

      for (final entry in sample.entries) {
        final matches = catalog.search(entry.key);
        expect(
          matches,
          isNotEmpty,
          reason: 'Parliamentarian ${entry.key} must be indexed and searchable',
        );

        final subject = matches.first;
        expect(subject.entry, isNotNull);
        expect(subject.spectrumId, entry.value.spectrum);
        expect(subject.axes.length, greaterThanOrEqualTo(entry.value.minAxes));
        expect(subject.entry!.highlights.first, contains('votações nominais'));
      }
    });

    test('lazy-loaded dimension evidence preserves nominal vote locators and rationales', () async {
      final tabataSubject = catalog.search('Tabata Amaral').first;
      final shard = tabataSubject.entry!.editorialBasis!.dossierShard!;
      final sourceUrls = tabataSubject.entry!.editorialBasis!.sourceUrls;

      final evidence = await data.loadDossierEvidence(
        tabataSubject.key,
        shard: shard,
        allowedSourceUrls: sourceUrls,
      );

      expect(evidence, isNotEmpty);
      for (final dim in evidence.values) {
        expect(dim.status, 'institutional_vote');
        expect(dim.isInstitutionalVote, isTrue);
        expect(dim.locator, matches(RegExp(r"(PEC|PL|MPV|PLP|PDC|PDL)\s+\d+/\d+.*voto\s+'(Sim|Não)'")));
        expect(dim.rationale, contains('votações nominais'));
        expect(dim.sourceUrls, isNotEmpty);
      }
    });

    test('study sources include official legislative portals for Chamber and Senate', () {
      final camaraPortal = studySources.where((s) => s.url.contains('dadosabertos.camara.leg.br')).toList();
      expect(camaraPortal, isNotEmpty);
      expect(camaraPortal.first.title, contains('Câmara dos Deputados'));

      final senadoPortal = studySources.where((s) => s.url.contains('legis.senado.leg.br')).toList();
      expect(senadoPortal, isNotEmpty);
      expect(senadoPortal.first.title, contains('Senado Federal'));

      final bolsonaroProfile = studySources.where((s) => s.url == 'https://www.camara.leg.br/deputados/74847').toList();
      expect(bolsonaroProfile, isNotEmpty);
      expect(bolsonaroProfile.first.keys, contains('personality:jair_bolsonaro'));

      final gilsonProfile = studySources.where((s) => s.url == 'https://www.camara.leg.br/deputados/204365').toList();
      expect(gilsonProfile, isNotEmpty);
      expect(gilsonProfile.first.keys, contains('personality:gilson_marques'));
    });

    test('core politicians with legislative mandates link to official roll call records', () {
      final bolsonaro = catalog.find('personality:jair_bolsonaro')!;
      expect(bolsonaro.entry!.editorialBasis!.sourceUrls, contains('https://www.camara.leg.br/deputados/74847'));
      expect(bolsonaro.entry!.editorialBasis!.scope, contains('votações nominais'));

      final gilson = catalog.find('personality:gilson_marques')!;
      expect(gilson.entry!.editorialBasis!.sourceUrls, contains('https://www.camara.leg.br/deputados/204365'));
      expect(gilson.entry!.editorialBasis!.scope, contains('votações nominais'));
    });
  });
}
