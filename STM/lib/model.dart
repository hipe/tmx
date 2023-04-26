import 'package:floor/floor.dart';

/* For now we'll put the DAO right above the entity class but let's not
assume that's a hard & fast rule */

@dao
abstract class LikeDAO {

  @Query('SELECT * FROM Like')  /* #open [#XXX] change this casing */
  Future<List<Like>> findAllLikes();

}


@entity
class Like {
  @primaryKey
  final int id;

  final String word1;
  final String word2;

  Like(this.id, this.word1, this.word2);
}

/*

# #history-A.1: begin introduce model for example
# #born
*/
