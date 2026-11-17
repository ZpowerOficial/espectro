import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/theme.dart';
import 'package:politico/widgets/common.dart';

void main() {
  testWidgets('AppButton expõe rótulo, papel de botão e ação semântica', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Começar minha avaliação',
              expand: false,
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );

    final SemanticsNode node = tester.getSemantics(find.byType(AppButton));
    expect(node.label, 'Começar minha avaliação');
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isEnabled, Tristate.isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('AppButton desabilitado não oferece ação de toque', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Center(
            child: AppButton(
              label: 'Indisponível',
              expand: false,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    final SemanticsNode node = tester.getSemantics(find.byType(AppButton));
    expect(node.label, 'Indisponível');
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isEnabled, Tristate.isFalse);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    handle.dispose();
  });
}
