// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  LikeDAO? _likeDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Like` (`id` INTEGER, `word1` TEXT NOT NULL, `word2` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  LikeDAO get likeDAO {
    return _likeDAOInstance ??= _$LikeDAO(database, changeListener);
  }
}

class _$LikeDAO extends LikeDAO {
  _$LikeDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _likeInsertionAdapter = InsertionAdapter(
            database,
            'Like',
            (Like item) => <String, Object?>{
                  'id': item.id,
                  'word1': item.word1,
                  'word2': item.word2
                }),
        _likeDeletionAdapter = DeletionAdapter(
            database,
            'Like',
            ['id'],
            (Like item) => <String, Object?>{
                  'id': item.id,
                  'word1': item.word1,
                  'word2': item.word2
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Like> _likeInsertionAdapter;

  final DeletionAdapter<Like> _likeDeletionAdapter;

  @override
  Future<List<Like>> findAllLikesWithThisNaturalKeyAsStream(
    String word1,
    String word2,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `Like` WHERE `word1` = ?1 AND `word2` = ?2',
        mapper: (Map<String, Object?> row) => Like(
            row['id'] as int?, row['word1'] as String, row['word2'] as String),
        arguments: [word1, word2]);
  }

  @override
  Future<List<Like>> findAllLikes() async {
    return _queryAdapter.queryList('SELECT * FROM `Like`',
        mapper: (Map<String, Object?> row) => Like(
            row['id'] as int?, row['word1'] as String, row['word2'] as String));
  }

  @override
  Future<int> createLike(Like like) {
    return _likeInsertionAdapter.insertAndReturnId(
        like, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteLike(Like like) {
    return _likeDeletionAdapter.deleteAndReturnChangedRows(like);
  }
}
