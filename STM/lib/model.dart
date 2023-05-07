import 'package:floor/floor.dart';

/* For now we'll put the DAO right above the entity class but let's not
assume that's a hard & fast rule */

@dao
abstract class LikeDAO {

  @insert
  Future<int> createLike(Like like);  // note to self: amazed that this works

  @delete
  Future<int?> deleteLike(Like like);

  @Query('SELECT * FROM `Like` WHERE `word1` = :word1 AND `word2` = :word2')
  Future<List<Like>> findAllLikesWithThisNaturalKeyAsStream(
      String word1, String word2);

  /* #[#892.E] the above used to be `<Stream<List<Like>>` but it would block
  forever waiting for the stream to exit (probably).

  Same problem with `<Stream<Like?>>`.
  */

  @Query('SELECT * FROM `Like`')  // #[#892.E] change name convention for table?
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
