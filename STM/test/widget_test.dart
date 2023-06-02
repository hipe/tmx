// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:stm/routes/list_skilltrees.dart';
//import 'package:stm/routes/view_skilltree.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('IMAGINE TESTING UI #case0250', (WidgetTester tester) async {

    // Build our app and trigger a frame.
    final sut = prepareGuy(RouteForListSkillTrees());
    await tester.pumpWidget(sut);

    // var matches = find.byType(Text);
    expect(find.text(NEEDLE_FOR_LIST_SKILL_TREES), findsOneWidget);
  });

  testWidgets('#case0055 not real', (WidgetTester tester) async {

    print("get rid of this test soon");  // keeping the examples around for now

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  }, tags: ['WIP',]);

  testWidgets('#case0275 click on item views item', (WidgetTester tester) async {
    // final sut = prepareGuy(RouteForViewSkillTree());
    final sut = prepareGuyForNav(RouteForListSkillTrees());
    await tester.pumpWidget(sut);

    // tap on the `Text` widget which is the non-item portion of the list item
    await tester.tap(find.text('Item 2'));

    await tester.pumpAndSettle();  // wait for new route to load (animation)

    const needle = 'OHAI I am an item';
    expect(find.text(needle), findsOneWidget);

    // ugly that this is in the same test case. this is testing something diff:

    await tester.tap(find.bySemanticsLabel('Back'));

    await tester.pumpAndSettle();  // wait for previous route to surface (anim)

    expect(find.text(needle), findsNothing);
    expect(find.text(NEEDLE_FOR_LIST_SKILL_TREES), findsOneWidget);
  });
}

Widget prepareGuyForNav(Widget xx) {
  return MaterialApp(
    home: xx,
  );
}

Widget prepareGuy(Widget xx) {
  // #todo: erase the commented-out code and similar after one commit lol
  // xx = Directionality(child: xx, textDirection: TextDirection.ltr);
  xx = Localizations(
    locale: const Locale('en', 'US'),
    delegates: const <LocalizationsDelegate<dynamic>>[
      DefaultWidgetsLocalizations.delegate,  // necessary at writing (hist A.1)
      DefaultMaterialLocalizations.delegate, // necessary at writing (hist A.1)
    ],
    child: xx,
    /*
    child: MediaQuery(
      data: const MediaQueryData(),
      child: xx,
    ),
    */
  );
  return xx;
}

const NEEDLE_FOR_LIST_SKILL_TREES = 'XYZZY 2';

/*
# #history-A.1: repurpose generated file for first widget test
*/
