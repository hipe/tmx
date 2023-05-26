import '../common_ui.dart' as cui;
import 'package:flutter/material.dart';

class IMAGINE_A_ROUTE extends StatelessWidget {
  const IMAGINE_A_ROUTE({super.key});

  @override
  Widget build(BuildContext context) {

    final dataItems = [
      for (var str in _TEMP_HARD_CODED)
        _DataItem(label: str),  // was const but (try it)
    ];

    final color = Theme.of(context).colorScheme.primary;
    final List<ListTile> tiles = [
      for (var item in dataItems)
        _listTileViaDataItem(item, color),
    ];

    final buttons = [
      ElevatedButton.icon(
        label: Text('Button 1'),
        icon: Icon(Icons.token),
        onPressed: () => print('pressed a button'),
      ),
      ElevatedButton(
        child: Text('Button 2'),
        onPressed: () => print('another button pressed'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('XYZZY 1')),
      body: LayoutBuilder(  // NOT USED YET. no responsiveness yet
        builder: (context, constraints) {
          return _buildWholeThing(tiles, buttons, constraints, context);
        },
      ),
    );
  }
}

Widget _buildWholeThing(tiles, buttons, BoxConstraints bc, context) {
  final butts = cui.layOutButtonsCommonly(buttons, bc);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(30), // #todo
        child: Text('Hello this is some kind of header XYZZY 2'),
      ),
      _popularGridView(tiles),
      SizedBox(height: 120.0, child: Center(child: butts)),  // #todo
    ],
  );
}

Widget _popularGridView(List<Widget> tiles) {
  return Expanded(
    child: GridView(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: cui.THIS_WIDTH,
        childAspectRatio: cui.THIS_WIDTH / cui.THIS_HEIGHT,
      ),
      children: tiles,
    ),
  );
}

ListTile _listTileViaDataItem(dataItem, color) {
  /* note to self in the future: probably we don't want just the leading
  icon (IconButton) to be clickable. probably we want etc.  */

  return ListTile(
    leading: IconButton(
      icon: Icon(Icons.token, semanticLabel: 'SOMETHING'),
      color: color,
      onPressed: () {
        print("(this used to do a thing)");
      },
    ),
    title: Text(dataItem.label),
  );
}

Widget _buildDismissButton(context) {
  // wrap in Center when alone
  return ElevatedButton(
    child: const Text('ZIBBA POP'),
    onPressed: () {
      print("popping back to previous screen..");
      Navigator.pop(context);
    },
  );
}

class _DataItem {
  final String label;
  const _DataItem({required String this.label});  // keymash
}

const _TEMP_HARD_CODED = ['Item 1', 'Item 2', 'Item 3'];

/*
# #born
*/
