import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a estimativa da bateria integral não é truncada em 40 minutos', () {
    expect(TestDepth.express.estimatedDuration(24), '~3 min');
    expect(TestDepth.quick.estimatedDuration(60), '~8 min');
    expect(TestDepth.standard.estimatedDuration(120), '~15 min');
    expect(TestDepth.deep.estimatedDuration(240), '~30 min');
    expect(TestDepth.exhaustive.estimatedDuration(528), '~66 min');
  });

  test(
    'modo Expresso seleciona 24 perguntas (só eixos) e permite completar +18 tríades preservando validade psicométrica',
    () async {
      final AppData data = await AppData.load();
      final EvaluationRepository repository = EvaluationRepository(
        storage: LocalStorageService.inMemory(),
      );

      expect(
        TestDepth.express.expectedCount(
          TestSuite.espectroIntegrated,
          totalAxesPool: data.twelveAxes.questions.length,
          totalTriadsPool: data.sixTriangles.questions.length,
        ),
        24,
      );
      expect(
        TestDepth.express.expectedCount(
          TestSuite.bipolarAxes,
          totalAxesPool: data.twelveAxes.questions.length,
          totalTriadsPool: data.sixTriangles.questions.length,
        ),
        24,
      );
      expect(
        TestDepth.express.expectedCount(
          TestSuite.triads,
          totalAxesPool: data.twelveAxes.questions.length,
          totalTriadsPool: data.sixTriangles.questions.length,
        ),
        18,
      );

      final QuizViewModel expressVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.express,
        seed: 101,
      );
      expect(expressVm.totalCount, 24);

      for (var i = 0; i < expressVm.totalCount; i++) {
        expressVm.jumpTo(i);
        expressVm.selectAnswer(
          i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
        );
      }

      final EvaluationRecord expressRecord = expressVm.buildCompletedRecord();
      await repository.saveRecord(expressRecord);
      expect(expressRecord.suite, TestSuite.bipolarAxes);
      expect(expressRecord.depth, TestDepth.express);
      expect(expressRecord.axes, hasLength(12));
      expect(expressRecord.triads, isEmpty);
      for (final BipolarDimensionScore axis in expressRecord.axes) {
        expect(axis.isIndeterminate, isFalse, reason: axis.axisId);
        expect(axis.hasBothPoles, isTrue, reason: axis.axisId);
        expect(axis.answeredCount, 2, reason: axis.axisId);
      }

      // Inicia o complemento de +18 perguntas das Tríades sobre o perfil Expresso
      final QuizViewModel supplementVm = QuizViewModel.startTriadSupplement(
        data: data,
        repository: repository,
        baseRecord: expressRecord,
        seed: 202,
      );
      expect(supplementVm.totalCount, 18);

      // Verifica persistência de rascunho retomável preservando completingRecordId
      supplementVm.selectAnswer(LikertAnswer.stronglyAgree);
      final ActiveQuizDraft draft = ActiveQuizDraft.fromJson(
        supplementVm.toDraft().toJson(),
      );
      expect(draft.completingRecordId, expressRecord.id);

      final QuizViewModel resumedVm = QuizViewModel.fromDraft(
        data: data,
        repository: repository,
        draft: draft,
        history: <EvaluationRecord>[expressRecord],
      );
      for (var i = 0; i < resumedVm.totalCount; i++) {
        resumedVm.jumpTo(i);
        resumedVm.selectAnswer(
          i % 2 == 0 ? LikertAnswer.stronglyAgree : LikertAnswer.disagree,
        );
      }

      final EvaluationRecord mergedRecord = resumedVm.buildCompletedRecord();
      expect(mergedRecord.id, expressRecord.id);
      expect(mergedRecord.suite, TestSuite.espectroIntegrated);
      expect(mergedRecord.depth, TestDepth.express);
      expect(mergedRecord.axes, hasLength(12));
      expect(mergedRecord.triads, hasLength(6));
      expect(mergedRecord.rawAnswers, hasLength(42));
      for (var i = 0; i < 12; i++) {
        expect(
          mergedRecord.axes[i].score,
          closeTo(expressRecord.axes[i].score, 1e-9),
        );
      }
      for (final TriadDimensionScore triad in mergedRecord.triads) {
        expect(triad.isIndeterminate, isFalse, reason: triad.label);
        expect(triad.hasAllVerticesObserved, isTrue, reason: triad.label);
        expect(triad.answeredCount, 3, reason: triad.label);
      }
    },
  );
}
