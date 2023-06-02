import './view_skilltree.dart';
import '../common_ui.dart' as cui;
import '../model.dart' show IMAGINE_SkillTree;
import 'package:flutter/material.dart';

class RouteForListSkillTrees extends StatelessWidget {
  const RouteForListSkillTrees({super.key});

  @override
  Widget build(BuildContext context) {

    final dataItems = [
      for (var str in _TEMP_HARD_CODED)
        IMAGINE_SkillTree(label: str),
    ];

    final color = Theme.of(context).colorScheme.primary;
    final tileBuilder = _buildTileBuilder(color, context);
    final List<Widget> tiles = [for (final x in dataItems.map(tileBuilder)) x];

    /*
    final List<Widget> tiles = [
      for (var item in dataItems)
        _listTileViaDataItem(item, color),
    ];
    */

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

    return cui.buildCommonScaffold((context, constraints) {
      return _buildRouteBody(tiles, buttons, constraints, context);
    });
  }
}

Widget _buildRouteBody(tiles, buttons, BoxConstraints bc, context) {
  final butts = cui.layOutButtonsCommonly(buttons, bc);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      cui.buildCommonHeaderRow('XYZZY 2'),  // #case0250
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

Function(IMAGINE_SkillTree) _buildTileBuilder(color, context) {
  return (dataItem) {
    final text = Text(dataItem.label);
    final onClick = _itemClickHandlerVia(dataItem, context);
    final clickable = _clickableVia(text, onClick);
    final mouseRegion = _mouseRegionVia(clickable);

    return ListTile(
      leading: IconButton(
        icon: Icon(Icons.token, semanticLabel: 'SOMETHING'),
        color: color,
        onPressed: () => onClick(),
      ),
      title: mouseRegion,
    );
  };
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

Widget _mouseRegionVia(Widget child) {
  return MouseRegion(child: child, cursor: SystemMouseCursors.click);
}

Widget _clickableVia(Widget child, Function handler) {
  return GestureDetector(child: child, onTap: () => handler());  // #todo xx
}

Function _itemClickHandlerVia(IMAGINE_SkillTree dataItem, BuildContext context) {
  return (() {
    print("IMAGINE VIEW '${dataItem.label}'");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctxt) {
        return RouteForViewSkillTree(skillTree: dataItem);
      }),
    );
  });
}

const _TEMP_HARD_CODED = ['Item 1', 'Item 2', 'Item 3'];

/*
# #born
*/
