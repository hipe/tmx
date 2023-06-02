import '../common_ui.dart' as cui;
import '../model.dart' show IMAGINE_SkillTree;
import 'package:flutter/material.dart';

class RouteForViewSkillTree extends StatelessWidget {

  final IMAGINE_SkillTree skillTree;

  RouteForViewSkillTree({required IMAGINE_SkillTree this.skillTree, super.key});

  @override
  Widget build(BuildContext context) {
    return cui.buildCommonScaffold((context, constraints) {
      return _buildRouteBody(this.skillTree);
    });
  }
}

Widget _buildRouteBody(IMAGINE_SkillTree skillTree) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      cui.buildCommonHeaderRow('OHAI I am an item'),  // #case0275
      Padding(
        child: _buildDataTable(skillTree),
        padding: EdgeInsets.only(top: 0.0, right: 0.0, bottom: 15.0, left: 15.0),
      ),
      SizedBox(height: 50, width: 300, child: Placeholder()),
    ],
  );
}

Widget _buildDataTable(IMAGINE_SkillTree skillTree) {
  return DataTable(
    columns: [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Value')),
    ],
    rows: [
      DataRow(cells: [
        DataCell(Text('label')),
        DataCell(Text(skillTree.label)),
      ]),
      DataRow(cells: [
        DataCell(Text('imagine')),
        DataCell(Text('something else')),
      ]),
    ],
  );
}

/*
# #born
*/
