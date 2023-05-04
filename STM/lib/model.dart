import 'package:floor/floor.dart';

/* For now we'll put the DAO right above the entity class but let's not
assume that's a hard & fast rule */

@dao
abstract class LikeDAO {

  @insert
  Future<int> createLike(Like like);  // this is amazing if this works

  @Query('SELECT * FROM Like')  /* #open [#XXX] change this casing */
  Future<List<Like>> findAllLikes();

}


@entity
class Like {
  @primaryKey
  final int? id;
  // changed to nullable so we can get autoincrement on create at #history-A.2

  final String word1;
  final String word2;

  Like(this.id, this.word1, this.word2);
}

/*

# #history-A.2: (as referenced)
# #history-A.1: begin introduce model for example
# #born
*/
