import 'package:stm/replication.dart';
import 'package:test/test.dart';
import 'package:stm/model.dart';  /* #open [#892.D] we don't know how to .. */

void main() {

  test('TEST THREE - fah fah', () async {
    print('hallo starting test THREE');
    final ting = VariousThingsTester();
    await ting.imagineDoingThis();
    print('Great job! There is a god.');
  });

  test('TEST TWO', () async {
    print('ok starting async test');
    final ting = VariousThingsTester();
    await ting.createSchema();
    print('ok wow finished!');
  });


  test('TEST ONE', () {
    final ting = VariousThingsTester();
    ting.increment();
    expect(ting.value, 1);
  });
}

/*
# #born
*/
