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
  });
}
