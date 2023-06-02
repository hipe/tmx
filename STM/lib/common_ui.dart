import 'package:flutter/material.dart';

Widget buildCommonScaffold(
    Widget Function(BuildContext, BoxConstraints) builder
  ) {
  return Scaffold(
    appBar: AppBar(title: const Text('XYZZY 1')),
    body: LayoutBuilder(builder: builder),
  );
}

// Header

Widget buildCommonHeaderRow(String label) {
  return Padding(
    padding: const EdgeInsets.all(30), // came from the first tut?
    child: Text(label),
  );
}

// Generic button layout
// this is a stand-in for the dream of it, but at #abstraction it's messy

Widget layOutButtonsCommonly(List<Widget> buttons, BoxConstraints bc) {

  print("layout buttons (maxWidth: ${bc.maxWidth})");

  final _HowMany howMany = _howMany(buttons.length);

  // error case early
  if (_HowMany.zero == howMany) return Text('[no buttons]');

  // If it's narrow..
  if (narrowNotWide(bc)) {
    return _buttonsAsColumnLike(buttons);
  }

  // If there's only one button..
  if (_HowMany.one == howMany) {
    return _buttonsAsColumnLike(buttons);  // hi
  }

  // If there's two buttons..
  if (_HowMany.two == howMany) {
    assert(wideNotNarrow(bc));
    // ..do what we did in the original demo
    List<Widget> useThese = [buttons[0], _spacer(), buttons[1]];  // yuck
    return Row(children: useThese, mainAxisSize: MainAxisSize.min);
  }

  // If there's three or more..
  assert(_HowMany.many == howMany);
  assert(wideNotNarrow(bc));
  return _buttonsAsGrid(buttons);
}

Widget _buttonsAsGrid(List<Widget> buttons) {
  final Widget buttonsContainer = GridView(
    children: buttons,
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 245.0,
      mainAxisSpacing: 20.0,
      crossAxisSpacing: 15.0,
      childAspectRatio: 4.5,  // the golden ratio for a button rectangle lol
    ),
    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
  );
  return Expanded(child: buttonsContainer);
}

Widget _buttonsAsColumnLike(List<Widget> buttons) {  // DRY ME WITH ABOVE
  final Widget buttonsContainer = GridView(
    children: buttons,
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 400.0,
      mainAxisSpacing: 13.0,
      crossAxisSpacing: 0.0,  // you won't see cross-axis spacing here
      childAspectRatio: 8,  // the golden ratio for a button rectangle lol
    ),
    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 7.0),
  );
  return Expanded(child: buttonsContainer);
}

Widget _spacer() {
  return SizedBox(width: 10);
}

// Screen metrics - centralize responsive layout magic numbers

//// How Many

_HowMany _howMany(int num) {
  if (1 == num) return _HowMany.one;
  if (2 == num) return _HowMany.two;
  if (0 == num) return _HowMany.zero;
  if (2 < num) return _HowMany.many;
  throw UnimplementedError('need zero or more, had $num');
}

enum _HowMany { zero, one, two, many }

//// Wide vs narrow

bool wideNotNarrow(BoxConstraints constraints) {
  return ! narrowNotWide(constraints);
}

bool narrowNotWide(BoxConstraints constraints) {
  return constraints.maxWidth < 450;
}

// Magic number constants

const double THIS_WIDTH = 400;
const double THIS_HEIGHT = 80;


/*
# #abstracted
*/
