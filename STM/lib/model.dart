import 'package:floor/floor.dart';

class FooZizzle {
  int canYouCallThis() {
    return 1234;
  }
}


/* For now we'll put the DAO right above the entity class but let's not
assume that's a hard & fast rule */

@dao
abstract class PersonDao {  /* #open [#XXX] change this casing */

  @Query('SELECT * FROM Person')  /* #open [#XXX] change this casing */
  Future<List<Person>> findAllPersons();

}


@entity
class Person {
  @primaryKey
  final int id;

  final String name;

  Person(this.id, this.name);
}

/*
# #born
*/
