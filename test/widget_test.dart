import 'package:children_learning/color_drawing_game.dart';
import 'package:children_learning/before_after_game.dart';
import 'package:children_learning/keyboard_learning.dart';
import 'package:children_learning/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('asks for learner name then opens mouse practice', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BrightStepsApp());
    await tester.pumpAndSettle();
    expect(find.text('What is your name?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-learning')));
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('learner-name')), 'Ayaan');
    await tester.tap(find.byKey(const Key('start-learning')));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ayaan!'), findsOneWidget);

    await tester.tap(find.text('Mouse Practice'));
    await tester.pumpAndSettle();
    expect(find.text('Mouse Adventure'), findsOneWidget);

    await tester.tap(find.byKey(const Key('adventure-click')));
    await tester.pumpAndSettle();
    expect(find.text('Click on'), findsOneWidget);
    expect(find.byKey(const Key('target')), findsOneWidget);
    expect(find.text('Score  0'), findsOneWidget);
    expect(find.text('Add picture'), findsOneWidget);
    expect(find.text('اردو'), findsOneWidget);
  });

  testWidgets('continues with the last saved learner', (tester) async {
    SharedPreferences.setMockInitialValues({
      'learner_profiles': '[{"id":"1","name":"Ayaan","imagePath":null}]',
      'active_learner_id': '1',
    });
    await tester.pumpWidget(const BrightStepsApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, Ayaan!'), findsOneWidget);
    expect(find.byKey(const Key('manage-learners')), findsOneWidget);
    expect(find.text('Keyboard Learning'), findsOneWidget);
  });

  testWidgets('keyboard adventure offers four learning games', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardLearningScreen(learnerName: 'Ayaan')),
    );

    expect(find.text('Ready, Ayaan?'), findsOneWidget);
    expect(find.text('Key Explorer'), findsOneWidget);
    expect(find.text('Letter Hunt'), findsOneWidget);
    expect(find.text('Word Builder'), findsOneWidget);
    expect(find.text('Before & After'), findsOneWidget);
    expect(find.text('0 stars'), findsOneWidget);
  });

  testWidgets('before and after accepts a mixed-case English answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SequenceNeighborGame(learnerName: 'Ayaan')),
    );

    expect(
      tester.getTopLeft(find.byKey(const Key('sequence-english'))).dy,
      greaterThanOrEqualTo(56),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const Key('sequence-reference-english-0')))
          .dy,
      greaterThanOrEqualTo(56),
    );

    final shown = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('sequence-shown-key')),
            matching: find.byType(Text),
          ),
        )
        .data!;
    final expected = String.fromCharCode(shown.codeUnitAt(0) - 1);
    await tester.enterText(
      find.byKey(const Key('sequence-answer')),
      '$expected${expected.toLowerCase()}',
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byKey(const Key('answer-correct-popup')), findsOneWidget);
    expect(find.text('That is correct! 🎉'), findsOneWidget);
    expect(find.text('Check my answer'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('1 / 9 answers'), findsOneWidget);
    expect(find.byKey(const Key('sequence-numbers')), findsOneWidget);
    expect(find.byKey(const Key('sequence-urdu')), findsOneWidget);
    expect(
      find.byKey(const Key('sequence-reference-english-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('sequence-reference-english-25')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('sequence-numbers')));
    await tester.tap(find.byKey(const Key('sequence-numbers')));
    await tester.pump();
    expect(
      find.byKey(const Key('sequence-reference-numbers-9')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('sequence-urdu')));
    await tester.tap(find.byKey(const Key('sequence-urdu')));
    await tester.pump();
    expect(find.byKey(const Key('sequence-reference-urdu-38')), findsOneWidget);
  });

  testWidgets('key explorer responds to the on-screen keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyExplorerGame(learnerName: 'Ayaan')),
    );

    final keyA = find.byKey(const Key('keyboard-key-A'));
    await tester.ensureVisible(keyA);
    await tester.tap(keyA);
    await tester.pump();

    expect(find.text('Amazing! You found A'), findsOneWidget);
    expect(find.text('1 / 10 discoveries'), findsOneWidget);
    expect(find.text('A'), findsWidgets);
  });

  testWidgets('reference keys can answer with the mouse', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SequenceNeighborGame(learnerName: 'Ayaan')),
    );

    await tester.tap(find.byKey(const Key('sequence-numbers')));
    await tester.pump();
    final shown = int.parse(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('sequence-shown-key')),
              matching: find.byType(Text),
            ),
          )
          .data!,
    );
    final correctKey = find.byKey(
      Key('sequence-reference-numbers-${shown - 1}'),
    );
    await tester.ensureVisible(correctKey);
    await tester.tap(correctKey);
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byKey(const Key('answer-correct-popup')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('1 / 9 answers'), findsOneWidget);
  });

  testWidgets('before and after trail starts directly with a question', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BeforeAfterTrailGame(learnerName: 'Ayaan', onWin: () {}),
      ),
    );

    expect(find.text('BEFORE'), findsOneWidget);
    expect(find.textContaining('Click the picture before'), findsOneWidget);
    expect(find.text('Go LEFT ←'), findsOneWidget);
    await tester.tap(find.byKey(const Key('before-after-choice-0')));
    await tester.pump();
    expect(find.text('1 / 10'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
  });

  testWidgets('color drawing completes after every closed part is filled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ColorDrawingGame(learnerName: 'Ayaan')),
    );

    expect(find.text('0 / 7 parts'), findsOneWidget);
    await tester.tap(find.byKey(const Key('color-4')));
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.byKey(Key('color-part-$i')));
    }
    await tester.pump();

    expect(find.byKey(const Key('coloring-complete')), findsOneWidget);
    expect(find.text('Beautiful coloring, Ayaan!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('color-another')));
    await tester.pump();
    expect(find.text('0 / 7 parts'), findsOneWidget);
  });

  testWidgets('color drawing offers more pictures with matching part counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ColorDrawingGame(learnerName: 'Ayaan')),
    );

    for (final name in [
      'Flower',
      'Rocket',
      'Butterfly',
      'House',
      'Fish',
      'Car',
      'Ice Cream',
      'Turtle',
    ]) {
      expect(find.text(name), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('picture-house')));
    await tester.pump();
    expect(find.text('0 / 8 parts'), findsOneWidget);

    await tester.tap(find.byKey(const Key('picture-iceCream')));
    await tester.pump();
    expect(find.text('0 / 6 parts'), findsOneWidget);
    expect(find.byKey(const Key('color-part-5')), findsOneWidget);
    expect(find.byKey(const Key('color-part-6')), findsNothing);
  });
}
