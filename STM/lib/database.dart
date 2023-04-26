import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'model.dart';

part 'database.g.dart';  // generated code

@Database(version: 1, entities: [Like])
abstract class AppDatabase extends FloorDatabase {
  LikeDAO get likeDAO;
}

/*
# #born
*/
