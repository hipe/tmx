import 'database.dart';
import 'model.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;


class VariousThingsTester {
  int value = 0;

  Future<void> imagineDoingThis() async {

    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final like_DAO = database.likeDao;
    final List<Like> ents = await like_DAO.findAllLikes();
    print('wow we got some kind of result: ' + ents.length.toString());
  }

  Future<void> createSchema() async {
    print('yes beginning');
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
    } else {
      WidgetsFlutterBinding.ensureInitialized();
    }
    databaseFactory = databaseFactoryFfi;
    String xx = await getDatabasesPath();
    print("thing: " + xx);

    final database = await openDatabase(
      join(xx, 'some_derta_berse.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE erase_me(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,  // makes the onCreate get called
    );
    print('hello did it work?: ' + database.path);
  }

  void increment() => value++;

  void decerment() => value--;

}

/*
# #history-A.1: connect to database
# #born
*/
