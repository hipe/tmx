import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class ThingDing {
  int value = 0;

  Future<void> tryThis() async {
    print('yes beginning');
    WidgetsFlutterBinding.ensureInitialized();
    final database = openDatabase(
      join(await getDatabasesPath(), 'some_derta_berse.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE erase_me(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,  // makes the onCreate get called
    );
    print('hello did it work?');
  }

  void increment() => value++;

  void decerment() => value--;

}

/*
# #born
*/
