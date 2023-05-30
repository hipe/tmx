// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:stm/routes/list_skilltrees.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('IMAGINE TESTING UI #case0250', (WidgetTester tester) async {

    // Build our app and trigger a frame.
    final sut = prepareGuy(IMAGINE_A_ROUTE());
    await tester.pumpWidget(sut);

    // var matches = find.byType(Text);
    expect(find.text('XYZZY 2'), findsOneWidget);
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

/*
# #history-A.1: repurpose generated file for first widget test
*/
