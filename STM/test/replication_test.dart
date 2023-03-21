import 'package:stm/replication.dart';
import 'package:test/test.dart';

void main() {

  test('TEST TWO', () async {
    print('ok starting async test');
    final ting = ThingDing();
    await ting.tryThis();
    print('ok wow finished!');
  });


  test('TEST ONE', () {
    final ting = ThingDing();
    ting.increment();
    expect(ting.value, 1);
  });
}

/*
# #born
*/
