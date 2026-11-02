import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/models.dart';
import 'package:politico/engine/twelve_axes_engine.dart';

const QuestionHelp _help = QuestionHelp(
  agree: 'concorda',
  disagree: 'discorda',
  note: 'nota',
  agreeExample: 'exemplo a',
  disagreeExample: 'exemplo d',
);

AxisQuestion _question({
  required String id,
  required String axisId,
  required bool agreeIsLeft,
  double weight = 1,
}) {
  return AxisQuestion(
    id: id,
    axisId: axisId,
    text: 'Pergunta $id',
    agreeIsLeft: agreeIsLeft,
    weight: weight,
    terms: const <QuestionTerm>[],
    help: _help,
  );
}

Axis _axis(String id, String left, String right) {
  return Axis(
    id: id,
    label: id,
    leftPole: left,
    rightPole: right,
    leftColor: const Color(0xFF2F6DC0),
    rightColor: const Color(0xFFCF5A22),
  );
}

TwelveAxesData _fixture() {
  final List<Axis> axes = <Axis>[
    for (var i = 0; i < 12; i++) _axis('eixo$i', 'Esquerda$i', 'Direita$i'),
  ];
  final List<AxisQuestion> questions = <AxisQuestion>[];
  for (final Axis axis in axes) {
    for (var i = 0; i < 20; i++) {
      questions.add(
        _question(
          id: '${axis.id}_$i',
          axisId: axis.id,
          agreeIsLeft: i.isEven,
        ),
      );
    }
  }
  return TwelveAxesData(
    axes: axes,
    answerOptions: const <AnswerOption>[
      AnswerOption(id: 'STRONGLY_AGREE', label: 'Concordo totalmente', score: 1),
      AnswerOption(id: 'AGREE', label: 'Concordo', score: 0.75),
      AnswerOption(id: 'NEUTRAL', label: 'Neutro', score: 0.5),
      AnswerOption(id: 'DISAGREE', label: 'Discordo', score: 0.25),
      AnswerOption(id: 'STRONGLY_DISAGREE', label: 'Discordo totalmente', score: 0),
    ],
    questions: questions,
    archetypeQuestions: const <ArchetypeQuestion>[],
  );
}

/// Sessão de 3 perguntas no eixo 0 (L, L, R) e mantém os demais neutros.
TwelveAxesSession _threeQuestionSession() {
  final TwelveAxesData base = _fixture();
  final List<AxisQuestion> questions = <AxisQuestion>[
    _question(id: 'l1', axisId: 'custom', agreeIsLeft: true),
    _question(id: 'l2', axisId: 'custom', agreeIsLeft: true),
    _question(id: 'r1', axisId: 'custom', agreeIsLeft: false),
  ];
  final TwelveAxesData data = TwelveAxesData(
    axes: <Axis>[_axis('custom', 'Esquerda', 'Direita')],
    answerOptions: base.answerOptions,
    questions: questions,
    archetypeQuestions: const <ArchetypeQuestion>[],
  );
  final TwelveAxesSession session = TwelveAxesSession(
    data: data,
    variant: TwelveVariant.short,
    random: Random(7),
  );
  return session;
}

void main() {
  group('pontuação do 12 Eixos', () {
    test('respostas à esquerda inclinam o eixo e rotulam a intensidade', () {
      final TwelveAxesSession session = _threeQuestionSession();
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = 0;
      }
      final TwelveAxesResult result = session.result()!;
      final AxisScore score = result.scores.single;
      expect(score.leftPercent, closeTo(66.67, 0.01));
      expect(score.leansLeft, isTrue);
      expect(score.intensity, 'Inclinado');
      expect(score.summary, '67% Esquerda');
    });

    test('concordância total com os dois polos equilibra o eixo', () {
      final TwelveAxesSession session = _threeQuestionSession();
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = 2;
      }
      final AxisScore score = session.result()!.scores.single;
      expect(score.leftPercent, closeTo(50, 0.001));
      expect(score.intensity, 'Equilibrado');
      expect(score.summary, 'Equilibrado');
    });

    test('peso da pergunta proporcionalmente conta na média', () {
      final TwelveAxesData base = _fixture();
      final TwelveAxesData data = TwelveAxesData(
        axes: <Axis>[_axis('custom', 'Esquerda', 'Direita')],
        answerOptions: base.answerOptions,
        questions: <AxisQuestion>[
          _question(id: 'l1', axisId: 'custom', agreeIsLeft: true, weight: 3),
          _question(id: 'l2', axisId: 'custom', agreeIsLeft: true, weight: 1),
          _question(id: 'r1', axisId: 'custom', agreeIsLeft: false, weight: 1),
        ],
        archetypeQuestions: const <ArchetypeQuestion>[],
      );
      final TwelveAxesSession session = TwelveAxesSession(
        data: data,
        variant: TwelveVariant.short,
        random: Random(1),
      );
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = switch (session.questions[i].id) {
          'l2' => 4, // discordo totalmente da segunda pergunta de esquerda
          _ => 0,
        };
      }
      final AxisScore score = session.result()!.scores.single;
      expect(score.leftPercent, closeTo(60, 0.001));
      expect(score.intensity, 'Inclinado');
      expect(score.summary, '60% Esquerda');
    });

    test('resultado é nulo enquanto houver pergunta sem resposta', () {
      final TwelveAxesSession session = _threeQuestionSession();
      expect(session.result(), isNull);
      session.answers[0] = 0;
      expect(session.result(), isNull);
    });
  });

  group('seleção de perguntas', () {
    test('curta tem 36 perguntas e 3 por eixo', () {
      final TwelveAxesData data = _fixture();
      final List<AxisQuestion> questions =
          selectTwelveQuestions(data, TwelveVariant.short, Random(2));
      expect(questions.length, 36);
      for (final Axis axis in data.axes) {
        expect(questions.where((q) => q.axisId == axis.id).length, 3);
      }
      final int left = questions.where((q) => q.agreeIsLeft).length;
      expect(left, 18);
    });

    test('completa tem 60 perguntas e 5 por eixo', () {
      final TwelveAxesData data = _fixture();
      final List<AxisQuestion> questions =
          selectTwelveQuestions(data, TwelveVariant.complete, Random(3));
      expect(questions.length, 60);
      for (final Axis axis in data.axes) {
        expect(questions.where((q) => q.axisId == axis.id).length, 5);
      }
    });

    test('extrema usa todas as 240 perguntas', () {
      final TwelveAxesData data = _fixture();
      final List<AxisQuestion> questions =
          selectTwelveQuestions(data, TwelveVariant.extreme, Random(4));
      expect(questions.length, 240);
      expect(questions.map((q) => q.id).toSet().length, 240);
    });
  });

  group('troca de pergunta', () {
    test('troca por pergunta inédita do mesmo eixo e zera a resposta', () {
      final TwelveAxesSession session = TwelveAxesSession(
        data: _fixture(),
        variant: TwelveVariant.short,
        random: Random(5),
      );
      final String before = session.current.id;
      session.select(0);
      expect(session.swapCurrent(), isTrue);
      expect(session.current.id, isNot(before));
      expect(session.current.axisId, session.questions.first.axisId);
      expect(session.currentAnswer, isNull);
    });

    test('esgota o banco do eixo e retorna false', () {
      final TwelveAxesSession session = TwelveAxesSession(
        data: _fixture(),
        variant: TwelveVariant.short,
        random: Random(6),
      );
      // 20 perguntas no eixo, 3 em uso: no máximo 17 trocas.
      var swaps = 0;
      while (session.swapCurrent()) {
        swaps++;
        expect(swaps, lessThan(30));
      }
      expect(swaps, 17);
    });
  });
}
